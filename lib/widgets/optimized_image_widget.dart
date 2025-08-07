import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/image_optimization.dart';

/// 🖼️ Optimized Image Widget
/// Replaces standard Image widgets with performance-optimized versions
class OptimizedImageWidget extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final String useCase;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? semanticLabel;
  final bool enableMemoryCache;
  final bool enableDiskCache;

  const OptimizedImageWidget({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.width,
    this.height,
    this.fit,
    this.useCase = 'preview',
    this.placeholder,
    this.errorWidget,
    this.semanticLabel,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
  }) : assert(imageUrl != null || assetPath != null, 'Either imageUrl or assetPath must be provided');

  @override
  Widget build(BuildContext context) {
    // Asset images
    if (assetPath != null) {
      return ImageOptimization.buildOptimizedAssetImage(
        assetPath: assetPath!,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: semanticLabel,
      );
    }

    // Network images
    if (imageUrl != null) {
      return ImageOptimization.buildProgressiveImage(
        imageUrl: imageUrl!,
        useCase: useCase,
        context: context,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    }

    return Container();
  }
}

/// 🔄 Lazy Loading Image Widget
/// Loads images only when they come into view
class LazyImageWidget extends StatefulWidget {
  final String? imageUrl;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final String useCase;
  final Widget? placeholder;
  final Widget? errorWidget;

  const LazyImageWidget({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.width,
    this.height,
    this.fit,
    this.useCase = 'preview',
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<LazyImageWidget> createState() => _LazyImageWidgetState();
}

class _LazyImageWidgetState extends State<LazyImageWidget> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.imageUrl ?? widget.assetPath ?? 'lazy_image'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0.1 && !_isVisible) {
          setState(() {
            _isVisible = true;
          });
        }
      },
      child: _isVisible
          ? OptimizedImageWidget(
              imageUrl: widget.imageUrl,
              assetPath: widget.assetPath,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              useCase: widget.useCase,
              placeholder: widget.placeholder,
              errorWidget: widget.errorWidget,
            )
          : Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[200],
              child: widget.placeholder ??
                  Center(
                    child: Icon(
                      Icons.image,
                      size: (widget.width ?? 50) * 0.3,
                      color: Colors.grey[400],
                    ),
                  ),
            ),
    );
  }
}

/// 📋 Optimized List Image Widget
/// Specifically optimized for list items with memory management
class ListImageWidget extends StatelessWidget {
  final String imageUrl;
  final double itemWidth;
  final double itemHeight;
  final BoxFit? fit;
  final String? placeholder;

  const ListImageWidget({
    super.key,
    required this.imageUrl,
    required this.itemWidth,
    required this.itemHeight,
    this.fit,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return ImageOptimization.buildListOptimizedImage(
      imageUrl: imageUrl,
      itemWidth: itemWidth,
      itemHeight: itemHeight,
      fit: fit,
    );
  }
}

/// 🎯 Avatar Image Widget
/// Specialized widget for avatar images with fallbacks
class AvatarImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? fallbackAsset;
  final Color? backgroundColor;
  final String? initials;

  const AvatarImageWidget({
    super.key,
    this.imageUrl,
    required this.size,
    this.fallbackAsset,
    this.backgroundColor,
    this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: imageUrl != null
            ? OptimizedImageWidget(
                imageUrl: imageUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                useCase: 'avatar_preview',
                errorWidget: _buildFallback(),
              )
            : _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    if (fallbackAsset != null) {
      return OptimizedImageWidget(
        assetPath: fallbackAsset,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    if (initials != null) {
      return Center(
        child: Text(
          initials!,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return Icon(
      Icons.person,
      size: size * 0.6,
      color: Colors.grey[600],
    );
  }
}

// Add visibility detector dependency if not present
import 'package:visibility_detector/visibility_detector.dart';