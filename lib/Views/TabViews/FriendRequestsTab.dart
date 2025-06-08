import 'package:flutter/material.dart';
import 'package:gamershub/services/LoadImageService.dart';
import 'package:http/http.dart' as http;
import 'package:gamershub/Constant/constant.dart';
import 'package:gamershub/services/SessionManager.dart';
import 'dart:convert';
import '../../Providers/FontNotifier.dart';
import '../../Constant/app_localizations.dart';
import '../../models/FriendRequest_Medel.dart';
import 'package:provider/provider.dart';
import '../../Providers/ThemeNotifier.dart';

class FriendSearsh extends StatefulWidget {
  const FriendSearsh({super.key});

  @override
  State<FriendSearsh> createState() => _FriendSearshState();
}

class _FriendSearshState extends State<FriendSearsh> {
  late final LoadImageService loadImageService;
  bool _isLoading = true;
  List<FriendRequest> _friendRequests = [];
  List<FriendRequest> _sentFriendRequests = []; // Added for sent requests

  @override
  void initState() {
    super.initState();
    loadImageService = LoadImageService();
    fetchFriendRequestReceved();
    fetchSentFriendRequests(); // Fetch sent friend requests as well
  }

  // Method for fetching received friend requests
  Future<void> fetchFriendRequestReceved() async {
    String? token = await SessionManager.loadToken();
    String? id = await SessionManager.loadId();
    if (id != null) {
      final url = Uri.parse("$FriendRequestReceved$id");
      try {
        final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          setState(() {
            _friendRequests = data.map((item) => FriendRequest.fromJson(item)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          print("Failed to load friend requests");
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print("Error: $e");
      }
    }
  }

  // Method for fetching sent friend requests
  Future<void> fetchSentFriendRequests() async {
    String? token = await SessionManager.loadToken();
    String? id = await SessionManager.loadId();
    if (id != null) {
      final url = Uri.parse("$sendFriendRequestEndpoint$id");
      try {
        final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          setState(() {
            _sentFriendRequests = data.map((item) => FriendRequest.fromJson(item)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          print("Failed to load sent friend requests");
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print("Error: $e");
      }
    }
  }

  Future<void> acceptFriendRequest(int requestId) async {
    String? token = await SessionManager.loadToken();
    final url = Uri.parse("$FriendRequestAccept$requestId");

    try {
      final response = await http.post(url, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        setState(() {
          _friendRequests.removeWhere((req) => req.id == requestId);
        });
        print("Friend request accepted successfully");
      } else {
        print("Failed to accept friend request");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> rejectFriendRequest(int requestId) async {
    String? token = await SessionManager.loadToken();
    final url = Uri.parse("$FriendRequestReject$requestId");

    try {
      final response = await http.post(url, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        setState(() {
          _friendRequests.removeWhere((req) => req.id == requestId);
        });
        print("Friend request rejected successfully");
      } else {
        print("Failed to reject friend request");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context);
    final fontFamily = Provider.of<FontNotifier>(context).fontFamily;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(AppLocalizations.of(context).translate('friend_requests')),
            Spacer(),
            Text(
              " ${_friendRequests.length}",
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: theme.currentTheme.appBarTheme.backgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: theme.currentTheme.iconTheme.color,
        ),
      ),
      backgroundColor: theme.currentTheme.scaffoldBackgroundColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _friendRequests.length + _sentFriendRequests.length,
        itemBuilder: (context, index) {
          final friendRequest = index < _friendRequests.length
              ? _friendRequests[index]
              : _sentFriendRequests[index - _friendRequests.length];

          return FutureBuilder<ImageProvider>(
            future: loadImageService.fetchImage("${addresse}${friendRequest.sender.profilePicUrl}"),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 10,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      leading: const CircularProgressIndicator(),
                      title: Text(
                        "${friendRequest.sender.firstName} ${friendRequest.sender.lastName}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: fontFamily),
                      ),
                      subtitle: Text(friendRequest.status, style: TextStyle(fontFamily: fontFamily)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () => acceptFriendRequest(friendRequest.id),
                            color: Colors.green,
                            iconSize: 30,
                            splashRadius: 20,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => rejectFriendRequest(friendRequest.id),
                            color: Colors.red,
                            iconSize: 30,
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 10,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      leading: CircleAvatar(
                        backgroundImage: snapshot.data,
                        radius: 25,
                      ),
                      title: Text(
                        "${friendRequest.sender.firstName} ${friendRequest.sender.lastName}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: fontFamily),
                      ),
                      subtitle: Text(friendRequest.status, style: TextStyle(fontFamily: fontFamily)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () => acceptFriendRequest(friendRequest.id),
                            color: Colors.green,
                            iconSize: 30,
                            splashRadius: 20,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => rejectFriendRequest(friendRequest.id),
                            color: Colors.red,
                            iconSize: 30,
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 10,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                      radius: 25,
                    ),
                    title: Text(
                      "${friendRequest.sender.firstName} ${friendRequest.sender.lastName}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontFamily: fontFamily),
                    ),
                    subtitle: Text(friendRequest.status, style: TextStyle(fontFamily: fontFamily)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () => acceptFriendRequest(friendRequest.id),
                          color: Colors.green,
                          iconSize: 30,
                          splashRadius: 20,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => rejectFriendRequest(friendRequest.id),
                          color: Colors.red,
                          iconSize: 30,
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
