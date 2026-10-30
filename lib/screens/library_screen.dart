import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import 'video_player_screen.dart';
import 'search_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  void _showCreatePlaylistDialog(BuildContext context, LibraryProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('New playlist'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter playlist title...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  provider.createPlaylist(controller.text.trim());
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final libProvider = context.watch<LibraryProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'You',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cast),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // User Profile Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundImage: NetworkImage(AppConstants.defaultUserAvatar),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Akaid Hossain',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@akaid_dev • Manage your Google Account',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Horizontal Actions (Switch Account, Google Account, Incognito)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildProfilePill(context, icon: Icons.switch_account, label: 'Switch account'),
                const SizedBox(width: 8),
                _buildProfilePill(context, icon: Icons.g_mobiledata, label: 'Google Account'),
                const SizedBox(width: 8),
                _buildProfilePill(context, icon: Icons.security, label: 'Turn on Incognito'),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),

          // History Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'History',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                if (libProvider.history.isNotEmpty)
                  InkWell(
                    onTap: libProvider.clearHistory,
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),

          if (libProvider.history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Videos you watch will appear here.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            )
          else
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: libProvider.history.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final video = libProvider.history[index];
                  return InkWell(
                    onTap: () {
                      context.read<PlayerProvider>().playVideo(video);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(video: video),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.network(
                                    video.thumbnailUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xCC000000),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    video.duration,
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            video.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            video.channelName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 16),
          const Divider(height: 1),

          // Playlists Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Playlists',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () => _showCreatePlaylistDialog(context, libProvider),
                  child: Row(
                    children: const [
                      Icon(Icons.add, size: 18, color: Colors.blueAccent),
                      SizedBox(width: 4),
                      Text(
                        'New playlist',
                        style: TextStyle(color: Colors.blueAccent, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Liked Videos Tile
          ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF272727) : const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.thumb_up, color: Colors.blueAccent),
            ),
            title: const Text('Liked videos', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${libProvider.likedVideos.length} videos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          // Watch Later Tile
          ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF272727) : const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.watch_later_outlined, color: Colors.orangeAccent),
            ),
            title: const Text('Watch later', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${libProvider.watchLater.length} videos • Private'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          // Custom Playlists
          for (final playlist in libProvider.playlists)
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF272727) : const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.playlist_play),
              ),
              title: Text(playlist, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Playlist'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),

          const Divider(height: 24),

          // Extra Utilities
          ListTile(
            leading: const Icon(Icons.slideshow_outlined),
            title: const Text('Your videos'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Downloads'),
            subtitle: const Text('20 videos'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.movie_creation_outlined),
            title: const Text('Your movies & TV'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help and feedback'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePill(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF272727) : const Color(0xFFE5E5E5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
