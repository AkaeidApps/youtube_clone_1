import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import 'home_screen.dart';
import 'shorts_screen.dart';
import 'subscriptions_screen.dart';
import 'library_screen.dart';
import 'video_player_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ShortsScreen(),
    SubscriptionsScreen(),
    LibraryScreen(),
  ];

  void _showCreateModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Create',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF272727),
                  child: Icon(Icons.flash_on, color: Colors.white),
                ),
                title: const Text('Create a Short'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening Short Camera...')),
                  );
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF272727),
                  child: Icon(Icons.upload, color: Colors.white),
                ),
                title: const Text('Upload a video'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening Gallery...')),
                  );
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF272727),
                  child: Icon(Icons.live_tv, color: Colors.white),
                ),
                title: const Text('Go live'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Starting Live Stream...')),
                  );
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF272727),
                  child: Icon(Icons.edit_note, color: Colors.white),
                ),
                title: const Text('Create a post'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Creating community post...')),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    final currentVideo = playerProvider.currentVideo;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Mini Player Overlay above bottom bar
          if (currentVideo != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerScreen(video: currentVideo),
                    ),
                  );
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF212121) : const Color(0xFFF2F2F2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Mini progress line
                      LinearProgressIndicator(
                        value: playerProvider.totalDuration.inSeconds > 0
                            ? (playerProvider.currentPosition.inSeconds /
                                playerProvider.totalDuration.inSeconds)
                            : 0.0,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                        minHeight: 2,
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                currentVideo.thumbnailUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentVideo.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    currentVideo.channelName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                playerProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 24,
                              ),
                              onPressed: playerProvider.togglePlayPause,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: playerProvider.closePlayer,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex >= 2 ? _currentIndex + 1 : _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: isDark ? Colors.white : Colors.black,
        unselectedItemColor: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          if (index == 2) {
            _showCreateModal();
          } else if (index > 2) {
            setState(() {
              _currentIndex = index - 1;
            });
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow_outlined),
            activeIcon: Icon(Icons.play_arrow),
            label: 'Shorts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 36),
            activeIcon: Icon(Icons.add_circle, size: 36),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.subscriptions_outlined),
            activeIcon: Icon(Icons.subscriptions),
            label: 'Subscriptions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_outlined),
            activeIcon: Icon(Icons.video_library),
            label: 'You',
          ),
        ],
      ),
    );
  }
}
