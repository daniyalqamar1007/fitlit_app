import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/optimized_avatar_service.dart';
import '../../controllers/fast_avatar_controller.dart';

/// 🎯 Avatar Optimization Demo
/// Shows different quality presets and their performance impact
class AvatarOptimizationDemo extends StatefulWidget {
  const AvatarOptimizationDemo({Key? key}) : super(key: key);

  @override
  State<AvatarOptimizationDemo> createState() => _AvatarOptimizationDemoState();
}

class _AvatarOptimizationDemoState extends State<AvatarOptimizationDemo> {
  final FastAvatarController _controller = FastAvatarController();
  String _selectedPreset = 'high';
  String _selectedUseCase = 'social';
  String? _demoAvatarId = '6185a4acfb622cf1cdc49348'; // Demo avatar ID
  final Map<String, Stopwatch> _loadTimers = {};
  final Map<String, bool> _loadSuccess = {};

  @override
  void initState() {
    super.initState();
    _generateTestUrls();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('🎯 Avatar Optimization Demo'),
        backgroundColor: const Color(0xFF4FACFE),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOptimizationHeader(),
            SizedBox(height: 20.h),
            _buildQualityPresetsComparison(),
            SizedBox(height: 20.h),
            _buildUseCaseOptimization(),
            SizedBox(height: 20.h),
            _buildPerformanceMetrics(),
            SizedBox(height: 20.h),
            _buildLiveTest(),
            SizedBox(height: 20.h),
            _buildOptimizationTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '⚡ Smart Avatar Optimization',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Balance quality and performance using Ready Player Me API parameters',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQualityPresetsComparison() {
    final presets = OptimizedAvatarService.getAvailablePresets();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎨 Quality Presets Comparison',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16.h),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.8,
              ),
              itemCount: presets.length,
              itemBuilder: (context, index) {
                final preset = presets[index];
                return _buildPresetCard(preset);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetCard(String preset) {
    final metrics = OptimizedAvatarService.getPresetMetrics(preset);
    final isSelected = _selectedPreset == preset;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPreset = preset;
        });
        _generateTestUrls();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                preset.toUpperCase(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blue[700] : Colors.grey[800],
                ),
              ),
              SizedBox(height: 8.h),
              
              _buildMetricRow('Size', metrics['fileSize'] ?? ''),
              _buildMetricRow('Load', metrics['loadTime'] ?? ''),
              _buildMetricRow('Memory', metrics['memoryUsage'] ?? ''),
              
              SizedBox(height: 8.h),
              
              if (_demoAvatarId != null) ...[
                Container(
                  height: 80.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: _buildOptimizedAvatarPreview(preset),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizedAvatarPreview(String preset) {
    if (_demoAvatarId == null) {
      return Center(
        child: Text(
          'No Avatar ID',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
      );
    }

    final optimizedUrl = OptimizedAvatarService.generateOptimizedAvatarUrl(
      avatarId: _demoAvatarId!,
      qualityPreset: preset,
    );

    _loadTimers[preset] ??= Stopwatch();
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.r),
      child: CachedNetworkImage(
        imageUrl: optimizedUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) {
          if (!_loadTimers[preset]!.isRunning) {
            _loadTimers[preset]!.start();
          }
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blue[600],
                ),
              ),
            ),
          );
        },
        imageBuilder: (context, imageProvider) {
          _loadTimers[preset]!.stop();
          _loadSuccess[preset] = true;
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${_loadTimers[preset]!.elapsedMilliseconds}ms',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
        errorWidget: (context, url, error) {
          _loadTimers[preset]!.stop();
          _loadSuccess[preset] = false;
          return Container(
            color: Colors.red[100],
            child: Center(
              child: Icon(
                Icons.error,
                size: 20.sp,
                color: Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUseCaseOptimization() {
    final useCases = ['profile', 'social', 'workout', 'list', 'background'];
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎯 Use Case Optimization',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16.h),
            
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: useCases.map((useCase) {
                final isSelected = _selectedUseCase == useCase;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedUseCase = useCase;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[600] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      useCase.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            if (_demoAvatarId != null) ...[
              SizedBox(height: 16.h),
              Container(
                height: 120.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: _buildUseCasePreview(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUseCasePreview() {
    if (_demoAvatarId == null) return const SizedBox();

    final optimizedUrl = OptimizedAvatarService.generateUseCaseOptimizedUrl(
      avatarId: _demoAvatarId!,
      useCase: _selectedUseCase,
    );

    return CachedNetworkImage(
      imageUrl: optimizedUrl,
      width: 100.w,
      height: 100.h,
      fit: BoxFit.cover,
      placeholder: (context, url) => CircularProgressIndicator(
        strokeWidth: 2,
        color: Colors.blue[600],
      ),
      errorWidget: (context, url, error) => Icon(
        Icons.error,
        color: Colors.red,
        size: 40.sp,
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 Performance Impact',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16.h),
            
            _buildPerformanceRow('🐌 Original Avatar', '~2MB', '~5s', 'High'),
            _buildPerformanceRow('⚡ Ultra High', '~2-5MB', '~3s', 'High'),
            _buildPerformanceRow('🚀 High', '~1-2MB', '~2s', 'Medium'),
            _buildPerformanceRow('🎯 Medium', '~500KB-1MB', '~1s', 'Low'),
            _buildPerformanceRow('💾 Low', '~200-500KB', '<1s', 'Minimal'),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceRow(String preset, String size, String loadTime, String memory) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              preset,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              size,
              style: TextStyle(fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              loadTime,
              style: TextStyle(fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              memory,
              style: TextStyle(fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTest() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🧪 Live Optimization Test',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16.h),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testOptimizedGeneration,
                    icon: const Icon(Icons.speed),
                    label: const Text('Test Generation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _refreshPreviews,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            ValueListenableBuilder<FastAvatarStatus>(
              valueListenable: _controller.statusNotifier,
              builder: (context, status, child) {
                if (status == FastAvatarStatus.loading) {
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12.w),
                        Text('Generating optimized avatar...'),
                      ],
                    ),
                  );
                } else if (status == FastAvatarStatus.success) {
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '✅ Avatar generated successfully!',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        if (_controller.avatarUrlNotifier.value != null) ...[
                          SizedBox(height: 8.h),
                          Text(
                            'Optimized URL: ${_controller.avatarUrlNotifier.value}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                              fontFamily: 'monospace',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationTips() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💡 Optimization Tips',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16.h),
            
            _buildTip('🎯 Use "medium" preset for mobile apps - 50% smaller files'),
            _buildTip('⚡ "fitness_optimized" preset perfect for workout screens'),
            _buildTip('📱 Device-based optimization adapts to connection speed'),
            _buildTip('🎨 Use "profile" useCase for high-quality profile pictures'),
            _buildTip('📋 "list" useCase optimized for avatar thumbnails'),
            _buildTip('💾 Progressive loading: start low quality, upgrade to high'),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Text(
        tip,
        style: TextStyle(
          fontSize: 13.sp,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  void _generateTestUrls() {
    // Reset timers for new preset
    _loadTimers.clear();
    _loadSuccess.clear();
  }

  void _testOptimizedGeneration() async {
    await _controller.generateOptimizedAvatar(
      shirtColor: '#FF6B6B',
      pantColor: '#4ECDC4',
      shoeColor: '#45B7D1',
      skinTone: '#FFDBAC',
      hairColor: '#8B4513',
      qualityPreset: _selectedPreset,
      useCase: _selectedUseCase,
    );
    
    // Update demo avatar ID if we got one
    if (_controller.avatarIdNotifier.value != null) {
      setState(() {
        _demoAvatarId = _controller.avatarIdNotifier.value;
      });
    }
  }

  void _refreshPreviews() {
    setState(() {
      _loadTimers.clear();
      _loadSuccess.clear();
    });
  }
}
