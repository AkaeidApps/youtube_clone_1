import 'package:flutter/material.dart';
import '../models/video_model.dart';

class ChannelTile extends StatelessWidget {
  final ChannelModel channel;
  final VoidCallback onSubscribeToggle;

  const ChannelTile({
    super.key,
    required this.channel,
    required this.onSubscribeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade800,
            backgroundImage: NetworkImage(channel.avatarUrl),
            onBackgroundImageError: (_, _) {},
            child: channel.avatarUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  channel.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${channel.handle} • ${channel.subscriberCount} subscribers',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onSubscribeToggle,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: channel.isSubscribed
                    ? (isDark ? const Color(0xFF272727) : const Color(0xFFE5E5E5))
                    : (isDark ? Colors.white : Colors.black),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (channel.isSubscribed) ...[
                    const Icon(Icons.notifications_active_outlined, size: 16),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    channel.isSubscribed ? 'Subscribed' : 'Subscribe',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: channel.isSubscribed
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark ? Colors.black : Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChannelStoryItem extends StatelessWidget {
  final ChannelModel channel;
  final VoidCallback onTap;

  const ChannelStoryItem({
    super.key,
    required this.channel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 68,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: channel.hasUnseenVideos
                      ? const Color(0xFF065FD4)
                      : Colors.transparent,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage: NetworkImage(channel.avatarUrl),
                  ),
                ),
                if (channel.hasUnseenVideos)
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF065FD4),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              channel.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey.shade300 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
