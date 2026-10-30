import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_model.dart';
import '../providers/player_provider.dart';
import '../providers/library_provider.dart';
import '../screens/video_player_screen.dart';

class VideoCard extends StatelessWidget {
  final VideoModel video;
  final bool showChannelAvatar;

  const VideoCard({
    super.key,
    required this.video,
    this.showChannelAvatar = true,
  });

  void _openVideo(BuildContext context) {
    context.read<PlayerProvider>().playVideo(video);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(video: video),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    final libraryProvider = context.read<LibraryProvider>();
    final isSaved = libraryProvider.isWatchLater(video.id);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Icon(
                  isSaved ? Icons.check_circle : Icons.watch_later_outlined,
                  color: isSaved ? Colors.red : null,
                ),
                title: Text(isSaved ? 'Remove from Watch Later' : 'Save to Watch Later'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  libraryProvider.toggleWatchLater(video);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isSaved ? 'Removed from Watch Later' : 'Saved to Watch Later',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('Save to playlist'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to Favorites playlist')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Share link copied for ${video.title}')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.not_interested),
                title: const Text('Not interested'),
                onTap: () => Navigator.pop(bottomSheetContext),
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Report'),
                onTap: () => Navigator.pop(bottomSheetContext),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => _openVideo(context),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with duration badge
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: isDark ? const Color(0xFF212121) : const Color(0xFFE0E0E0),
                    child: Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: Icon(Icons.play_circle_outline, size: 48, color: Colors.white70),
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: isDark ? const Color(0xFF212121) : const Color(0xFFE0E0E0),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xCC000000),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video.duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Video Details Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showChannelAvatar) ...[
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey.shade800,
                      backgroundImage: NetworkImage(video.channelAvatarUrl),
                      onBackgroundImageError: (_, _) {},
                      child: video.channelAvatarUrl.isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${video.channelName} • ${video.viewCount} • ${video.uploadDate}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    onPressed: () => _showMoreOptions(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
