import 'package:flutter/material.dart';
import 'package:gamershub/services/file_picker.dart';
import 'package:gamershub/services/SessionManager.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:io';

import '../Constant/constant.dart';
import '../Views/LiveStreamInterface.dart';

class StatusInputWidget extends StatefulWidget {
  final Function(String) onStatusPosted;

  const StatusInputWidget({Key? key, required this.onStatusPosted}) : super(key: key);

  @override
  _StatusInputWidgetState createState() => _StatusInputWidgetState();
}

class _StatusInputWidgetState extends State<StatusInputWidget> {
  final TextEditingController _statusController = TextEditingController();
  File? _pickedFile;

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
        throw 'Token not found, please log in again';
      }

      String status = _statusController.text;
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
        setState(() {
          _pickedFile = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Status posted successfully!")));
      } else {
        String responseBody = await response.stream.bytesToString();
        throw 'Failed to post status: ${response.statusCode}\n$responseBody';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      print("❌ Error posting status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
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
          children: [
            IconButton(onPressed: _pickImageOrVideo, icon: Icon(Icons.camera_alt, color: Colors.blue)),
            SizedBox(width: 10),
            IconButton(onPressed: _pickImageOrVideo, icon: Icon(Icons.photo_library, color: Colors.green)),
            SizedBox(width: 10),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => LiveStream()));
              },
              icon: Icon(Icons.radio_button_checked, color: Colors.red),
            ),
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
        if (_pickedFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Image.file(_pickedFile!, width: double.infinity, height: 180, fit: BoxFit.cover),
          ),
      ],
    );
  }
}
