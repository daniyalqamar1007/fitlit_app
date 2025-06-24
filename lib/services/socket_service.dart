// socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? _socket;
  String? _currentToken;
  bool _isConnected = false;

  factory SocketService() => _instance;

  SocketService._internal();

  IO.Socket? get socket => _socket;

  Future<void> connect(String token) async {
    if (_socket != null && _isConnected && _currentToken == token) return;

    _currentToken = token;
    await disconnect();

    try {
      _socket = IO.io(
        'https://your-server-url.com',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setQuery({'token': token})
            .build(),
      );

      _socket!.onConnect((_) {
        _isConnected = true;
        print('Socket connected');
        _socket!.emit('join', {'userId': _extractUserIdFromToken(token)});
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        print('Socket disconnected');
      });

      _socket!.onError((error) => print('Socket error: $error'));
      _socket!.connect();
    } catch (e) {
      print('Socket connection error: $e');
    }
  }

  Future<void> disconnect() async {
    _socket?.disconnect();
    _socket?.destroy();
    _socket = null;
    _isConnected = false;
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  String? _extractUserIdFromToken(String token) {
    // Implement your JWT parsing logic here
    return null;
  }
}