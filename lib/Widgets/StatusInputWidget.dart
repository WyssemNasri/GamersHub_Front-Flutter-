import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:gamershub/services/SessionManager.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../services/file_picker.dart';

class StatusInputWidget extends StatefulWidget {
  final Function(String) onStatusPosted;

  const StatusInputWidget({Key? key, required this.onStatusPosted}) : super(key: key);

  @override
  _StatusInputWidgetState createState() => _StatusInputWidgetState();
}

class _StatusInputWidgetState extends State<StatusInputWidget> {
  final TextEditingController _statusController = TextEditingController();
  File? _pickedFile;

  // Utilisation de la méthode de FilePicker
  Future<void> _pickImageOrVideo() async {
    File? file = await FilePicker.pickImageFromGallery();
    if (file != null) {
      setState(() {
        _pickedFile = file;
      });
    }
  }

  Future<void> _postStatus() async {
    try {
      String? token = await SessionManager.loadToken();
      String? userId = await SessionManager.loadId();
      if (token == null) {
        print("Erreur : Aucun token trouvé. L'utilisateur doit se reconnecter.");
        return;
      }

      String status = _statusController.text;
      final uri = Uri.parse('http://192.168.43.169:8080/post/statue');
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      Map<String, dynamic> postRequest = {"userId": userId, "description": status};
      request.fields['post'] = jsonEncode(postRequest);
      if (_pickedFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _pickedFile!.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        widget.onStatusPosted(status);
        _statusController.clear();
        setState(() {
          _pickedFile = null;
        });
        print("✅ Statut posté avec succès !");
      } else {
        String responseBody = await response.stream.bytesToString();
        print('⚠️ Échec de l\'envoi du statut : ${response.statusCode}');
        print('🔹 Réponse du serveur : $responseBody');
      }
    } catch (e) {
      print("❌ Erreur lors de l'envoi du statut : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: TextField(
            controller: _statusController,
            decoration: InputDecoration(
              hintText: 'What\'s on your mind?',
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            maxLines: 3,
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(onPressed: _pickImageOrVideo, icon: Icon(Icons.camera_alt, color: Colors.blue)),
            SizedBox(width: 10),
            IconButton(onPressed: _pickImageOrVideo, icon: Icon(Icons.photo_library, color: Colors.green)),
            Spacer(),
            ElevatedButton(
              onPressed: _postStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Post Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        if (_pickedFile != null) Image.file(_pickedFile!, width: double.infinity, height: 180, fit: BoxFit.cover),
      ],
    );
  }
}
