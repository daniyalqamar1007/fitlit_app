// upload_isolate_service.dart
import 'dart:isolate';
import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;

class UploadIsolateService {
  static Isolate? _isolate;
  static SendPort? _sendPort;
  static final Completer<SendPort> _sendPortCompleter = Completer<SendPort>();
  static StreamController<UploadMessage>? _messageController;

  // Initialize the isolate
  static Future<void> initialize() async {
    if (_isolate != null) return;

    _messageController = StreamController<UploadMessage>.broadcast();

    final receivePort = ReceivePort();

    _isolate = await Isolate.spawn(
      _isolateEntryPoint,
      receivePort.sendPort,
    );

    receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        if (!_sendPortCompleter.isCompleted) {
          _sendPortCompleter.complete(message);
        }
      } else if (message is UploadMessage) {
        _messageController?.add(message);
      }
    });

    await _sendPortCompleter.future;
  }

  // Start upload in isolate
  static Future<String> startUpload({
    required String category,
    required String subCategory,
    required File imageFile,
    required String avatarUrl,
    required String token,
    required String uploadId,
  }) async {
    await initialize();

    final uploadRequest = UploadRequest(
      uploadId: uploadId,
      category: category,
      subCategory: subCategory,
      imageFilePath: imageFile.path,
      avatarUrl: avatarUrl,
      token: token,
    );

    _sendPort?.send(uploadRequest);
    return uploadId;
  }

  // Get upload status stream
  static Stream<UploadMessage> get uploadStream {
    return _messageController?.stream ?? Stream.empty();
  }

  // Dispose isolate
  static void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
    _messageController?.close();
    _messageController = null;
  }

  // Isolate entry point
  static void _isolateEntryPoint(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) async {
      if (message is UploadRequest) {
        await _handleUploadInIsolate(message, sendPort);
      }
    });
  }

  // Handle upload in isolate
  static Future<void> _handleUploadInIsolate(
      UploadRequest request,
      SendPort sendPort,
      ) async {
    try {
      // Send starting message
      sendPort.send(UploadMessage(
        uploadId: request.uploadId,
        status: UploadStatus.started,
        message: 'Upload started',
      ));

      // Create Dio instance
      final dio = Dio(BaseOptions(
        baseUrl: "https://wittywardrobe.store/aims-service5", // Replace with your actual base URL
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 300),
        sendTimeout: const Duration(seconds: 300),
      ));

      // Convert image to PNG
      sendPort.send(UploadMessage(
        uploadId: request.uploadId,
        status: UploadStatus.processing,
        message: 'Converting image format...',
        progress: 0.1,
      ));

      final pngFile = await _convertImageToPng(File(request.imageFilePath));

      sendPort.send(UploadMessage(
        uploadId: request.uploadId,
        status: UploadStatus.processing,
        message: 'Preparing upload data...',
        progress: 0.2,
      ));

      // Create FormData
      final formData = FormData.fromMap({
        'category': request.category,
        'sub_category': request.subCategory,
        'avatar': request.avatarUrl,
        'file': await MultipartFile.fromFile(
          pngFile.path,
          filename: 'wardrobe_${DateTime.now().millisecondsSinceEpoch}.png',
          contentType: MediaType('image', 'png'),
        ),
      });

      sendPort.send(UploadMessage(
        uploadId: request.uploadId,
        status: UploadStatus.uploading,
        message: 'Uploading to server...',
        progress: 0.3,
      ));

      // Upload with progress tracking
      final response = await dio.post(
        '/wardrobe-items',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${request.token}',
            'Content-Type': 'multipart/form-data',
          },
        ),
        onSendProgress: (sent, total) {
          final progress = 0.3 + (sent / total) * 0.6; // 30% to 90%
          sendPort.send(UploadMessage(
            uploadId: request.uploadId,
            status: UploadStatus.uploading,
            message: 'Uploading... ${(progress * 100).toInt()}%',
            progress: progress,
          ));
        },
      );

      // Process response
      sendPort.send(UploadMessage(
        uploadId: request.uploadId,
        status: UploadStatus.processing,
        message: 'Processing response...',
        progress: 0.95,
      ));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        Map<String, dynamic> itemData;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            itemData = responseData['data'];
          } else if (responseData.containsKey('item')) {
            itemData = responseData['item'];
          } else {
            itemData = responseData;
          }
        } else {
          throw Exception('Unexpected response format');
        }

        // Send success message
        sendPort.send(UploadMessage(
          uploadId: request.uploadId,
          status: UploadStatus.completed,
          message: 'Upload completed successfully!',
          progress: 1.0,
          data: itemData,
        ));
      } else {
        throw Exception('Upload failed with status ${response.statusCode}');
      }

    } catch (e) {
      // Send error message
      sendPort.send(UploadMessage(
        uploadId: request.uploadId,
        status: UploadStatus.error,
        message: 'Upload failed: ${e.toString()}',
        error: e.toString(),
      ));
    }
  }

  // Convert image to PNG in isolate
  static Future<File> _convertImageToPng(File originalFile) async {
    final imageBytes = await originalFile.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final pngBytes = img.encodePng(image);
    final pngFile = File('${originalFile.parent.path}/converted_${DateTime.now().millisecondsSinceEpoch}.png');
    await pngFile.writeAsBytes(pngBytes);

    return pngFile;
  }
}

// Data classes for isolate communication
class UploadRequest {
  final String uploadId;
  final String category;
  final String subCategory;
  final String imageFilePath;
  final String avatarUrl;
  final String token;

  UploadRequest({
    required this.uploadId,
    required this.category,
    required this.subCategory,
    required this.imageFilePath,
    required this.avatarUrl,
    required this.token,
  });
}

class UploadMessage {
  final String uploadId;
  final UploadStatus status;
  final String message;
  final double? progress;
  final Map<String, dynamic>? data;
  final String? error;

  UploadMessage({
    required this.uploadId,
    required this.status,
    required this.message,
    this.progress,
    this.data,
    this.error,
  });
}

enum UploadStatus {
  started,
  processing,
  uploading,
  completed,
  error,
}