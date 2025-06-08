import 'package:flutter/material.dart';

import '../models/Person_Model.dart';
import '../services/LoadImageService.dart';

class FriendsDialog extends StatelessWidget {
  final List<Person> userFriends;
  final String addresse;
  final LoadImageService loadImageService;

  FriendsDialog({
    required this.userFriends,
    required this.addresse,
    required this.loadImageService,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Friends',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      content: SizedBox(
        height: 350,
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: userFriends.length,
          itemBuilder: (_, i) {
            final f = userFriends[i];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
              child: ListTile(
                leading: FutureBuilder<ImageProvider>(
                  future: loadImageService.fetchImage('$addresse${f.profilePicUrl}'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[300],
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      );
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, color: Colors.white),
                      );
                    } else {
                      return CircleAvatar(
                        radius: 25,
                        backgroundImage: snapshot.data,
                      );
                    }
                  },
                ),
                title: Text(
                  '${f.firstName} ${f.lastName}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Tap to view profile',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                onTap: () {
                  // Handle navigation to friend's profile or other actions
                  Navigator.pop(context); // Close the dialog on tap
                  // You can handle the navigation or action here
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Close',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
