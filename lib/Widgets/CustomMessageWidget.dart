import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Message_Model.dart';

class CustomMessageWidget extends StatelessWidget {
  final Message message;
  final bool isMe;
  final ImageProvider? friendImage;
  final bool showTime;
  final bool showDateSeparator;
  final String formattedDate;
  final VoidCallback onLongPress;

  const CustomMessageWidget({
    super.key,
    required this.message,
    required this.isMe,
    required this.friendImage,
    required this.showTime,
    required this.showDateSeparator,
    required this.formattedDate,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final msgDate = DateTime.parse(message.createdAt);
    final formattedTime = DateFormat('HH:mm').format(msgDate);

    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showDateSeparator)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
          ),
        GestureDetector(
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: friendImage ??
                          const AssetImage('assets/images/default_profile_picture.png'),
                    ),
                  ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.deepPurpleAccent.shade200 : Colors.grey.shade800,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isMe ? 12 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        if (showTime)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              formattedTime,
                              style: const TextStyle(color: Colors.white60, fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
