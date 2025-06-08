import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamershub/services/file_picker.dart';
import 'package:gamershub/services/SessionManager.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:io';
import '../Constant/constant.dart';
import '../services/speech_service.dart';

class StatusInputWidget extends StatefulWidget {
  final Function(String) onStatusPosted;

  const StatusInputWidget({Key? key, required this.onStatusPosted}) : super(key: key);

  @override
  _StatusInputWidgetState createState() => _StatusInputWidgetState();
}

class _StatusInputWidgetState extends State<StatusInputWidget> {
  final SpeechService _speechService = SpeechService();
  final TextEditingController _statusController = TextEditingController();
  File? _pickedFile;
  bool _isListening = false;
  String _selectedLocale = 'fr-FR'; // Valeur par défaut

  // Sélection image ou vidéo
  Future<void> _pickImageOrVideo() async {
    File? file = await FilePicker.pickImageFromGallery();
    if (file != null) {
      setState(() {
        _pickedFile = file;
      });
    }
  }

  void _handleMicPress() async {
    if (_isListening) {
      _speechService.stopListening();
      setState(() => _isListening = false);
    } else {
      // Affiche un dialog pour sélectionner la langue
      String? selected = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Choisir la langue du micro'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('Français'),
                  onTap: () => Navigator.pop(context, 'fr-FR'),
                ),
                ListTile(
                  title: Text('English'),
                  onTap: () => Navigator.pop(context, 'en-US'),
                ),
                ListTile(
                  title: Text('العربية'),
                  onTap: () => Navigator.pop(context, 'ar'),
                ),
              ],
            ),
          );
        },
      );

      if (selected != null) {
        setState(() {
          _selectedLocale = selected;
          _isListening = true;
        });

        await _speechService.startListening((text) {
          setState(() {
            _statusController.text = text;
            _statusController.selection = TextSelection.fromPosition(
              TextPosition(offset: text.length),
            );
          });
        }, localeId: _selectedLocale);
      }
    }
  }


  // Poster le statut
  Future<void> _postStatus() async {
    try {
      String? token = await SessionManager.loadToken();
      String? userId = await SessionManager.loadId();
      if (token == null) throw 'Token not found. Please log in again.';

      String status = _statusController.text.trim();
      if (status.isEmpty && _pickedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a status or pick an image/video.')),
        );
        return;
      }

      final uri = Uri.parse(sharePostendpoint);
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['post'] = jsonEncode({"userId": userId, "description": status});

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
        setState(() => _pickedFile = null);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Status posted successfully!")));
      } else {
        String responseBody = await response.stream.bytesToString();
        throw 'Failed to post status: ${response.statusCode}\n$responseBody';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      print("Error posting status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Ligne principale
        Row(
          children: [
            SizedBox(width: 20,),
            IconButton(onPressed: _pickImageOrVideo, icon: Icon(Icons.photo_library, color: Colors.green)),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  controller: _statusController,
                  decoration: InputDecoration(
                    hintText: 'What\'s on your mind?',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  maxLines: 1,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            IconButton(
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.red),
              onPressed: _handleMicPress,
            ),
            IconButton(
              onPressed: _postStatus,
              icon: Icon(Icons.post_add, color: Colors.blue),
            ),
          ],
        ),

        if (_pickedFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Image.file(_pickedFile!, width: double.infinity, height: 180, fit: BoxFit.cover),
          ),
      ],
    );
  }
}
