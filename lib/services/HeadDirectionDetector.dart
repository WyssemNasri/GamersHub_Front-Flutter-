import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HeadDirectionDetector {
  CameraController? _cameraController;
  bool _isDetecting = false;

  // Initialisation de la caméra
  Future<void> initialize() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front);

    _cameraController = CameraController(frontCamera, ResolutionPreset.low);
    await _cameraController!.initialize();
  }

  // Détection de l'orientation de la tête
  Future<String> startHeadDetection() async {
    if (_isDetecting || _cameraController == null || !_cameraController!.value.isInitialized) {
      return 'none';
    }

    _isDetecting = true;
    try {
      final image = await _cameraController!.takePicture();
      final bytes = await File(image.path).readAsBytes();

      // Création de la requête HTTP
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.43.169:5001/detect/head_direction'),  // Assurez-vous que l'IP et le port sont corrects
      );

      request.files.add(http.MultipartFile.fromBytes('frame', bytes, filename: 'frame.jpg'));

      // Envoi de la requête au backend
      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();

        // Convertir la réponse JSON
        final jsonResponse = json.decode(respStr);

        // Si la direction est incluse dans la réponse JSON
        final direction = jsonResponse['direction'] ?? 'none';
        return direction;
      } else {
        return "none";
      }
    } catch (e) {
      print("Erreur lors de la détection de l'orientation : $e");
      return "none";
    } finally {
      _isDetecting = false;
    }
  }

  // Libérer la caméra
  void dispose() {
    _cameraController?.dispose();
  }
}
