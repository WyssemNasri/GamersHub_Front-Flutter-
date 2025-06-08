import 'package:flutter/material.dart';
import 'package:gamershub/Constant/constant.dart';
import 'package:provider/provider.dart';
import '../Providers/MessageProvider.dart';
import '../models/Message_Model.dart';
import '../services/LoadImageService.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final int senderId;
  final int receiverId;
  final String receiverName;
  final String? friendUrlPic;

  const ChatScreen({
    super.key,
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
    this.friendUrlPic,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final LoadImageService _imageService = LoadImageService();
  ImageProvider? _friendImage;
  Set<int> _visibleTimes = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<MessageProvider>(context, listen: false)
          .connect(widget.senderId, widget.receiverId);

      final image = await _imageService.fetchImage("$addresse${widget.friendUrlPic}");
      if (mounted) {
        setState(() => _friendImage = image);
      }
    });
  }

  @override
  void dispose() {
    Provider.of<MessageProvider>(context, listen: false).disconnect();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      final message = Message(
        senderId: widget.senderId,
        receiverId: widget.receiverId,
        content: content,
        createdAt: DateTime.now().toIso8601String(),
      );

      Provider.of<MessageProvider>(context, listen: false).sendMessage(message);
      _messageController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _showImage() {
    if (widget.friendUrlPic == null) return;

    if (_friendImage != null && _friendImage is MemoryImage) {
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
                  child: Image(
                    image: _friendImage!,
                    fit: BoxFit.contain,
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
    } else {
      _imageService.showFullScreenImage(context, widget.friendUrlPic!);
    }
  }



  bool _isNewDay(DateTime current, DateTime? previous) {
    if (previous == null) return true;
    return current.year != previous.year ||
        current.month != previous.month ||
        current.day != previous.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: _showImage,
              child: CircleAvatar(
                backgroundImage: _friendImage ?? const AssetImage('assets/images/default_profile_picture.png'),
                radius: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.receiverName),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<MessageProvider>(
        builder: (context, messageProvider, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

          DateTime? lastDate;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messageProvider.messages.length,
                    itemBuilder: (context, index) {
                      final msg = messageProvider.messages[index];
                      final isMe = msg.senderId == widget.senderId;
                      final msgDate = DateTime.parse(msg.createdAt);
                      final formattedTime = DateFormat('HH:mm').format(msgDate);
                      final today = DateTime.now();
                      final yesterday = today.subtract(const Duration(days: 1));

                      String formattedDate = DateFormat('dd MMM yyyy').format(msgDate);
                      if (msgDate.year == today.year &&
                          msgDate.month == today.month &&
                          msgDate.day == today.day) {
                        formattedDate = "Aujourd'hui";
                      } else if (msgDate.year == yesterday.year &&
                          msgDate.month == yesterday.month &&
                          msgDate.day == yesterday.day) {
                        formattedDate = "Hier";
                      }

                      final showDateSeparator = _isNewDay(msgDate, lastDate);
                      lastDate = msgDate;

                      return Column(
                        crossAxisAlignment:
                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (showDateSeparator)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: Container(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                            onLongPress: () {
                              setState(() {
                                if (_visibleTimes.contains(index)) {
                                  _visibleTimes.remove(index);
                                } else {
                                  _visibleTimes.add(index);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (!isMe)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundImage: _friendImage ??
                                            const AssetImage(
                                                'assets/images/default_profile_picture.png'),
                                      ),
                                    ),
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? Colors.deepPurpleAccent.shade200
                                            : Colors.grey.shade800,
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
                                            msg.content,
                                            style:
                                            const TextStyle(color: Colors.white, fontSize: 15),
                                          ),
                                          if (_visibleTimes.contains(index))
                                            Padding(
                                              padding: const EdgeInsets.only(top: 6),
                                              child: Text(
                                                formattedTime,
                                                style: const TextStyle(
                                                    color: Colors.white60, fontSize: 10),
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

                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.grey[900],
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Tapez votre message...",
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.deepPurpleAccent),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
