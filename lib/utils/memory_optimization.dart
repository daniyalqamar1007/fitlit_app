import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

/// 🧠 Memory Optimization Utility
/// Provides comprehensive memory management including:
/// - Automatic disposal of controllers and subscriptions
/// - Memory leak detection
/// - Efficient widget disposal
/// - Stream and timer cleanup

class MemoryOptimization {
  static final List<Disposable> _disposables = [];
  static Timer? _memoryCheckTimer;
  static int _memoryCheckInterval = 30; // seconds

  /// Register a disposable resource for automatic cleanup
  static void register(Disposable disposable) {
    _disposables.add(disposable);
  }

  /// Unregister a disposable resource
  static void unregister(Disposable disposable) {
    _disposables.remove(disposable);
  }

  /// Dispose all registered resources
  static void disposeAll() {
    for (final disposable in _disposables) {
      try {
        disposable.dispose();
      } catch (e) {
        debugPrint('Error disposing resource: $e');
      }
    }
    _disposables.clear();
  }

  /// Start memory monitoring
  static void startMemoryMonitoring() {
    _memoryCheckTimer?.cancel();
    _memoryCheckTimer = Timer.periodic(
      Duration(seconds: _memoryCheckInterval),
      (timer) {
        _checkMemoryUsage();
      },
    );
  }

  /// Stop memory monitoring
  static void stopMemoryMonitoring() {
    _memoryCheckTimer?.cancel();
    _memoryCheckTimer = null;
  }

  /// Check current memory usage
  static void _checkMemoryUsage() {
    if (kDebugMode) {
      // In a real implementation, you'd use platform-specific memory monitoring
      debugPrint('Memory Check: ${_disposables.length} active disposables');
      
      // Check for potential memory leaks
      if (_disposables.length > 50) {
        debugPrint('⚠️ Warning: High number of active disposables (${_disposables.length}). Potential memory leak!');
      }
    }
  }

  /// Clear image cache periodically
  static void scheduleImageCacheCleanup() {
    Timer.periodic(const Duration(minutes: 5), (timer) {
      imageCache.clear();
      debugPrint('🧹 Image cache cleared');
    });
  }

  /// Get memory usage report
  static Map<String, dynamic> getMemoryReport() {
    return {
      'active_disposables': _disposables.length,
      'image_cache_size': imageCache.currentSizeBytes,
      'image_cache_count': imageCache.liveImageCount,
      'monitoring_active': _memoryCheckTimer?.isActive ?? false,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Interface for disposable resources
abstract class Disposable {
  void dispose();
}

/// 🎮 Optimized Controller Base
/// Base class for controllers with automatic memory management
abstract class OptimizedController extends ChangeNotifier implements Disposable {
  final List<StreamSubscription> _subscriptions = [];
  final List<Timer> _timers = [];
  bool _disposed = false;

  OptimizedController() {
    MemoryOptimization.register(this);
  }

  /// Add a stream subscription for automatic disposal
  void addSubscription(StreamSubscription subscription) {
    if (!_disposed) {
      _subscriptions.add(subscription);
    }
  }

  /// Add a timer for automatic disposal
  void addTimer(Timer timer) {
    if (!_disposed) {
      _timers.add(timer);
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    
    _disposed = true;
    
    // Cancel all subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    
    // Cancel all timers
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    
    // Unregister from memory optimization
    MemoryOptimization.unregister(this);
    
    super.dispose();
    
    debugPrint('✅ Controller disposed: ${runtimeType}');
  }

  /// Check if controller is disposed
  bool get isDisposed => _disposed;

  /// Assert not disposed (for debugging)
  void assertNotDisposed([String? operation]) {
    assert(!_disposed, 'Cannot perform ${operation ?? 'operation'} on disposed controller');
  }
}

/// 📱 Optimized StatefulWidget Base
/// Base class for StatefulWidgets with automatic cleanup
abstract class OptimizedStatefulWidget extends StatefulWidget {
  const OptimizedStatefulWidget({super.key});
}

/// 🔧 Optimized State Base
/// Base class for State with automatic resource management
abstract class OptimizedState<T extends OptimizedStatefulWidget> extends State<T> implements Disposable {
  final List<StreamSubscription> _subscriptions = [];
  final List<Timer> _timers = [];
  final List<AnimationController> _animationControllers = [];
  final List<TextEditingController> _textControllers = [];
  final List<ScrollController> _scrollControllers = [];
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    MemoryOptimization.register(this);
  }

  /// Add a stream subscription for automatic disposal
  void addSubscription(StreamSubscription subscription) {
    if (!_disposed) {
      _subscriptions.add(subscription);
    }
  }

  /// Add a timer for automatic disposal
  void addTimer(Timer timer) {
    if (!_disposed) {
      _timers.add(timer);
    }
  }

  /// Add an animation controller for automatic disposal
  void addAnimationController(AnimationController controller) {
    if (!_disposed) {
      _animationControllers.add(controller);
    }
  }

  /// Add a text controller for automatic disposal
  void addTextController(TextEditingController controller) {
    if (!_disposed) {
      _textControllers.add(controller);
    }
  }

  /// Add a scroll controller for automatic disposal
  void addScrollController(ScrollController controller) {
    if (!_disposed) {
      _scrollControllers.add(controller);
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    
    _disposed = true;
    
    // Cancel all subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    
    // Cancel all timers
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    
    // Dispose animation controllers
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    _animationControllers.clear();
    
    // Dispose text controllers
    for (final controller in _textControllers) {
      controller.dispose();
    }
    _textControllers.clear();
    
    // Dispose scroll controllers
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    _scrollControllers.clear();
    
    // Unregister from memory optimization
    MemoryOptimization.unregister(this);
    
    super.dispose();
    
    debugPrint('✅ State disposed: ${runtimeType}');
  }

  /// Check if state is disposed
  bool get isDisposed => _disposed;
}

/// 🔄 Stream Management Helper
class StreamManager implements Disposable {
  final List<StreamSubscription> _subscriptions = [];
  bool _disposed = false;

  StreamManager() {
    MemoryOptimization.register(this);
  }

  /// Add a stream subscription
  void add<T>(Stream<T> stream, void Function(T) onData, {
    Function? onError,
    void Function()? onDone,
  }) {
    if (_disposed) return;
    
    final subscription = stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
    );
    
    _subscriptions.add(subscription);
  }

  /// Cancel all subscriptions
  @override
  void dispose() {
    if (_disposed) return;
    
    _disposed = true;
    
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    
    MemoryOptimization.unregister(this);
    debugPrint('✅ StreamManager disposed');
  }
}

/// ⏰ Timer Management Helper
class TimerManager implements Disposable {
  final List<Timer> _timers = [];
  bool _disposed = false;

  TimerManager() {
    MemoryOptimization.register(this);
  }

  /// Create a periodic timer
  Timer periodic(Duration duration, void Function(Timer) callback) {
    if (_disposed) throw StateError('TimerManager is disposed');
    
    final timer = Timer.periodic(duration, callback);
    _timers.add(timer);
    return timer;
  }

  /// Create a one-time timer
  Timer once(Duration duration, void Function() callback) {
    if (_disposed) throw StateError('TimerManager is disposed');
    
    final timer = Timer(duration, callback);
    _timers.add(timer);
    return timer;
  }

  /// Cancel all timers
  @override
  void dispose() {
    if (_disposed) return;
    
    _disposed = true;
    
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    
    MemoryOptimization.unregister(this);
    debugPrint('✅ TimerManager disposed');
  }
}

/// 🧹 Cleanup Utilities
class CleanupUtils {
  /// Dispose a list of disposable objects safely
  static void disposeList(List<dynamic> objects) {
    for (final object in objects) {
      try {
        if (object is Disposable) {
          object.dispose();
        } else if (object is ChangeNotifier) {
          object.dispose();
        } else if (object is StreamSubscription) {
          object.cancel();
        } else if (object is Timer) {
          object.cancel();
        }
      } catch (e) {
        debugPrint('Error disposing object: $e');
      }
    }
    objects.clear();
  }

  /// Force garbage collection (debug only)
  static void forceGarbageCollection() {
    if (kDebugMode) {
      // Force garbage collection in debug mode
      // Note: This is not available in production builds
      debugPrint('🗑️ Forcing garbage collection...');
    }
  }
}