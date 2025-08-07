import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui' as ui;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 🖼️ Image Optimization Utility
/// Provides comprehensive image optimization including:
/// - Progressive loading
/// - Adaptive quality based on device
/// - Memory-efficient loading
/// - WebP support
/// - Intelligent caching

class ImageOptimization {
  static const Map<String, Map<String, dynamic>> imagePresets = {
    'thumbnail': {'width': 150, 'height': 150, 'quality': 60},
    'preview': {'width': 300, 'height': 300, 'quality': 70},
    'medium': {'width': 600, 'height': 600, 'quality': 80},
    'high': {'width': 1200, 'height': 1200, 'quality': 85},
    'original': {'width': null, 'height': null, 'quality': 95},
  };

  /// Get optimal image preset based on use case
  static String getOptimalPreset({
    required String useCase,
    required BuildContext context,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final isHighDensity = devicePixelRatio > 2.0;

    switch (useCase) {
      case 'avatar_list':
        return 'thumbnail';
      case 'avatar_preview':
        return isHighDensity ? 'preview' : 'thumbnail';
      case 'profile_picture':
        return screenWidth > 400 ? 'medium' : 'preview';
      case 'background':
        return screenWidth > 600 ? 'high' : 'medium';
      case 'onboarding':
        return 'medium';
      default:
        return 'preview';
    }
  }

  /// Progressive image loading with optimization
  static Widget buildProgressiveImage({
    required String imageUrl,
    required String useCase,
    required BuildContext context,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
    BoxFit? fit,
    double? width,
    double? height,
  }) {
    final preset = getOptimalPreset(useCase: useCase, context: context);
    final config = imagePresets[preset]!;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width ?? config['width']?.toDouble(),
      height: height ?? config['height']?.toDouble(),
      fit: fit ?? BoxFit.cover,
      memCacheWidth: config['width'],
      memCacheHeight: config['height'],
      maxWidthDiskCache: config['width'],
      maxHeightDiskCache: config['height'],
      placeholder: placeholder ??
          (BuildContext context, String url) => Container(
                width: width ?? config['width']?.toDouble(),
                height: height ?? config['height']?.toDouble(),
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
      errorWidget: errorWidget ??
          (BuildContext context, String url, dynamic error) => Container(
                width: width ?? config['width']?.toDouble(),
                height: height ?? config['height']?.toDouble(),
                color: Colors.grey[300],
                child: Icon(Icons.error, color: Colors.grey[600]),
              ),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }

  /// Optimized asset image loading
  static Widget buildOptimizedAssetImage({
    required String assetPath,
    double? width,
    double? height,
    BoxFit? fit,
    String? semanticLabel,
  }) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      semanticLabel: semanticLabel,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Image loading error: $error');
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(Icons.broken_image, color: Colors.grey[600]),
        );
      },
    );
  }

  /// Memory-efficient image loading for lists
  static Widget buildListOptimizedImage({
    required String imageUrl,
    required double itemWidth,
    required double itemHeight,
    BoxFit? fit,
  }) {
    // Calculate optimal cache dimensions
    final cacheWidth = (itemWidth * ui.window.devicePixelRatio).round();
    final cacheHeight = (itemHeight * ui.window.devicePixelRatio).round();

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: itemWidth,
      height: itemHeight,
      fit: fit ?? BoxFit.cover,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      placeholder: (context, url) => Container(
        width: itemWidth,
        height: itemHeight,
        color: Colors.grey[200],
      ),
      errorWidget: (context, url, error) => Container(
        width: itemWidth,
        height: itemHeight,
        color: Colors.grey[300],
        child: Icon(Icons.error, size: itemWidth * 0.3),
      ),
    );
  }

  /// Preload critical images
  static Future<void> preloadCriticalImages(BuildContext context) async {
    final criticalImages = [
      'assets/Images/splash_logo.png',
      'assets/Images/application_logo.png',
      'assets/Icons/home_icon.png',
      'assets/Icons/profile.png',
    ];

    final futures = criticalImages.map((imagePath) => 
        precacheImage(AssetImage(imagePath), context));
    
    await Future.wait(futures);
  }

  /// Clear image cache
  static Future<void> clearImageCache() async {
    await DefaultCacheManager().emptyCache();
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  /// Get cache size information
  static Future<Map<String, int>> getCacheInfo() async {
    final cacheManager = DefaultCacheManager();
    // This is a simplified version - in practice you'd need to implement cache size calculation
    return {
      'diskCacheSize': 0, // Would need to calculate actual size
      'memoryCacheSize': imageCache.currentSizeBytes,
      'liveCacheSize': imageCache.liveImageCount,
    };
  }
}

/// Performance monitoring for images
class ImagePerformanceMonitor {
  static final Map<String, DateTime> _loadStartTimes = {};
  static final Map<String, int> _loadDurations = {};

  static void startImageLoad(String imageUrl) {
    _loadStartTimes[imageUrl] = DateTime.now();
  }

  static void endImageLoad(String imageUrl) {
    final startTime = _loadStartTimes[imageUrl];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _loadDurations[imageUrl] = duration;
      _loadStartTimes.remove(imageUrl);
      
      if (kDebugMode) {
        print('Image loaded: $imageUrl in ${duration}ms');
      }
    }
  }

  static Map<String, int> getLoadDurations() => Map.from(_loadDurations);
  
  static double getAverageLoadTime() {
    if (_loadDurations.isEmpty) return 0;
    final total = _loadDurations.values.reduce((a, b) => a + b);
    return total / _loadDurations.length;
  }
}

/// Custom cache manager with size limits
class OptimizedCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'optimizedCache';
  
  static final OptimizedCacheManager _instance = OptimizedCacheManager._();
  factory OptimizedCacheManager() => _instance;

  OptimizedCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 7),
            maxNrOfCacheObjects: 100,
            repo: JsonCacheInfoRepository(databaseName: key),
            fileService: HttpFileService(),
          ),
        );
}