import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LiveStream extends StatefulWidget {
  const LiveStream({super.key});

  @override
  State<LiveStream> createState() => _LiveStreamState();
}

class _LiveStreamState extends State<LiveStream> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isLive = false;
  WebSocketChannel? _channel;
  final String serverUrl = "ws://192.168.1.18:8080/ws";  // URL de connexion WebSocket au serveur Spring

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialisation de la caméra
  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0], // Utilise la première caméra
        ResolutionPreset.high, // Résolution élevée pour la vidéo
      );
      await _controller!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  // Démarrer le flux en direct via WebSocket
  void _goLive() {
    if (_isCameraInitialized) {
      setState(() {
        _isLive = true; // Change l'état en direct
      });

      // Connexion WebSocket avec le serveur Spring
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));

      // Démarrer la capture et l'envoi des images
      _startCapturing();
    } else {
      print("La caméra n'est pas encore initialisée");
    }
  }

  // Fonction pour capturer les images et les envoyer via WebSocket
  Future<void> _startCapturing() async {
    while (_isLive) {
      try {
        // Capturer une image
        final image = await _controller!.takePicture();

        // Convertir l'image en bytes
        Uint8List imageBytes = await image.readAsBytes();

        // Encoder l'image en Base64 pour l'envoyer par WebSocket
        String base64Image = base64Encode(imageBytes);

        // Créer un message structuré (ici on envoie l'image et un identifiant de session, par exemple)
        Map<String, dynamic> message = {
          'image': base64Image,
          'timestamp': DateTime.now().toIso8601String(),
        };

        // Convertir le message en JSON
        String jsonMessage = jsonEncode(message);

        // Envoyer le message via WebSocket
        _channel!.sink.add(jsonMessage);

        // Attendre avant de capturer une nouvelle image
        await Future.delayed(Duration(milliseconds: 100)); // Ajuste l'intervalle
      } catch (e) {
        print("Erreur lors de la capture de l'image: $e");
        break;
      }
    }
  }

  // Fonction pour arrêter le flux en direct
  void _stopLiveStream() {
    setState(() {
      _isLive = false; // Mettre fin au flux en direct
    });

    _channel?.sink.close(); // Fermer la connexion WebSocket
    print("Le flux a été arrêté.");
  }

  @override
  void dispose() {
    _controller?.dispose();
    _channel?.sink.close(); // Fermer la connexion WebSocket
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Stream'),
      ),
      body: Column(
        children: [
          // Si la caméra est initialisée, affiche le flux vidéo en temps réel
          if (_isCameraInitialized)
            Expanded(
              child: CameraPreview(_controller!),
            ),
          // Si l'utilisateur n'est pas encore en direct, montre un bouton "Go Live"
          if (!_isLive)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _goLive,
                child: Text('Go Live'),
              ),
            ),
          // Si l'utilisateur est en direct, montre un bouton pour arrêter le flux
          if (_isLive)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('You are now live streaming!'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _stopLiveStream,
                    child: Text('Stop Streaming'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
