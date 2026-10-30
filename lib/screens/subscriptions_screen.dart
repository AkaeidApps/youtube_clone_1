import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../providers/subscription_provider.dart';
import '../widgets/channel_tile.dart';
import '../widgets/video_card.dart';
import '../widgets/shimmer_skeleton.dart';
import 'search_screen.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  void _showAllChannelsModal(BuildContext context, SubscriptionProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Subscriptions',
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
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: provider.channels.length,
                    itemBuilder: (context, index) {
                      final channel = provider.channels[index];
                      return ChannelTile(
                        channel: channel,
                        onSubscribeToggle: () => provider.toggleSubscribe(channel.id),
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
    final subProvider = context.watch<SubscriptionProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filterPills = ['All', 'Today', 'Videos', 'Shorts', 'Live', 'Unwatched'];

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
              'Subscriptions',
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
        ],
      ),
      body: Column(
        children: [
          // Subscribed Channels Horizontal Story Bar
          Container(
            height: 96,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final ch in subProvider.channels)
                  ChannelStoryItem(
                    channel: ch,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Viewing ${ch.name}')),
                      );
                    },
                  ),
                // 'All' button
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextButton(
                      onPressed: () => _showAllChannelsModal(context, subProvider),
                      child: const Text('ALL', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Filters Row
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: filterPills.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final pill = filterPills[index];
                final isSelected = subProvider.selectedFilter == pill;

                return ChoiceChip(
                  label: Text(pill),
                  selected: isSelected,
                  onSelected: (_) => subProvider.selectFilter(pill),
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

          // Feed
          Expanded(
            child: subProvider.isLoading
                ? ListView.builder(
                    itemCount: 3,
                    itemBuilder: (_, _) => const VideoCardSkeleton(),
                  )
                : (subProvider.videos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.subscriptions_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No new videos from your subscriptions',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Subscribe to more channels to see their latest videos',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: subProvider.videos.length,
                        itemBuilder: (context, index) {
                          return VideoCard(video: subProvider.videos[index]);
                        },
                      )),
          ),
        ],
      ),
    );
  }
}
