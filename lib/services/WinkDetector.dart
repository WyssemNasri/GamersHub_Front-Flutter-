import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class WinkDetector {
  CameraController? _controller;
  bool _isDetecting = false;

  /// Initialisation de la caméra frontale
  Future<void> initialize() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.low,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
  }

  /// Détection de clin d'œil : left / right / none
  Future<String?> startWinkDetection() async {
    if (_controller == null || !_controller!.value.isInitialized || _isDetecting) return null;

    _isDetecting = true;

    try {
      final XFile picture = await _controller!.takePicture();
      final Uint8List bytes = await picture.readAsBytes();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.43.169:5001/detect/wink'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'frame',
          bytes,
          filename: 'frame.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final jsonResponse = json.decode(res.body);
        print("Wink detection result: $jsonResponse");

        return jsonResponse['wink'] ?? 'none';
      } else {
        print("Erreur HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur lors de la détection : $e");
    } finally {
      _isDetecting = false;
    }

    return null;
  }

  void dispose() {
    _controller?.dispose();
  }

  /// Détection de la direction de la tête : left / right / center / none
  Future<String?> startHeadDirectionDetection() async {
    if (_controller == null || !_controller!.value.isInitialized || _isDetecting) return null;

    _isDetecting = true;

    try {
      final XFile picture = await _controller!.takePicture();
      final Uint8List bytes = await picture.readAsBytes();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.43.169:5001/detect/head_direction'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'frame',
          bytes,
          filename: 'frame.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final jsonResponse = json.decode(res.body);
        print("Head direction detection result: $jsonResponse");

        return jsonResponse['direction'] ?? 'none';
      } else {
        print("Erreur HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur lors de la détection de la direction de la tête : $e");
    } finally {
      _isDetecting = false;
    }

    return null;
  }

}
