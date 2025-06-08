import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gamershub/services/SessionManager.dart';
import 'package:http/http.dart' as http;

class LoadImageService {
  Future<ImageProvider> fetchImage(String? url) async {
    if (url == null || url.isEmpty) {
      return const AssetImage('assets/images/default_profile_picture.png');
    }
    String? token = await SessionManager.loadToken();
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return MemoryImage(response.bodyBytes);
    } else {
      return const AssetImage('assets/images/default_profile_picture.png');
    }
  }
  Future<void> showFullScreenImage(BuildContext context, String imageUrl) async {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.8,
              maxScale: 3.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FutureBuilder<ImageProvider>( // Loading image from the service
                  future: fetchImage(imageUrl),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Image.asset('assets/images/default_profile_picture.png', fit: BoxFit.cover);
                    }
                    return Hero(
                      tag: imageUrl,
                      child: Image(
                        image: snapshot.data!,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.7),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
