import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../providers/home_provider.dart';
import '../providers/shorts_provider.dart';
import '../widgets/video_card.dart';
import '../widgets/shimmer_skeleton.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final shortsProvider = context.watch<ShortsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppConstants.primaryRed,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 6),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cast),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Searching for Cast devices...')),
              );
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 14,
              backgroundImage: const NetworkImage(AppConstants.defaultUserAvatar),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Horizontal Category Filter Pills
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = AppConstants.categories[index];
                final isSelected = homeProvider.selectedCategory == category;

                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) => homeProvider.selectCategory(category),
                  selectedColor: isDark ? Colors.white : Colors.black,
                  backgroundColor: isDark ? const Color(0xFF272727) : const Color(0xFFF2F2F2),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? (isDark ? Colors.black : Colors.white)
                        : (isDark ? Colors.white : Colors.black),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide.none,
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),

          // Main Video Feed
          Expanded(
            child: homeProvider.isLoading
                ? ListView.builder(
                    itemCount: 4,
                    itemBuilder: (_, _) => const VideoCardSkeleton(),
                  )
                : RefreshIndicator(
                    onRefresh: homeProvider.refresh,
                    child: ListView.builder(
                      itemCount: homeProvider.videos.length + (shortsProvider.shorts.isNotEmpty ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Insert Shorts Shelf after 1st video
                        if (index == 1 && shortsProvider.shorts.isNotEmpty) {
                          return _buildShortsShelf(context, shortsProvider.shorts);
                        }

                        final videoIndex = (index > 1 && shortsProvider.shorts.isNotEmpty)
                            ? index - 1
                            : index;

                        if (videoIndex >= homeProvider.videos.length) {
                          return const SizedBox.shrink();
                        }

                        return VideoCard(video: homeProvider.videos[videoIndex]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortsShelf(BuildContext context, List shorts) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.flash_on, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Shorts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 240,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: shorts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final short = shorts[i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 140,
                    color: Colors.grey.shade900,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          short.thumbnailUrl,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color(0xCC000000),
                              ],
                              stops: [0.5, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          right: 8,
                          bottom: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                short.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                short.viewCount,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }
}
