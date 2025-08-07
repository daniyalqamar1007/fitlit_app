import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../services/optimized_upload_service.dart';
import '../utils/performance_monitoring.dart';

/// 🚀 Optimized Upload Widget
/// Provides ultra-fast cloth uploading with:
/// - Real-time progress tracking
/// - Background image compression
/// - Smart quality selection
/// - Visual feedback and metrics

class OptimizedUploadWidget extends StatefulWidget {
  final String category;
  final String subCategory;
  final String token;
  final Function(UploadResult)? onUploadComplete;
  final Function(String)? onError;

  const OptimizedUploadWidget({
    super.key,
    required this.category,
    required this.subCategory,
    required this.token,
    this.onUploadComplete,
    this.onError,
  });

  @override
  State<OptimizedUploadWidget> createState() => _OptimizedUploadWidgetState();
}

class _OptimizedUploadWidgetState extends State<OptimizedUploadWidget>
    with TickerProviderStateMixin {
  final OptimizedUploadService _uploadService = OptimizedUploadService();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  UploadQuality _selectedQuality = UploadQuality.balanced;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _currentStatus = '';
  UploadResult? _lastResult;

  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 20.h),
          _buildImageSelection(),
          if (_selectedImage != null) ...[
            SizedBox(height: 16.h),
            _buildQualitySelection(),
            SizedBox(height: 16.h),
            _buildImagePreview(),
            SizedBox(height: 20.h),
            _buildUploadSection(),
          ],
          if (_lastResult != null) ...[
            SizedBox(height: 16.h),
            _buildResultSummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.cloud_upload_outlined,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ultra-Fast Upload',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '${widget.category} • ${widget.subCategory}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (_isUploading)
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 8.w,
              height: 8.h,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageSelection() {
    return GestureDetector(
      onTap: _isUploading ? null : _selectImage,
      child: Container(
        width: double.infinity,
        height: 120.h,
        decoration: BoxDecoration(
          color: _selectedImage != null ? Colors.green[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: _selectedImage != null ? Colors.green : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: _selectedImage != null
            ? Row(
                children: [
                  Container(
                    width: 80.w,
                    height: 80.h,
                    margin: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      image: DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Image Selected',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        FutureBuilder<int>(
                          future: _selectedImage!.length(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final sizeKB = snapshot.data! ~/ 1024;
                              return Text(
                                '${sizeKB}KB • Ready to optimize',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isUploading ? null : () => setState(() => _selectedImage = null),
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                      size: 20.sp,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Tap to select image',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Automatic compression & optimization',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildQualitySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Quality',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: UploadQuality.values.map((quality) {
            final isSelected = _selectedQuality == quality;
            return Expanded(
              child: GestureDetector(
                onTap: _isUploading ? null : () => setState(() => _selectedQuality = quality),
                child: Container(
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[600] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getQualityLabel(quality),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _getQualityDescription(quality),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isSelected ? Colors.white70 : Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        image: DecorationImage(
          image: FileImage(_selectedImage!),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.3),
            ],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Text(
              'Will be optimized to ${_getQualitySize(_selectedQuality)}',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      children: [
        if (_isUploading) ...[
          _buildProgressIndicator(),
          SizedBox(height: 16.h),
        ],
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: _isUploading ? null : _startUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isUploading ? Colors.grey[400] : Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: _isUploading ? 0 : 4,
            ),
            child: _isUploading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        _currentStatus,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rocket_launch, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Upload with Optimization',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _currentStatus,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${(_uploadProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            minHeight: 8.h,
          ),
        ),
      ],
    );
  }

  Widget _buildResultSummary() {
    if (_lastResult == null) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _lastResult!.success ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _lastResult!.success ? Colors.green[200]! : Colors.red[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _lastResult!.success ? Icons.check_circle : Icons.error,
                color: _lastResult!.success ? Colors.green[600] : Colors.red[600],
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                _lastResult!.success ? 'Upload Successful!' : 'Upload Failed',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: _lastResult!.success ? Colors.green[700] : Colors.red[700],
                ),
              ),
            ],
          ),
          if (_lastResult!.success) ...[
            SizedBox(height: 8.h),
            Text(
              _lastResult!.compressionSummary,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.green[600],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Uploaded in ${_lastResult!.uploadTime.millisecondsSinceEpoch}ms',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ] else if (_lastResult!.error != null) ...[
            SizedBox(height: 8.h),
            Text(
              _lastResult!.error!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.red[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _lastResult = null; // Clear previous result
        });
      }
    } catch (e) {
      widget.onError?.call('Failed to select image: $e');
    }
  }

  Future<void> _startUpload() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _currentStatus = 'Preparing upload...';
    });

    final measurement = 'UI_ClothUpload'.startMeasurement();

    try {
      final result = await _uploadService.uploadClothOptimized(
        imageFile: _selectedImage!,
        category: widget.category,
        subCategory: widget.subCategory,
        token: widget.token,
        quality: _selectedQuality,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
            _currentStatus = _getStatusForProgress(progress);
          });
          _progressController.animateTo(progress);
        },
      );

      measurement.end();

      setState(() {
        _isUploading = false;
        _lastResult = result;
        _uploadProgress = 1.0;
        _currentStatus = result.success ? 'Upload completed!' : 'Upload failed';
      });

      if (result.success) {
        widget.onUploadComplete?.call(result);
      } else {
        widget.onError?.call(result.error ?? 'Upload failed');
      }
    } catch (e) {
      measurement.end();
      setState(() {
        _isUploading = false;
        _currentStatus = 'Upload failed';
      });
      widget.onError?.call('Upload error: $e');
    }
  }

  String _getQualityLabel(UploadQuality quality) {
    switch (quality) {
      case UploadQuality.fast:
        return 'FAST';
      case UploadQuality.balanced:
        return 'BALANCED';
      case UploadQuality.high:
        return 'HIGH';
    }
  }

  String _getQualityDescription(UploadQuality quality) {
    switch (quality) {
      case UploadQuality.fast:
        return '512px\nWebP\n<2s';
      case UploadQuality.balanced:
        return '800px\nJPEG\n<5s';
      case UploadQuality.high:
        return '1200px\nJPEG\n<10s';
    }
  }

  String _getQualitySize(UploadQuality quality) {
    switch (quality) {
      case UploadQuality.fast:
        return '512x512px';
      case UploadQuality.balanced:
        return '800x800px';
      case UploadQuality.high:
        return '1200x1200px';
    }
  }

  String _getStatusForProgress(double progress) {
    if (progress < 0.1) return 'Preparing upload...';
    if (progress < 0.3) return 'Optimizing image...';
    if (progress < 0.95) return 'Uploading...';
    return 'Finalizing...';
  }
}