import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

/// 🌐 Network Optimization Utility
/// Provides comprehensive network optimization including:
/// - Request caching and deduplication
/// - Connection monitoring
/// - Retry mechanisms
/// - Bandwidth optimization
/// - Request prioritization

class NetworkOptimization {
  static final NetworkOptimization _instance = NetworkOptimization._internal();
  factory NetworkOptimization() => _instance;
  NetworkOptimization._internal();

  late final Dio _dio;
  final Map<String, CachedResponse> _responseCache = {};
  final Map<String, Future<Response>> _pendingRequests = {};
  final List<ConnectivityResult> _connectionHistory = [];
  ConnectivityResult _currentConnection = ConnectivityResult.none;
  bool _isOnline = false;

  /// Initialize network optimization
  void initialize() {
    _setupDio();
    _setupConnectivityMonitoring();
    _setupPeriodicCacheCleanup();
  }

  /// Setup Dio with optimizations
  void _setupDio() {
    _dio = Dio();
    
    // Add interceptors
    _dio.interceptors.addAll([
      CacheInterceptor(),
      DeduplicationInterceptor(),
      RetryInterceptor(),
      PerformanceInterceptor(),
      ConnectionInterceptor(),
    ]);

    // Configure timeouts based on connection
    _updateTimeoutsForConnection();
  }

  /// Setup connectivity monitoring
  void _setupConnectivityMonitoring() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _currentConnection = result;
      _isOnline = result != ConnectivityResult.none;
      _connectionHistory.add(result);
      
      // Keep only last 10 connection changes
      if (_connectionHistory.length > 10) {
        _connectionHistory.removeAt(0);
      }
      
      _updateTimeoutsForConnection();
      debugPrint('🌐 Connection changed: $result');
    });
  }

  /// Update timeouts based on current connection
  void _updateTimeoutsForConnection() {
    Duration connectTimeout;
    Duration receiveTimeout;
    Duration sendTimeout;

    switch (_currentConnection) {
      case ConnectivityResult.wifi:
        connectTimeout = const Duration(seconds: 10);
        receiveTimeout = const Duration(seconds: 30);
        sendTimeout = const Duration(seconds: 30);
        break;
      case ConnectivityResult.mobile:
        connectTimeout = const Duration(seconds: 15);
        receiveTimeout = const Duration(seconds: 45);
        sendTimeout = const Duration(seconds: 45);
        break;
      case ConnectivityResult.ethernet:
        connectTimeout = const Duration(seconds: 5);
        receiveTimeout = const Duration(seconds: 20);
        sendTimeout = const Duration(seconds: 20);
        break;
      default:
        connectTimeout = const Duration(seconds: 30);
        receiveTimeout = const Duration(seconds: 60);
        sendTimeout = const Duration(seconds: 60);
    }

    _dio.options = _dio.options.copyWith(
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
    );
  }

  /// Setup periodic cache cleanup
  void _setupPeriodicCacheCleanup() {
    Timer.periodic(const Duration(minutes: 10), (timer) {
      _cleanupExpiredCache();
    });
  }

  /// Clean up expired cache entries
  void _cleanupExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _responseCache.entries) {
      if (entry.value.isExpired(now)) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _responseCache.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      debugPrint('🧹 Cleaned ${expiredKeys.length} expired cache entries');
    }
  }

  /// Make optimized GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    Duration? cacheFor,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    return _makeRequest(
      'GET',
      path,
      queryParameters: queryParameters,
      options: options,
      cacheFor: cacheFor,
      priority: priority,
    );
  }

  /// Make optimized POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    return _makeRequest(
      'POST',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      priority: priority,
    );
  }

  /// Make optimized request with caching and deduplication
  Future<Response> _makeRequest(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Duration? cacheFor,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    // Create request key for caching/deduplication
    final requestKey = _createRequestKey(method, path, queryParameters, data);

    // Check cache for GET requests
    if (method == 'GET' && _responseCache.containsKey(requestKey)) {
      final cached = _responseCache[requestKey]!;
      if (!cached.isExpired(DateTime.now())) {
        debugPrint('📦 Cache hit: $path');
        return cached.response;
      }
    }

    // Check for pending identical requests
    if (_pendingRequests.containsKey(requestKey)) {
      debugPrint('🔄 Deduplicating request: $path');
      return await _pendingRequests[requestKey]!;
    }

    // Create the request future
    final requestFuture = _executeRequest(
      method,
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      priority: priority,
    );

    // Store as pending request
    _pendingRequests[requestKey] = requestFuture;

    try {
      final response = await requestFuture;

      // Cache GET responses if requested
      if (method == 'GET' && cacheFor != null) {
        _responseCache[requestKey] = CachedResponse(
          response: response,
          cachedAt: DateTime.now(),
          expiresAfter: cacheFor,
        );
      }

      return response;
    } finally {
      // Remove from pending requests
      _pendingRequests.remove(requestKey);
    }
  }

  /// Execute the actual request
  Future<Response> _executeRequest(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    final mergedOptions = (options ?? Options()).copyWith(
      extra: {
        'priority': priority,
        'startTime': DateTime.now().millisecondsSinceEpoch,
      },
    );

    switch (method) {
      case 'GET':
        return await _dio.get(path, queryParameters: queryParameters, options: mergedOptions);
      case 'POST':
        return await _dio.post(path, data: data, queryParameters: queryParameters, options: mergedOptions);
      case 'PUT':
        return await _dio.put(path, data: data, queryParameters: queryParameters, options: mergedOptions);
      case 'DELETE':
        return await _dio.delete(path, queryParameters: queryParameters, options: mergedOptions);
      default:
        throw UnsupportedError('Method $method not supported');
    }
  }

  /// Create unique request key for caching/deduplication
  String _createRequestKey(String method, String path, Map<String, dynamic>? query, dynamic data) {
    final buffer = StringBuffer();
    buffer.write(method);
    buffer.write(':');
    buffer.write(path);
    
    if (query != null && query.isNotEmpty) {
      buffer.write('?');
      buffer.write(Uri(queryParameters: query.map((k, v) => MapEntry(k, v.toString()))).query);
    }
    
    if (data != null) {
      buffer.write('#');
      buffer.write(data.hashCode);
    }
    
    return buffer.toString();
  }

  /// Get network status
  NetworkStatus getNetworkStatus() {
    return NetworkStatus(
      isOnline: _isOnline,
      connection: _currentConnection,
      cacheSize: _responseCache.length,
      pendingRequests: _pendingRequests.length,
      connectionHistory: List.from(_connectionHistory),
    );
  }

  /// Clear cache
  void clearCache() {
    _responseCache.clear();
    debugPrint('🧹 Network cache cleared');
  }
}

/// Cached response wrapper
class CachedResponse {
  final Response response;
  final DateTime cachedAt;
  final Duration expiresAfter;

  CachedResponse({
    required this.response,
    required this.cachedAt,
    required this.expiresAfter,
  });

  bool isExpired(DateTime now) {
    return now.isAfter(cachedAt.add(expiresAfter));
  }
}

/// Request priority levels
enum RequestPriority {
  low,
  normal,
  high,
  critical,
}

/// Network status information
class NetworkStatus {
  final bool isOnline;
  final ConnectivityResult connection;
  final int cacheSize;
  final int pendingRequests;
  final List<ConnectivityResult> connectionHistory;

  NetworkStatus({
    required this.isOnline,
    required this.connection,
    required this.cacheSize,
    required this.pendingRequests,
    required this.connectionHistory,
  });

  Map<String, dynamic> toJson() => {
    'isOnline': isOnline,
    'connection': connection.toString(),
    'cacheSize': cacheSize,
    'pendingRequests': pendingRequests,
    'connectionHistory': connectionHistory.map((c) => c.toString()).toList(),
  };
}

/// Cache interceptor for automatic response caching
class CacheInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Add cache headers info to response
    response.extra['cached'] = false;
    response.extra['cacheTime'] = DateTime.now().millisecondsSinceEpoch;
    
    super.onResponse(response, handler);
  }
}

/// Deduplication interceptor to prevent duplicate requests
class DeduplicationInterceptor extends Interceptor {
  // Implementation is handled in NetworkOptimization._makeRequest
}

/// Retry interceptor for failed requests
class RetryInterceptor extends Interceptor {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      
      if (retryCount < maxRetries) {
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        
        await Future.delayed(retryDelay * (retryCount + 1));
        
        try {
          final response = await Dio().fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Continue to original error handler
        }
      }
    }
    
    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    // Retry on network errors, timeouts, and 5xx server errors
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

/// Performance interceptor for tracking request performance
class PerformanceInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['startTime'] = DateTime.now().millisecondsSinceEpoch;
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['startTime'] as int?;
    if (startTime != null) {
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      response.extra['duration'] = duration;
      
      if (kDebugMode) {
        debugPrint('🌐 ${response.requestOptions.method} ${response.requestOptions.path}: ${duration}ms');
      }
    }
    
    super.onResponse(response, handler);
  }
}

/// Connection interceptor for handling offline scenarios
class ConnectionInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Check if we should proceed with request based on connection
    final networkStatus = NetworkOptimization().getNetworkStatus();
    
    if (!networkStatus.isOnline) {
      handler.reject(DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        message: 'No internet connection',
      ));
      return;
    }
    
    super.onRequest(options, handler);
  }
}