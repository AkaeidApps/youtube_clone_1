import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_model.dart';
import '../providers/player_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/video_card.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoModel video;

  const VideoPlayerScreen({
    super.key,
    required this.video,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _isDescriptionExpanded = false;
  bool _showControls = true;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  void _showCommentsModal(BuildContext context) {
    final playerProvider = context.read<PlayerProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (ctx, scrollController) {
              return Consumer<PlayerProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Comments (${provider.comments.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(modalContext),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: provider.comments.isEmpty
                            ? const Center(
                                child: Text('No comments yet. Be the first to comment!'),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: provider.comments.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final comment = provider.comments[index];
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundImage: NetworkImage(comment.userAvatarUrl),
                                        onBackgroundImageError: (_, _) {},
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  comment.userName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  comment.timestamp,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              comment.text,
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.thumb_up_alt_outlined,
                                                  size: 14,
                                                  color: Colors.grey.shade500,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${comment.likes}',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Icon(
                                                  Icons.thumb_down_alt_outlined,
                                                  size: 14,
                                                  color: Colors.grey.shade500,
                                                ),
                                                const SizedBox(width: 16),
                                                Icon(
                                                  Icons.reply,
                                                  size: 14,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                      const Divider(height: 1),
                      // Input bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              child: Icon(Icons.person, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                decoration: const InputDecoration(
                                  hintText: 'Add a comment...',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.blueAccent),
                              onPressed: () {
                                if (_commentController.text.trim().isNotEmpty) {
                                  playerProvider.addComment(_commentController.text);
                                  _commentController.clear();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final video = player.currentVideo ?? widget.video;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeProvider = context.watch<HomeProvider>();
    final relatedVideos = homeProvider.videos.where((v) => v.id != video.id).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Video Player Container
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Video Thumbnail background
                  Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                  ),

                  // Controls Overlay
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showControls = !_showControls;
                      });
                    },
                    child: Container(
                      color: _showControls ? const Color(0x8C000000) : Colors.transparent,
                      child: _showControls
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Top controls
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.keyboard_arrow_down,
                                          color: Colors.white, size: 28),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.closed_caption_outlined,
                                          color: Colors.white),
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.settings_outlined,
                                          color: Colors.white),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),

                                // Center controls (Play/Pause, Rewind, Fast Forward)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.replay_10,
                                          size: 36, color: Colors.white),
                                      onPressed: () {
                                        final newPos = player.currentPosition -
                                            const Duration(seconds: 10);
                                        player.seekTo(
                                          newPos < Duration.zero ? Duration.zero : newPos,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 32),
                                    GestureDetector(
                                      onTap: player.togglePlayPause,
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: const BoxDecoration(
                                          color: Color(0x99000000),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          player.isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 32),
                                    IconButton(
                                      icon: const Icon(Icons.forward_10,
                                          size: 36, color: Colors.white),
                                      onPressed: () {
                                        player.seekTo(
                                          player.currentPosition + const Duration(seconds: 10),
                                        );
                                      },
                                    ),
                                  ],
                                ),

                                // Bottom timeline and duration
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        _formatDuration(player.currentPosition),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Text(
                                        ' / ',
                                        style: TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                      Text(
                                        _formatDuration(player.totalDuration),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.fullscreen,
                                            color: Colors.white, size: 24),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),

                  // Progress Bar at bottom of video
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        trackHeight: 2,
                        activeTrackColor: Colors.red,
                        inactiveTrackColor: Colors.white30,
                        thumbColor: Colors.red,
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                      ),
                      child: Slider(
                        value: player.currentPosition.inSeconds
                            .toDouble()
                            .clamp(0.0, player.totalDuration.inSeconds.toDouble()),
                        max: player.totalDuration.inSeconds > 0
                            ? player.totalDuration.inSeconds.toDouble()
                            : 1.0,
                        onChanged: (value) {
                          player.seekTo(Duration(seconds: value.toInt()));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Video Details & Related Videos
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      video.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                  ),

                  // Views, Date & expandable description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDescriptionExpanded = !_isDescriptionExpanded;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${video.viewCount}  ${video.uploadDate}',
                                style: TextStyle(
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isDescriptionExpanded ? '...less' : '...more',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (_isDescriptionExpanded) ...[
                            const SizedBox(height: 8),
                            Text(
                              video.description,
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade300 : Colors.black87,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              children: video.tags
                                  .map((tag) => Text(
                                        '#$tag',
                                        style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 12,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Channel Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(video.channelAvatarUrl),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.channelName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                video.subscriberCount,
                                style: TextStyle(
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: player.toggleSubscribe,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: video.isSubscribed
                                ? (isDark ? const Color(0xFF272727) : const Color(0xFFE5E5E5))
                                : Colors.red,
                            foregroundColor: video.isSubscribed
                                ? (isDark ? Colors.white : Colors.black87)
                                : Colors.white,
                            shape: const StadiumBorder(),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          child: Text(
                            video.isSubscribed ? 'Subscribed' : 'Subscribe',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Actions Horizontal Scroll (Like/Dislike, Share, Remix, Download)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Joined Like/Dislike Pill
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF272727) : const Color(0xFFEFEFEF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: player.toggleLike,
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        video.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                        size: 18,
                                        color: video.isLiked ? Colors.blueAccent : null,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${video.likes}',
                                        style: const TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.grey.shade600,
                              ),
                              InkWell(
                                onTap: player.toggleDislike,
                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Icon(
                                    video.isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                                    size: 18,
                                    color: video.isDisliked ? Colors.redAccent : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        _buildActionPill(
                          context,
                          icon: Icons.share_outlined,
                          label: 'Share',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Sharing ${video.title}')),
                            );
                          },
                        ),
                        const SizedBox(width: 8),

                        _buildActionPill(
                          context,
                          icon: Icons.sync,
                          label: 'Remix',
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),

                        _buildActionPill(
                          context,
                          icon: Icons.download_outlined,
                          label: 'Download',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Video downloading...')),
                            );
                          },
                        ),
                        const SizedBox(width: 8),

                        _buildActionPill(
                          context,
                          icon: Icons.playlist_add,
                          label: 'Save',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Saved to Watch Later')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Comments Preview Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: InkWell(
                      onTap: () => _showCommentsModal(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF272727) : const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Comments',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${video.commentCount}',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 12,
                                  backgroundImage: NetworkImage(
                                    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    player.comments.isNotEmpty
                                        ? player.comments.first.text
                                        : 'Add a comment...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.grey.shade300 : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1),

                  // Up Next / Related Videos
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'Related Videos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),

                  for (final rel in relatedVideos) VideoCard(video: rel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF272727) : const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
