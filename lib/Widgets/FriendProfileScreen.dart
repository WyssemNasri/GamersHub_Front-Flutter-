import 'package:flutter/material.dart';
import '../Constant/constant.dart';
import '../models/Person_Model.dart';
import '../services/LoadImageService.dart';

class FriendProfileScreen extends StatelessWidget {
  final Person friend;
  final LoadImageService loadImageService; // Le service de chargement d'images

  FriendProfileScreen({
    required this.friend,
    required this.loadImageService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${friend.firstName} ${friend.lastName}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Utilisation du FutureBuilder pour charger l'image
            FutureBuilder<ImageProvider>(
              future: loadImageService.fetchImage('$addresse${friend.profilePicUrl}'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, color: Colors.white),
                  );
                } else {
                  return CircleAvatar(
                    radius: 50,
                    backgroundImage: snapshot.data,
                  );
                }
              },
            ),
            SizedBox(height: 20),
            Text(
              'Full Name: ${friend.firstName} ${friend.lastName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),


            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Action pour envoyer un message ou faire une autre action
              },
              child: Text('Send Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
