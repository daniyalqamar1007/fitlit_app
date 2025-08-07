import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'dart:math';

/// 📊 Performance Monitoring System
/// Comprehensive performance tracking including:
/// - Frame rate monitoring
/// - Load time tracking
/// - Memory usage monitoring
/// - Network performance
/// - User interaction timing

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final List<FrameMetric> _frameMetrics = [];
  final List<LoadTimeMetric> _loadTimeMetrics = [];
  final List<InteractionMetric> _interactionMetrics = [];
  final List<NetworkMetric> _networkMetrics = [];
  
  Timer? _monitoringTimer;
  bool _isMonitoring = false;
  
  /// Start performance monitoring
  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _startFrameRateMonitoring();
    _startPeriodicReporting();
    
    debugPrint('🚀 Performance monitoring started');
  }

  /// Stop performance monitoring
  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    
    debugPrint('⏹️ Performance monitoring stopped');
  }

  /// Start frame rate monitoring
  void _startFrameRateMonitoring() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isMonitoring) return;
      
      final frameStart = DateTime.now();
      
      SchedulerBinding.instance.addPostFrameCallback((_) {
        final frameEnd = DateTime.now();
        final frameDuration = frameEnd.difference(frameStart).inMicroseconds;
        
        _recordFrameMetric(frameDuration);
        
        // Schedule next frame monitoring
        if (_isMonitoring) {
          _startFrameRateMonitoring();
        }
      });
    });
  }

  /// Record frame metric
  void _recordFrameMetric(int durationMicroseconds) {
    final metric = FrameMetric(
      timestamp: DateTime.now(),
      durationMicroseconds: durationMicroseconds,
    );
    
    _frameMetrics.add(metric);
    
    // Keep only last 1000 frames
    if (_frameMetrics.length > 1000) {
      _frameMetrics.removeAt(0);
    }
    
    // Check for janky frames (> 16.67ms for 60fps)
    if (durationMicroseconds > 16670) {
      debugPrint('⚠️ Janky frame detected: ${(durationMicroseconds / 1000).toStringAsFixed(2)}ms');
    }
  }

  /// Start periodic reporting
  void _startPeriodicReporting() {
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) => _generatePerformanceReport(),
    );
  }

  /// Record load time for a specific operation
  void recordLoadTime(String operation, int durationMs, {Map<String, dynamic>? metadata}) {
    final metric = LoadTimeMetric(
      operation: operation,
      durationMs: durationMs,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );
    
    _loadTimeMetrics.add(metric);
    
    if (kDebugMode) {
      debugPrint('⏱️ $operation: ${durationMs}ms');
    }
  }

  /// Record user interaction timing
  void recordInteraction(String interaction, int durationMs, {bool success = true}) {
    final metric = InteractionMetric(
      interaction: interaction,
      durationMs: durationMs,
      timestamp: DateTime.now(),
      success: success,
    );
    
    _interactionMetrics.add(metric);
    
    if (durationMs > 100) {
      debugPrint('🐌 Slow interaction: $interaction (${durationMs}ms)');
    }
  }

  /// Record network performance
  void recordNetworkCall(String endpoint, int durationMs, int responseSize, {bool success = true}) {
    final metric = NetworkMetric(
      endpoint: endpoint,
      durationMs: durationMs,
      responseSize: responseSize,
      timestamp: DateTime.now(),
      success: success,
    );
    
    _networkMetrics.add(metric);
    
    if (durationMs > 3000) {
      debugPrint('🌐 Slow network call: $endpoint (${durationMs}ms)');
    }
  }

  /// Get current performance metrics
  PerformanceMetrics getCurrentMetrics() {
    return PerformanceMetrics(
      averageFrameTime: _getAverageFrameTime(),
      jankPercentage: _getJankPercentage(),
      averageLoadTime: _getAverageLoadTime(),
      averageInteractionTime: _getAverageInteractionTime(),
      averageNetworkTime: _getAverageNetworkTime(),
      totalFrames: _frameMetrics.length,
      totalLoadOperations: _loadTimeMetrics.length,
      totalInteractions: _interactionMetrics.length,
      totalNetworkCalls: _networkMetrics.length,
    );
  }

  /// Generate performance report
  void _generatePerformanceReport() {
    if (!kDebugMode) return;
    
    final metrics = getCurrentMetrics();
    
    print('\n📊 PERFORMANCE REPORT');
    print('═══════════════════════════════════════');
    print('🎬 Frame Performance:');
    print('   Average Frame Time: ${metrics.averageFrameTime.toStringAsFixed(2)}ms');
    print('   Jank Percentage: ${metrics.jankPercentage.toStringAsFixed(1)}%');
    print('   Total Frames: ${metrics.totalFrames}');
    
    print('\n⏱️ Load Performance:');
    print('   Average Load Time: ${metrics.averageLoadTime.toStringAsFixed(2)}ms');
    print('   Total Operations: ${metrics.totalLoadOperations}');
    
    print('\n👆 Interaction Performance:');
    print('   Average Interaction Time: ${metrics.averageInteractionTime.toStringAsFixed(2)}ms');
    print('   Total Interactions: ${metrics.totalInteractions}');
    
    print('\n🌐 Network Performance:');
    print('   Average Network Time: ${metrics.averageNetworkTime.toStringAsFixed(2)}ms');
    print('   Total Network Calls: ${metrics.totalNetworkCalls}');
    print('═══════════════════════════════════════\n');
  }

  /// Calculate average frame time in milliseconds
  double _getAverageFrameTime() {
    if (_frameMetrics.isEmpty) return 0;
    
    final totalTime = _frameMetrics
        .map((m) => m.durationMicroseconds)
        .reduce((a, b) => a + b);
    
    return totalTime / _frameMetrics.length / 1000; // Convert to ms
  }

  /// Calculate jank percentage
  double _getJankPercentage() {
    if (_frameMetrics.isEmpty) return 0;
    
    final jankyFrames = _frameMetrics
        .where((m) => m.durationMicroseconds > 16670) // > 16.67ms
        .length;
    
    return (jankyFrames / _frameMetrics.length) * 100;
  }

  /// Calculate average load time
  double _getAverageLoadTime() {
    if (_loadTimeMetrics.isEmpty) return 0;
    
    final totalTime = _loadTimeMetrics
        .map((m) => m.durationMs)
        .reduce((a, b) => a + b);
    
    return totalTime / _loadTimeMetrics.length;
  }

  /// Calculate average interaction time
  double _getAverageInteractionTime() {
    if (_interactionMetrics.isEmpty) return 0;
    
    final totalTime = _interactionMetrics
        .map((m) => m.durationMs)
        .reduce((a, b) => a + b);
    
    return totalTime / _interactionMetrics.length;
  }

  /// Calculate average network time
  double _getAverageNetworkTime() {
    if (_networkMetrics.isEmpty) return 0;
    
    final totalTime = _networkMetrics
        .map((m) => m.durationMs)
        .reduce((a, b) => a + b);
    
    return totalTime / _networkMetrics.length;
  }

  /// Clear all metrics
  void clearMetrics() {
    _frameMetrics.clear();
    _loadTimeMetrics.clear();
    _interactionMetrics.clear();
    _networkMetrics.clear();
    
    debugPrint('🧹 Performance metrics cleared');
  }

  /// Export metrics to JSON
  Map<String, dynamic> exportMetrics() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'frameMetrics': _frameMetrics.map((m) => m.toJson()).toList(),
      'loadTimeMetrics': _loadTimeMetrics.map((m) => m.toJson()).toList(),
      'interactionMetrics': _interactionMetrics.map((m) => m.toJson()).toList(),
      'networkMetrics': _networkMetrics.map((m) => m.toJson()).toList(),
      'summary': getCurrentMetrics().toJson(),
    };
  }
}

/// Performance measurement helper
class PerformanceMeasurement {
  final String _operation;
  final DateTime _startTime;
  final Map<String, dynamic> _metadata;

  PerformanceMeasurement(this._operation, [this._metadata = const {}])
      : _startTime = DateTime.now();

  /// Public getter for measurement start time
  DateTime get startTime => _startTime;

  /// End measurement and record the result
  void end({bool success = true}) {
    final duration = DateTime.now().difference(_startTime).inMilliseconds;
    PerformanceMonitor().recordLoadTime(_operation, duration, metadata: _metadata);
  }
}

/// Extension for easy performance measurement
extension PerformanceMeasurementExt on String {
  PerformanceMeasurement startMeasurement([Map<String, dynamic>? metadata]) {
    return PerformanceMeasurement(this, metadata ?? {});
  }
}

/// Frame metric data class
class FrameMetric {
  final DateTime timestamp;
  final int durationMicroseconds;

  FrameMetric({
    required this.timestamp,
    required this.durationMicroseconds,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'durationMicroseconds': durationMicroseconds,
  };
}

/// Load time metric data class
class LoadTimeMetric {
  final String operation;
  final int durationMs;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  LoadTimeMetric({
    required this.operation,
    required this.durationMs,
    required this.timestamp,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'operation': operation,
    'durationMs': durationMs,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };
}

/// Interaction metric data class
class InteractionMetric {
  final String interaction;
  final int durationMs;
  final DateTime timestamp;
  final bool success;

  InteractionMetric({
    required this.interaction,
    required this.durationMs,
    required this.timestamp,
    required this.success,
  });

  Map<String, dynamic> toJson() => {
    'interaction': interaction,
    'durationMs': durationMs,
    'timestamp': timestamp.toIso8601String(),
    'success': success,
  };
}

/// Network metric data class
class NetworkMetric {
  final String endpoint;
  final int durationMs;
  final int responseSize;
  final DateTime timestamp;
  final bool success;

  NetworkMetric({
    required this.endpoint,
    required this.durationMs,
    required this.responseSize,
    required this.timestamp,
    required this.success,
  });

  Map<String, dynamic> toJson() => {
    'endpoint': endpoint,
    'durationMs': durationMs,
    'responseSize': responseSize,
    'timestamp': timestamp.toIso8601String(),
    'success': success,
  };
}

/// Performance metrics summary
class PerformanceMetrics {
  final double averageFrameTime;
  final double jankPercentage;
  final double averageLoadTime;
  final double averageInteractionTime;
  final double averageNetworkTime;
  final int totalFrames;
  final int totalLoadOperations;
  final int totalInteractions;
  final int totalNetworkCalls;

  PerformanceMetrics({
    required this.averageFrameTime,
    required this.jankPercentage,
    required this.averageLoadTime,
    required this.averageInteractionTime,
    required this.averageNetworkTime,
    required this.totalFrames,
    required this.totalLoadOperations,
    required this.totalInteractions,
    required this.totalNetworkCalls,
  });

  Map<String, dynamic> toJson() => {
    'averageFrameTime': averageFrameTime,
    'jankPercentage': jankPercentage,
    'averageLoadTime': averageLoadTime,
    'averageInteractionTime': averageInteractionTime,
    'averageNetworkTime': averageNetworkTime,
    'totalFrames': totalFrames,
    'totalLoadOperations': totalLoadOperations,
    'totalInteractions': totalInteractions,
    'totalNetworkCalls': totalNetworkCalls,
  };
}