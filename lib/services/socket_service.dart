import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  String? _currentToken;
  Timer? _reconnectTimer;
  bool _isDisposed = false;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectDelay = const Duration(seconds: 5);

  // Track all subscribed event names for proper cleanup
  final Set<String> _subscribedEvents = {};
  final Map<String, Function(dynamic)> _eventHandlers = {};

  final ValueNotifier<bool> connectionState = ValueNotifier(false);
  final ValueNotifier<List<dynamic>> incomingMessages = ValueNotifier([]);

  bool get isConnected => _socket?.connected ?? false;
  String? get currentToken => _currentToken;

  Future<void> initialize(String token) async {
    if (_isDisposed) return;

    _currentToken = token;
    await connect(token);
  }

  Future<void> connect(String token) async {
    if (_isDisposed) return;

    if (_socket?.connected == true && _currentToken == token) {
      print('Socket already connected with same token');
      return;
    }

    _currentToken = token;
    await disconnect();

    try {
      print('Connecting to socket with token: ${token.substring(0, 10)}...');

      _socket = IO.io(
        'https://nnl056zh-3099.inc1.devtunnels.ms/notifications',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setQuery({'token': token})
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .setTimeout(20000)
            .setReconnectionAttempts(5)
            .setReconnectionDelay(2000)
            .build(),
      );

      _setupSocketListeners();
      _socket!.connect();

      // Reset reconnect attempts on successful connection setup
      _reconnectAttempts = 0;

    } catch (e) {
      print('Socket connection error: $e');
      connectionState.value = false;
      _scheduleReconnect();
      rethrow;
    }
  }

  void _setupSocketListeners() {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      print('Socket connected successfully');
      connectionState.value = true;
      _reconnectAttempts = 0;
      _cancelReconnectTimer();

      // Re-subscribe to all events after reconnection
      _resubscribeToEvents();
    });

    _socket!.onDisconnect((reason) {
      print('Socket disconnected: $reason');
      connectionState.value = false;

      // Only attempt reconnection if not manually disconnected
      if (reason != 'io client disconnect' && !_isDisposed) {
        _scheduleReconnect();
      }
    });

    _socket!.onError((error) {
      print('Socket error: $error');
      connectionState.value = false;
      _scheduleReconnect();
    });

    _socket!.onConnectError((error) {
      print('Socket connection error: $error');
      connectionState.value = false;
      _scheduleReconnect();
    });

    _socket!.onReconnect((attempt) {
      print('Socket reconnected on attempt: $attempt');
      connectionState.value = true;
      _reconnectAttempts = 0;
    });

    _socket!.onReconnectError((error) {
      print('Socket reconnection error: $error');
      _scheduleReconnect();
    });
  }

  void _resubscribeToEvents() {
    print('Re-subscribing to ${_eventHandlers.length} events');
    _eventHandlers.forEach((eventName, handler) {
      _socket?.on(eventName, handler);
    });
  }

  void _scheduleReconnect() {
    if (_isDisposed || _reconnectAttempts >= _maxReconnectAttempts) {
      print('Max reconnection attempts reached or service disposed');
      return;
    }

    _cancelReconnectTimer();
    _reconnectAttempts++;

    print('Scheduling reconnect attempt $_reconnectAttempts in ${_reconnectDelay.inSeconds} seconds');

    _reconnectTimer = Timer(_reconnectDelay, () {
      if (!_isDisposed && _currentToken != null) {
        print('Attempting reconnection...');
        connect(_currentToken!);
      }
    });
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Subscribe to a socket event
  void on(String eventName, Function(dynamic) handler) {
    if (_isDisposed) return;

    _socket?.on(eventName, handler);
    _subscribedEvents.add(eventName);
    _eventHandlers[eventName] = handler; // Store for re-subscription
    print('Subscribed to event: $eventName');
  }

  /// Unsubscribe from a specific socket event
  void off(String eventName) {
    _socket?.off(eventName);
    _subscribedEvents.remove(eventName);
    _eventHandlers.remove(eventName);
    print('Unsubscribed from event: $eventName');
  }

  /// Unsubscribe from all events we've subscribed to
  void unsubscribeAll() {
    for (final event in _subscribedEvents) {
      _socket?.off(event);
    }
    _subscribedEvents.clear();
    _eventHandlers.clear();
    print('Unsubscribed from all events');
  }

  Future<void> disconnect() async {
    try {
      _cancelReconnectTimer();
      if (_socket != null) {
        unsubscribeAll();
        _socket!.disconnect();
        _socket!.destroy();
        _socket = null;
      }
    } finally {
      connectionState.value = false;
      print('Socket disconnected and cleaned up');
    }
  }

  /// Send an event to the server
  void emit(String eventName, [dynamic data]) {
    if (_socket?.connected == true) {
      _socket!.emit(eventName, data);
      print('Emitted event: $eventName');
    } else {
      print('Cannot emit event $eventName - socket not connected');
    }
  }

  /// Force reconnection with current token
  Future<void> forceReconnect() async {
    if (_currentToken != null) {
      await connect(_currentToken!);
    }
  }

  void dispose() {
    print('Disposing SocketService');
    _isDisposed = true;
    _cancelReconnectTimer();
    disconnect();
    connectionState.dispose();
    incomingMessages.dispose();
  }
}