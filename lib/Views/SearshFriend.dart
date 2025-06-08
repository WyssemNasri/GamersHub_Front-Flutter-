import 'package:flutter/material.dart';
import 'package:gamershub/Constant/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../Providers/FontNotifier.dart';
import '../../models/Person_Model.dart';
import '../../services/SessionManager.dart';
import '../Providers/ThemeNotifier.dart';
import '../Constant/app_localizations.dart';
import 'package:gamershub/services/LoadImageService.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FriendSearch extends StatefulWidget {
  @override
  State<FriendSearch> createState() => _FriendSearchState();
}

class _FriendSearchState extends State<FriendSearch> {
  List<Person> allUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      String? token = await SessionManager.loadToken();

      final response = await http.get(
        Uri.parse(allUsersendpoint),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          allUsers = data.map((user) => Person.fromJson(user)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load users");
      }
    } catch (e) {
      print("Error fetching users: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendInvitation(String receiverId) async {
    try {
      String? token = await SessionManager.loadToken();
      if (token == null) throw Exception("Token non trouvé");
      String? senderId = await SessionManager.loadId();

      final response = await http.post(
        Uri.parse(sendFriendRequestEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'senderId': senderId, 'receiverId': receiverId}),
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          response.statusCode == 200
              ? AppLocalizations.of(context).translate("invitation_sent")
              : AppLocalizations.of(context).translate("invitation_failed"),
        ),
        backgroundColor: response.statusCode == 200 ? Colors.green : Colors.red,
      ));
    } catch (e) {
      print("Error sending invitation: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final fontNotifier = Provider.of<FontNotifier>(context);
    final currentTheme = themeNotifier.currentTheme;
    final currentFont = fontNotifier.fontFamily;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_outlined, color: Colors.white),
        ),
        title: Text(
          AppLocalizations.of(context).translate("search_friends"),
          style: TextStyle(fontFamily: currentFont, fontWeight: FontWeight.bold),
        ),
        backgroundColor: currentTheme.appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color:Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: FriendSearchDelegate(allUsers, sendInvitation, currentFont),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : allUsers.isEmpty
          ? Center(
        child: Text(
          AppLocalizations.of(context).translate("no_users_found"),
          style: TextStyle(fontFamily: currentFont, fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: allUsers.length,
        itemBuilder: (context, index) {
          return _buildUserCard(allUsers[index], currentFont, currentTheme);
        },
      ),
    );
  }

  Widget _buildUserCard(Person user, String font, ThemeData theme) {
    LoadImageService loadImageService = LoadImageService();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: theme.cardColor,
        child: ListTile(
          contentPadding: EdgeInsets.all(15),
          leading: FutureBuilder<ImageProvider>(
            future: loadImageService.fetchImage('$addresse${user.profilePicUrl}'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return CircleAvatar(radius: 25, backgroundImage: snapshot.data);
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return CircleAvatar(radius: 25, child: CircularProgressIndicator(), backgroundColor: Colors.grey);
              } else {
                return CircleAvatar(radius: 25, child: Icon(Icons.person, color: Colors.white), backgroundColor: Colors.grey);
              }
            },
          ),
          title: Text(
            "${user.firstName} ${user.lastName}",
            style: TextStyle(fontFamily: font, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          trailing: ElevatedButton(
            onPressed: () => sendInvitation(user.id.toString()),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add, size: 20, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).translate("send_invitation"),
                  style: TextStyle(fontFamily: font, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FriendSearchDelegate extends SearchDelegate<Person> {
  final List<Person> allUsers;
  final Function(String) sendInvitation;
  final String font;
  late stt.SpeechToText _speech;
  bool _isListening = false;

  FriendSearchDelegate(this.allUsers, this.sendInvitation, this.font) {
    _speech = stt.SpeechToText();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.mic),
        onPressed: () async {
          if (!_isListening) {
            bool available = await _speech.initialize();
            if (available) {
              _isListening = true;
              _speech.listen(onResult: (val) {
                query = val.recognizedWords;
              });
            }
          } else {
            _speech.stop();
            _isListening = false;
          }
        },
      ),
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, Person(id: 0, firstName: '', lastName: '')),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Person> filtered = allUsers
        .where((user) => user.firstName.toLowerCase().contains(query.toLowerCase()) ||
        user.lastName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final user = filtered[index];
        return ListTile(
          title: Text("${user.firstName} ${user.lastName}", style: TextStyle(fontFamily: font)),
          leading: FutureBuilder<ImageProvider>(
            future: LoadImageService().fetchImage('$addresse${user.profilePicUrl}'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return CircleAvatar(radius: 20, backgroundImage: snapshot.data);
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return CircleAvatar(radius: 20, child: CircularProgressIndicator(), backgroundColor: Colors.grey);
              } else {
                return CircleAvatar(radius: 20, child: Icon(Icons.person, color: Colors.white), backgroundColor: Colors.grey);
              }
            },
          ),
          trailing: IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () => sendInvitation(user.id.toString()),
          ),
        );
      },
    );
  }
}
