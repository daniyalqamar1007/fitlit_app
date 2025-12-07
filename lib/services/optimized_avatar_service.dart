import 'dart:convert';
import 'dart:math';

/// 🎯 Optimized Ready Player Me Avatar Service
/// Balances quality and performance using Avatar API parameters
/// Reduces download size and memory usage while maintaining visual quality
class OptimizedAvatarService {
  static const String baseApiUrl = 'https://api.readyplayer.me/v1/avatars';
  static const String subdomain = 'fitlit-m9mpgi';

  /// 🎨 Avatar Quality Presets for different use cases
  static const Map<String, Map<String, dynamic>> qualityPresets = {
    'ultra_high': {
      'meshLod': 0,        // Full resolution
      'textureAtlas': null, // Original textures
      'morphTargets': null, // All morph targets
      'pose': 'A',
      'description': 'Maximum quality - Use for close-ups and hero shots',
      'polygonReduction': '0%',
      'fileSize': 'Large (~2-5MB)',
      'loadTime': 'Slower',
      'memoryUsage': 'High',
      'useCase': 'Profile pictures, detailed views'
    },
    'high': {
      'meshLod': 1,        // Slight reduction
      'textureAtlas': '1024', // High quality textures
      'morphTargets': 'ARKit,Oculus', // Essential morph targets
      'pose': 'A',
      'description': 'High quality - Great balance for most use cases',
      'polygonReduction': '25%',
      'fileSize': 'Medium (~1-2MB)',
      'loadTime': 'Fast',
      'memoryUsage': 'Medium',
      'useCase': 'Main app avatars, social features'
    },
    'medium': {
      'meshLod': 2,        // 50% polygon reduction
      'textureAtlas': '512', // Medium quality textures
      'morphTargets': 'ARKit', // Basic morph targets
      'pose': 'A',
      'description': 'Balanced quality - Optimized for mobile devices',
      'polygonReduction': '50%',
      'fileSize': 'Small (~500KB-1MB)',
      'loadTime': 'Very Fast',
      'memoryUsage': 'Low',
      'useCase': 'Mobile apps, list views, thumbnails'
    },
    'low': {
      'meshLod': 3,        // Maximum reduction
      'textureAtlas': '256', // Compressed textures
      'morphTargets': null, // No morph targets
      'pose': 'A',
      'description': 'Performance optimized - For low-end devices',
      'polygonReduction': '75%',
      'fileSize': 'Very Small (~200-500KB)',
      'loadTime': 'Instant',
      'memoryUsage': 'Minimal',
      'useCase': 'Background avatars, low-end devices'
    },
    'fitness_optimized': {
      'meshLod': 2,        // Balanced for fitness poses
      'textureAtlas': '512',
      'morphTargets': 'ARKit',
      'pose': 'T',         // T-pose for workout positions
      'description': 'Fitness app optimized - Balanced for workout scenarios',
      'polygonReduction': '50%',
      'fileSize': 'Small (~500KB-1MB)',
      'loadTime': 'Very Fast',
      'memoryUsage': 'Low',
      'useCase': 'Workout screens, exercise demonstrations'
    }
  };

  /// 🚀 Generate optimized avatar URL with quality preset
  static String generateOptimizedAvatarUrl({
    required String avatarId,
    String qualityPreset = 'high',
    Map<String, dynamic>? customParams,
  }) {
    final preset = qualityPresets[qualityPreset] ?? qualityPresets['high']!;
    final params = <String, String>{};

    // Apply preset parameters
    if (preset['meshLod'] != null) {
      params['meshLod'] = preset['meshLod'].toString();
    }
    
    if (preset['textureAtlas'] != null) {
      params['textureAtlas'] = preset['textureAtlas'].toString();
    }
    
    if (preset['morphTargets'] != null) {
      params['morphTargets'] = preset['morphTargets'];
    }
    
    if (preset['pose'] != null) {
      params['pose'] = preset['pose'];
    }

    // Apply custom parameters (override preset)
    if (customParams != null) {
      customParams.forEach((key, value) {
        if (value != null) {
          params[key] = value.toString();
        }
      });
    }

    // Build URL with parameters
    final baseUrl = '$baseApiUrl/$avatarId.glb';
    if (params.isEmpty) return baseUrl;

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$baseUrl?$queryString';
  }

  /// 📱 Device-specific optimization
  static String generateDeviceOptimizedUrl({
    required String avatarId,
    String deviceType = 'mobile', // 'mobile', 'tablet', 'desktop'
    String connectionSpeed = 'fast', // 'slow', 'medium', 'fast'
    bool isLowEndDevice = false,
  }) {
    String qualityPreset;

    // Determine optimal preset based on device and connection
    if (isLowEndDevice || connectionSpeed == 'slow') {
      qualityPreset = 'low';
    } else if (deviceType == 'mobile' && connectionSpeed == 'medium') {
      qualityPreset = 'medium';
    } else if (deviceType == 'tablet' || connectionSpeed == 'fast') {
      qualityPreset = 'high';
    } else {
      qualityPreset = 'ultra_high';
    }

    return generateOptimizedAvatarUrl(
      avatarId: avatarId,
      qualityPreset: qualityPreset,
    );
  }

  /// 🎮 Use-case specific optimization
  static String generateUseCaseOptimizedUrl({
    required String avatarId,
    required String useCase, // 'profile', 'list', 'workout', 'social', 'hero'
  }) {
    String qualityPreset;

    switch (useCase) {
      case 'profile':
      case 'hero':
        qualityPreset = 'ultra_high';
        break;
      case 'social':
        qualityPreset = 'high';
        break;
      case 'workout':
      case 'fitness':
        qualityPreset = 'fitness_optimized';
        break;
      case 'list':
      case 'thumbnail':
        qualityPreset = 'medium';
        break;
      case 'background':
        qualityPreset = 'low';
        break;
      default:
        qualityPreset = 'high';
    }

    return generateOptimizedAvatarUrl(
      avatarId: avatarId,
      qualityPreset: qualityPreset,
    );
  }

  /// 🎨 Custom optimization builder
  static String buildCustomOptimizedUrl({
    required String avatarId,
    int? meshLod,           // 0-3 (0=highest quality, 3=lowest)
    String? textureAtlas,   // '2048', '1024', '512', '256'
    String? morphTargets,   // 'ARKit', 'Oculus', 'ARKit,Oculus'
    String? pose,           // 'A', 'T', 'relaxed'
    bool? includeHair,
    bool? includeClothes,
    String? background,     // 'transparent', 'studio'
    String? format,         // 'glb', 'gltf'
  }) {
    final customParams = <String, dynamic>{
      if (meshLod != null) 'meshLod': meshLod,
      if (textureAtlas != null) 'textureAtlas': textureAtlas,
      if (morphTargets != null) 'morphTargets': morphTargets,
      if (pose != null) 'pose': pose,
      if (includeHair != null) 'includeHair': includeHair,
      if (includeClothes != null) 'includeClothes': includeClothes,
      if (background != null) 'background': background,
      if (format != null) 'format': format,
    };

    return generateOptimizedAvatarUrl(
      avatarId: avatarId,
      qualityPreset: 'high', // Base preset
      customParams: customParams,
    );
  }

  /// 📊 Get performance metrics for a quality preset
  static Map<String, String> getPresetMetrics(String qualityPreset) {
    final preset = qualityPresets[qualityPreset];
    if (preset == null) return {};

    return {
      'polygonReduction': preset['polygonReduction'] ?? 'Unknown',
      'fileSize': preset['fileSize'] ?? 'Unknown',
      'loadTime': preset['loadTime'] ?? 'Unknown',
      'memoryUsage': preset['memoryUsage'] ?? 'Unknown',
      'useCase': preset['useCase'] ?? 'Unknown',
      'description': preset['description'] ?? 'Unknown',
    };
  }

  /// 🎯 Adaptive quality selection based on network conditions
  static String getAdaptiveQualityUrl({
    required String avatarId,
    double? networkSpeedMbps,
    int? deviceRAMGB,
    bool? isOnWifi,
  }) {
    String qualityPreset = 'medium'; // Default fallback

    // Network-based optimization
    if (networkSpeedMbps != null) {
      if (networkSpeedMbps > 10 && (isOnWifi ?? false)) {
        qualityPreset = 'ultra_high';
      } else if (networkSpeedMbps > 5) {
        qualityPreset = 'high';
      } else if (networkSpeedMbps > 2) {
        qualityPreset = 'medium';
      } else {
        qualityPreset = 'low';
      }
    }

    // Device RAM consideration
    if (deviceRAMGB != null && deviceRAMGB < 4) {
      // Force lower quality on low-RAM devices
      if (qualityPreset == 'ultra_high') qualityPreset = 'high';
      if (qualityPreset == 'high') qualityPreset = 'medium';
    }

    return generateOptimizedAvatarUrl(
      avatarId: avatarId,
      qualityPreset: qualityPreset,
    );
  }

  /// 📱 Progressive loading URLs (load low quality first, then high quality)
  static List<String> getProgressiveLoadingUrls({
    required String avatarId,
    String finalQuality = 'high',
  }) {
    return [
      generateOptimizedAvatarUrl(avatarId: avatarId, qualityPreset: 'low'),
      generateOptimizedAvatarUrl(avatarId: avatarId, qualityPreset: 'medium'),
      generateOptimizedAvatarUrl(avatarId: avatarId, qualityPreset: finalQuality),
    ];
  }

  /// 🔍 Avatar URL analysis and optimization suggestions
  static Map<String, dynamic> analyzeAvatarUrl(String avatarUrl) {
    final uri = Uri.parse(avatarUrl);
    final params = uri.queryParameters;
    
    String currentQuality = 'custom';
    String? meshLod = params['meshLod'];
    String? textureAtlas = params['textureAtlas'];
    
    // Try to determine quality preset
    for (final entry in qualityPresets.entries) {
      final preset = entry.value;
      if (preset['meshLod']?.toString() == meshLod &&
          preset['textureAtlas']?.toString() == textureAtlas) {
        currentQuality = entry.key;
        break;
      }
    }
    
    // Generate optimization suggestions
    final suggestions = <String>[];
    
    if (meshLod == null || int.tryParse(meshLod) == 0) {
      suggestions.add('Consider using meshLod=2 for 50% smaller file size');
    }
    
    if (textureAtlas == null || int.tryParse(textureAtlas) == 2048) {
      suggestions.add('Use textureAtlas=1024 for faster loading');
    }
    
    if (!params.containsKey('morphTargets')) {
      suggestions.add('Add morphTargets=ARKit for facial animations');
    }

    return {
      'currentQuality': currentQuality,
      'parameters': params,
      'suggestions': suggestions,
      'estimatedFileSize': _estimateFileSize(params),
      'estimatedLoadTime': _estimateLoadTime(params),
    };
  }

  /// 📊 Estimate file size based on parameters
  static String _estimateFileSize(Map<String, String> params) {
    int baseSize = 2000; // KB
    
    // Apply reductions based on parameters
    if (params['meshLod'] != null) {
      int lod = int.tryParse(params['meshLod'] ?? '0') ?? 0;
      baseSize = (baseSize * pow(0.6, lod)).round();
    }
    
    if (params['textureAtlas'] != null) {
      int textureSize = int.tryParse(params['textureAtlas'] ?? '2048') ?? 2048;
      double reduction = textureSize / 2048;
      baseSize = (baseSize * reduction).round();
    }

    if (baseSize > 1024) {
      return '${(baseSize / 1024).toStringAsFixed(1)}MB';
    } else {
      return '${baseSize}KB';
    }
  }

  /// ⏱️ Estimate load time based on parameters  
  static String _estimateLoadTime(Map<String, String> params) {
    int baseTime = 5; // seconds
    
    if (params['meshLod'] != null) {
      int lod = int.tryParse(params['meshLod'] ?? '0') ?? 0;
      baseTime = (baseTime * pow(0.7, lod)).round();
    }
    
    if (params['textureAtlas'] != null) {
      int textureSize = int.tryParse(params['textureAtlas'] ?? '2048') ?? 2048;
      double factor = textureSize / 2048;
      baseTime = (baseTime * factor).round();
    }

    if (baseTime < 1) {
      return '< 1 second';
    } else {
      return '$baseTime seconds';
    }
  }

  /// 📋 Get all available quality presets
  static List<String> getAvailablePresets() {
    return qualityPresets.keys.toList();
  }

  /// 📊 Performance comparison between presets
  static Map<String, Map<String, String>> getPresetComparison() {
    final comparison = <String, Map<String, String>>{};
    
    for (final entry in qualityPresets.entries) {
      comparison[entry.key] = getPresetMetrics(entry.key);
    }
    
    return comparison;
  }
}

/// 🎯 Avatar optimization result model
class AvatarOptimizationResult {
  final String optimizedUrl;
  final String qualityPreset;
  final Map<String, String> metrics;
  final List<String> optimizations;

  AvatarOptimizationResult({
    required this.optimizedUrl,
    required this.qualityPreset,
    required this.metrics,
    required this.optimizations,
  });

  factory AvatarOptimizationResult.fromUrl({
    required String avatarId,
    required String qualityPreset,
  }) {
    final optimizedUrl = OptimizedAvatarService.generateOptimizedAvatarUrl(
      avatarId: avatarId,
      qualityPreset: qualityPreset,
    );
    
    final metrics = OptimizedAvatarService.getPresetMetrics(qualityPreset);
    
    final optimizations = <String>[
      'Applied $qualityPreset quality preset',
      'Optimized for ${metrics['useCase']}',
      'Reduced file size: ${metrics['fileSize']}',
      'Improved load time: ${metrics['loadTime']}',
    ];

    return AvatarOptimizationResult(
      optimizedUrl: optimizedUrl,
      qualityPreset: qualityPreset,
      metrics: metrics,
      optimizations: optimizations,
    );
  }
}

