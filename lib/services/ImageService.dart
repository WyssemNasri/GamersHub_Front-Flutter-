
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/SessionManager.dart';
import '../Constant/constant.dart';

class ImageService {
  static Future<ImageProvider> fetchImage(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const AssetImage('assets/images/default_profile_picture.png');
    }

    String fullUrl = "$addresse$imageUrl";
    String? token = await SessionManager.loadToken();

    try {
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return MemoryImage(response.bodyBytes);
      } else {
        return const AssetImage('assets/images/default_profile_picture.png');
      }
    } catch (e) {
      print('Error fetching image: $e');
      return const AssetImage('assets/images/default_profile_picture.png');
    }
  }
}
