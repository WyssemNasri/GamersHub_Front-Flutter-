import 'package:flutter/material.dart';
import 'package:gamershub/models/Comment_Model.dart';
import 'package:gamershub/services/CommentService.dart';
import 'package:gamershub/services/LoadImageService.dart';
import 'package:provider/provider.dart';
import '../Constant/app_localizations.dart';
import '../Constant/constant.dart';
import '../Providers/FontNotifier.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/speech_service.dart';

void customShowCommentBottomSheet(BuildContext context, List<CommentModel> comments, int postid) {
  final loadImageService = LoadImageService();
  final commentService = CommentService();
  final theme = Theme.of(context);
  final localizations = AppLocalizations.of(context);
  final fontNotifier = Provider.of<FontNotifier>(context, listen: false);
  final fontFamily = fontNotifier.fontFamily;
  final TextEditingController commentController = TextEditingController();
  final SpeechService _speechService = SpeechService();
  bool _isListening = false;
  String _selectedLocale = 'fr-FR';

  void _handleMicPress() async {
    if (_isListening) {
      _speechService.stopListening();
      _isListening = false;
    } else {
      String? selected = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Choisir la langue du micro'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(title: Text('Français'), onTap: () => Navigator.pop(context, 'fr-FR')),
                ListTile(title: Text('English'), onTap: () => Navigator.pop(context, 'en-US')),
                ListTile(title: Text('العربية'), onTap: () => Navigator.pop(context, 'ar')),
              ],
            ),
          );
        },
      );

      if (selected != null) {
        _selectedLocale = selected;
        _isListening = true;
        await _speechService.startListening((text) {
          commentController.text = text;
          commentController.selection = TextSelection.fromPosition(TextPosition(offset: text.length));
        }, localeId: _selectedLocale);
      }
    }
  }

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    backgroundColor: theme.scaffoldBackgroundColor,
    isScrollControlled: true,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, controller) => Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      localizations.translate('comments'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: theme.iconTheme.color),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 24,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 1.5, height: 1),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.only(top: 10, bottom: 80),
                  itemCount: comments.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final person = comment.commentOwner;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<ImageProvider>(
                            future: loadImageService.fetchImage('$addresse${person.profilePicUrl}'),
                            builder: (context, snapshot) {
                              return CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: snapshot.hasData
                                    ? snapshot.data
                                    : const AssetImage('assets/images/default_profile_picture.png'),
                              );
                            },
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${person.firstName} ${person.lastName}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    fontFamily: fontFamily,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  comment.content,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    timeago.format(DateTime.parse(comment.createdAt)),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    border: Border(
                      top: BorderSide(color: theme.dividerColor, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                              icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.red),
                              onPressed: _handleMicPress,
                              splashRadius: 20,
                              padding: EdgeInsets.zero,
                            ),
                            hintText: localizations.translate('write_a_comment'),
                            hintStyle: TextStyle(
                              fontFamily: fontFamily,
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                            filled: true,
                            fillColor: theme.cardColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: theme.dividerColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
                            ),
                          ),
                          minLines: 1,
                          maxLines: 4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.send, color: theme.primaryColor),
                        onPressed: () async {
                          if (commentController.text.isNotEmpty) {
                            await commentService.add_comment(postid, commentController.text);
                            commentController.clear();
                            final updatedComments = await commentService.fetchCommentByPost(postid);
                            Navigator.pop(context);
                            customShowCommentBottomSheet(context, updatedComments, postid);
                          }
                        },
                        splashRadius: 24,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
