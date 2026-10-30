import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'YouTube';

  // YouTube Data API v3 Configuration
  // Replace 'YOUR_API_KEY' with your actual Google Cloud YouTube Data API v3 key
  static const String youtubeApiKey = 'YOUR_API_KEY';
  static const String youtubeApiBaseUrl = 'https://www.googleapis.com/youtube/v3';

  // Colors
  static const Color primaryRed = Color(0xFFFF0000);
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF212121);
  static const Color darkCard = Color(0xFF282828);
  static const Color darkChip = Color(0xFF383838);

  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF2F2F2);
  static const Color lightCard = Color(0xFFE5E5E5);

  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFFAAAAAA);
  static const Color textDark = Color(0xFF0F0F0F);

  // Category tags
  static const List<String> categories = [
    'All',
    'Gaming',
    'Flutter',
    'Music',
    'Podcasts',
    'Tech',
    'Live',
    'Coding',
    'News',
    'Trending',
  ];

  // Dummy avatar
  static const String defaultUserAvatar =
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80';
}
