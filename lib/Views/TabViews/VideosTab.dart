import 'package:flutter/material.dart';
import 'package:gamershub/Constant/constant.dart';
import 'package:gamershub/services/post_service.dart';
import '../../models/Post_Model.dart';
import 'package:video_player/video_player.dart';
import '../../services/SessionManager.dart';

class VideosTab extends StatefulWidget {
  const VideosTab({super.key});

  @override
  State<VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<VideosTab> {
  final PostService postService = PostService();
  List<Post> videos = [];
  List<VideoPlayerController> controllers = [];
  bool isLoading = true;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  Future<void> loadVideos() async {
    String? token = await SessionManager.loadToken();
    List<Post> fetchedVideos = await postService.fetchFriendsVIdeos();

    for (var post in fetchedVideos) {
      if (post.urlMedia!.isNotEmpty) {
        final fullUrl = Uri.parse('${addresse}${post.urlMedia}');

        final controller = VideoPlayerController.networkUrl(
          fullUrl,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          httpHeaders: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        await controller.initialize();
        controllers.add(controller);
      } else {
        final fallback = VideoPlayerController.networkUrl(
          Uri.parse("http://example.com/fallback.mp4"),
        );
        await fallback.initialize();
        controllers.add(fallback);
      }
    }

    setState(() {
      videos = fetchedVideos;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildSideBar(Post post) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Bouton Like
        Column(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite, color: Colors.white, size: 32),
            ),
            Text(
              '${post.likeCount ?? 0}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Bouton Commentaire
        Column(
          children: [
            IconButton(
              onPressed: () {
                // Logique pour commentaires
              },
              icon: const Icon(Icons.comment, color: Colors.white, size: 32),
            ),
            Text(
              '${post.commentCount ?? 0}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Column(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.share, color: Colors.white, size: 32),
            ),
            const Text(
              'Share',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Bouton Musique (ou autre élément)
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white),
          ),
          child: const Icon(Icons.music_note, color: Colors.white, size: 24),
        ),
      ],
    );
  }

  Widget _buildUserInfo(Post post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nom d'utilisateur
        Text(
          '@${post.owner.firstName}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Description
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Text(
            post.description ?? 'No description',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),
        // Musique (ou autre élément)
        Row(
          children: [
            const Icon(Icons.music_note, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              'Original Sound',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (videos.isEmpty) {
      return const Center(
        child: Text(
          "No videos available",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return PageView.builder(
      itemCount: videos.length,
      scrollDirection: Axis.vertical,
      onPageChanged: (index) {
        // Pause la vidéo précédente et joue la nouvelle
        if (currentPage >= 0 && currentPage < controllers.length) {
          controllers[currentPage].pause();
        }
        setState(() {
          currentPage = index;
        });
        controllers[index].play();
        controllers[index].setLooping(true);
      },
      itemBuilder: (context, index) {
        final post = videos[index];
        final controller = controllers[index];

        return Stack(
          children: [
            // Vidéo plein écran
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (controller.value.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                  });
                },
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
            // Overlay sombre en bas pour mieux voir le texte
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Informations de l'utilisateur et description
            Positioned(
              bottom: 80,
              left: 16,
              child: _buildUserInfo(post),
            ),
            // Barre latérale avec boutons
            Positioned(
              bottom: 80,
              right: 16,
              child: _buildSideBar(post),
            ),
            // Photo de profil de l'utilisateur en haut à gauche
            Positioned(
              top: 40,
              left: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.pink, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        post.owner.profilePicUrl ??
                            'https://www.example.com/default_profile.jpg',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '@${post.owner.firstName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Indicateur de lecture/pause
            if (!controller.value.isPlaying)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
