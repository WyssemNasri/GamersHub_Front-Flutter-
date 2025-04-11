import 'package:flutter/material.dart';
import 'package:gamershub/Constant/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../FontTheme/FontNotifier.dart';
import '../../languages/LanguageNotifier.dart';
import '../../models/Person.dart';
import '../../services/SessionManager.dart';
import '../../themes/ThemeNotifier.dart';
import '../languages/app_localizations.dart';

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
      if (token == null) {
        throw Exception("Token non trouvé");
      }

      String? senderId = await SessionManager.loadId();

      final response = await http.post(
        Uri.parse(sendFriendRequestEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'senderId': senderId,
          'receiverId': receiverId,
        }),
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
    final languageNotifier = Provider.of<LanguageNotifier>(context);
    final currentTheme = themeNotifier.currentTheme;
    final currentFont = fontNotifier.fontFamily;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_outlined, color: currentTheme.primaryColor),
        ),
        title: Text(
          AppLocalizations.of(context).translate("search_friends"),
          style: TextStyle(fontFamily: currentFont, fontWeight: FontWeight.bold),
        ),
        backgroundColor: currentTheme.appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: currentTheme.primaryColor),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          contentPadding: EdgeInsets.all(10),
          leading: CircleAvatar(
            backgroundImage: user.profilePicUrl != null ? NetworkImage(user.profilePicUrl!) : null,
            child: user.profilePicUrl == null ? Icon(Icons.person, color: Colors.grey[700]) : null,
          ),
          title: Text(
            "${user.firstName} ${user.lastName}",
            style: TextStyle(fontFamily: font, fontWeight: FontWeight.bold),
          ),
          trailing: ElevatedButton(
            onPressed: () => sendInvitation(user.id.toString()),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add, size: 18, color: Colors.white),
                SizedBox(width: 5),
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

  FriendSearchDelegate(this.allUsers, this.sendInvitation, this.font);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context));
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Person> filteredUsers = allUsers
        .where((user) => user.firstName.toLowerCase().contains(query.toLowerCase()) || user.lastName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        Person user = filteredUsers[index];
        return ListTile(
          title: Text("${user.firstName} ${user.lastName}", style: TextStyle(fontFamily: font)),
          leading: CircleAvatar(backgroundImage: user.profilePicUrl != null ? NetworkImage(user.profilePicUrl!) : null),
          trailing: IconButton(icon: Icon(Icons.person_add), onPressed: () => sendInvitation(user.id.toString())),
        );
      },
    );
  }
}