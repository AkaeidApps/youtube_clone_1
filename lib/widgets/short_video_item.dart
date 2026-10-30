import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_model.dart';
import '../providers/shorts_provider.dart';

class ShortVideoItem extends StatefulWidget {
  final VideoModel video;
  final bool isCurrent;

  const ShortVideoItem({
    super.key,
    required this.video,
    required this.isCurrent,
  });

  @override
  State<ShortVideoItem> createState() => _ShortVideoItemState();
}

class _ShortVideoItemState extends State<ShortVideoItem>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = true;
  late AnimationController _discController;

  @override
  void initState() {
    super.initState();
    _discController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _discController.dispose();
    super.dispose();
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1F1F1F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Comments ${widget.video.commentCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.white24),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: 4,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, i) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '@user_${i + 1}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  i == 0
                                      ? 'This is super clean and useful!'
                                      : 'Love the creativity here 🔥',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: const [
                              Icon(Icons.favorite_border, size: 16, color: Colors.white70),
                              SizedBox(height: 2),
                              Text('12', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final shortsProvider = context.watch<ShortsProvider>();

    return GestureDetector(
      onTap: () {
        setState(() {
          _isPlaying = !_isPlaying;
        });
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image / Video Mock
          Image.network(
            widget.video.thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: Colors.grey.shade900,
              child: const Center(
                child: Icon(Icons.play_arrow, size: 80, color: Colors.white30),
              ),
            ),
          ),

          // Gradient overlays
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x4D000000),
                  Colors.transparent,
                  Colors.transparent,
                  Color(0xCC000000),
                ],
                stops: [0.0, 0.2, 0.65, 1.0],
              ),
            ),
          ),

          // Paused Indicator
          if (!_isPlaying)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pause, size: 48, color: Colors.white),
              ),
            ),

          // Right Side Action Buttons
          Positioned(
            right: 12,
            bottom: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Like Button
                _buildActionButton(
                  icon: widget.video.isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                  iconColor: widget.video.isLiked ? Colors.white : Colors.white,
                  label: '${widget.video.likes}',
                  onTap: () => shortsProvider.toggleLike(widget.video.id),
                ),
                const SizedBox(height: 18),

                // Dislike Button
                _buildActionButton(
                  icon: Icons.thumb_down_alt_outlined,
                  label: 'Dislike',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feedback noted')),
                    );
                  },
                ),
                const SizedBox(height: 18),

                // Comments Button
                _buildActionButton(
                  icon: Icons.comment,
                  label: '${widget.video.commentCount}',
                  onTap: () => _showComments(context),
                ),
                const SizedBox(height: 18),

                // Share Button
                _buildActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sharing ${widget.video.title}')),
                    );
                  },
                ),
                const SizedBox(height: 18),

                // Remix Button
                _buildActionButton(
                  icon: Icons.sync,
                  label: 'Remix',
                  onTap: () {},
                ),
                const SizedBox(height: 18),

                // Rotating Disc
                RotationTransition(
                  turns: _discController,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white70, width: 2),
                      image: DecorationImage(
                        image: NetworkImage(widget.video.channelAvatarUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Left Channel & Video Details
          Positioned(
            left: 16,
            right: 80,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Channel Row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(widget.video.channelAvatarUrl),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.video.channelName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => shortsProvider.toggleSubscribe(widget.video.channelId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.video.isSubscribed ? Colors.white24 : Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.video.isSubscribed ? 'Subscribed' : 'Subscribe',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  widget.video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Audio ticker
                Row(
                  children: const [
                    Icon(Icons.music_note, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Original sound - Trending Audio',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
