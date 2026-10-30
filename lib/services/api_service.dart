import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/video_model.dart';
import '../models/comment_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Mock Videos
  final List<VideoModel> _mockVideos = [
    VideoModel(
      id: 'v1',
      title: 'Flutter 3 Full Course 2026 - Build 10 Production Apps',
      description:
          'Learn Flutter from scratch and build production-ready mobile, web, and desktop apps with clean architecture, state management, and modern design.',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=800&q=80',
      duration: '42:15',
      viewCount: '1.4M views',
      uploadDate: '3 days ago',
      channelId: 'c1',
      channelName: 'Flutter Masterclass',
      channelAvatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
      subscriberCount: '850K subscribers',
      likes: 64200,
      dislikes: 120,
      commentCount: 1420,
      tags: ['Flutter', 'Coding', 'Tech'],
    ),
    VideoModel(
      id: 'v2',
      title: 'Chill Lo-Fi Beats to Relax / Study / Code to [24/7 Live Stream]',
      description:
          'Peaceful and relaxing lofi hip hop beats for studying, sleeping, and deep focus coding sessions.',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?auto=format&fit=crop&w=800&q=80',
      duration: '1:15:30',
      viewCount: '5.8M views',
      uploadDate: '1 week ago',
      channelId: 'c2',
      channelName: 'Lofi Chill Station',
      channelAvatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
      subscriberCount: '3.2M subscribers',
      likes: 240000,
      dislikes: 540,
      commentCount: 8900,
      tags: ['Music', 'Live'],
    ),
    VideoModel(
      id: 'v3',
      title: 'Building a Full-Stack YouTube Clone in Flutter with Provider & REST APIs',
      description:
          'Step-by-step tutorial on crafting an ultra responsive YouTube application with custom video controls, bottom sheets, search, and dynamic playlists.',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80',
      duration: '28:40',
      viewCount: '480K views',
      uploadDate: '2 weeks ago',
      channelId: 'c3',
      channelName: 'DevPulse Academy',
      channelAvatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80',
      subscriberCount: '410K subscribers',
      likes: 31200,
      dislikes: 80,
      commentCount: 950,
      tags: ['Flutter', 'Coding', 'Tech'],
    ),
    VideoModel(
      id: 'v4',
      title: 'Top 10 Unreal Engine 5 Next-Gen Games Coming in 2026',
      description:
          'Take an exclusive first look at breathtaking photorealistic gameplay footage running on next-generation graphics hardware.',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&w=800&q=80',
      duration: '18:02',
      viewCount: '2.1M views',
      uploadDate: '4 days ago',
      channelId: 'c4',
      channelName: 'IGN GameZone',
      channelAvatarUrl:
          'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=150&q=80',
      subscriberCount: '12M subscribers',
      likes: 110000,
      dislikes: 1200,
      commentCount: 4300,
      tags: ['Gaming', 'Trending'],
    ),
    VideoModel(
      id: 'v5',
      title: 'The Future of AI Hardware: Quantum Chips & Neural Processing Units',
      description:
          'An in-depth breakdown of how silicon architecture is evolving to handle massive multimodal neural network inference on edge devices.',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=800&q=80',
      duration: '22:18',
      viewCount: '780K views',
      uploadDate: '5 days ago',
      channelId: 'c5',
      channelName: 'TechVisionary',
      channelAvatarUrl:
          'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=150&q=80',
      subscriberCount: '1.9M subscribers',
      likes: 54000,
      dislikes: 310,
      commentCount: 1600,
      tags: ['Tech', 'News'],
    ),
    VideoModel(
      id: 'v6',
      title: 'Deep Work Podcast #84: Maximizing Developer Productivity and Focus',
      description:
          'Discussion with senior staff engineers on managing distractions, building high-throughput systems, and maintaining work-life balance.',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1478737270239-2f02b77fc618?auto=format&fit=crop&w=800&q=80',
      duration: '54:10',
      viewCount: '320K views',
      uploadDate: '6 days ago',
      channelId: 'c6',
      channelName: 'The Modern Coder',
      channelAvatarUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
      subscriberCount: '620K subscribers',
      likes: 22000,
      dislikes: 90,
      commentCount: 780,
      tags: ['Podcasts', 'Coding'],
    ),
  ];

  // Mock Shorts
  final List<VideoModel> _mockShorts = [
    VideoModel(
      id: 's1',
      title: 'Flutter Animation Trick you definitely missed! #flutter #shorts #dev',
      description: 'Quick tip on using AnimatedBuilder for 60fps buttery smooth UI transitions.',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=600&q=80',
      duration: '0:45',
      viewCount: '890K views',
      uploadDate: '1 day ago',
      channelId: 'c1',
      channelName: 'Flutter Masterclass',
      channelAvatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
      subscriberCount: '850K subscribers',
      likes: 78000,
      isShort: true,
      commentCount: 1250,
      tags: ['Flutter', 'Shorts'],
    ),
    VideoModel(
      id: 's2',
      title: 'Insane Speedrun World Record in 2026! 😱🔥 #gaming #speedrun #epic',
      description: 'Check out this pixel-perfect skip that shaved 4 seconds off the previous record!',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1538481199705-c710c4e965fc?auto=format&fit=crop&w=600&q=80',
      duration: '0:30',
      viewCount: '2.4M views',
      uploadDate: '2 days ago',
      channelId: 'c4',
      channelName: 'IGN GameZone',
      channelAvatarUrl:
          'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=150&q=80',
      subscriberCount: '12M subscribers',
      likes: 195000,
      isShort: true,
      commentCount: 3400,
      tags: ['Gaming', 'Shorts'],
    ),
    VideoModel(
      id: 's3',
      title: 'Satisfying Coding Setup Aesthetic Desk Tour ✨💻 #setup #tech #vibes',
      description: 'Clean minimalist developer desk with ultra-wide monitor and mechanical keyboard.',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?auto=format&fit=crop&w=600&q=80',
      duration: '0:50',
      viewCount: '1.2M views',
      uploadDate: '3 days ago',
      channelId: 'c5',
      channelName: 'TechVisionary',
      channelAvatarUrl:
          'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=150&q=80',
      subscriberCount: '1.9M subscribers',
      likes: 112000,
      isShort: true,
      commentCount: 980,
      tags: ['Tech', 'Shorts'],
    ),
  ];

  // Mock Channels
  final List<ChannelModel> _mockChannels = [
    ChannelModel(
      id: 'c1',
      name: 'Flutter Masterclass',
      handle: '@flutter_masterclass',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
      bannerUrl:
          'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?auto=format&fit=crop&w=800&q=80',
      subscriberCount: '850K',
      videoCount: 145,
      isSubscribed: true,
      hasUnseenVideos: true,
    ),
    ChannelModel(
      id: 'c2',
      name: 'Lofi Chill Station',
      handle: '@lofichillstation',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
      bannerUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
      subscriberCount: '3.2M',
      videoCount: 310,
      isSubscribed: true,
      hasUnseenVideos: false,
    ),
    ChannelModel(
      id: 'c3',
      name: 'DevPulse Academy',
      handle: '@devpulse',
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80',
      bannerUrl:
          'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=800&q=80',
      subscriberCount: '410K',
      videoCount: 88,
      isSubscribed: true,
      hasUnseenVideos: true,
    ),
    ChannelModel(
      id: 'c4',
      name: 'IGN GameZone',
      handle: '@igngamezone',
      avatarUrl:
          'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=150&q=80',
      bannerUrl:
          'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&w=800&q=80',
      subscriberCount: '12M',
      videoCount: 2400,
      isSubscribed: false,
      hasUnseenVideos: false,
    ),
  ];

  // Mock Comments
  final Map<String, List<CommentModel>> _mockComments = {
    'v1': [
      CommentModel(
        id: 'cm1',
        videoId: 'v1',
        userName: 'Alex Johnson',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80',
        text: 'This is hands down the best Flutter architecture explanation on YouTube! Thank you!',
        timestamp: '2 days ago',
        likes: 342,
      ),
      CommentModel(
        id: 'cm2',
        videoId: 'v1',
        userName: 'Sophia Martinez',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80',
        text: 'The Provider state management section saved my project from messy spaghetti code.',
        timestamp: '1 day ago',
        likes: 128,
      ),
      CommentModel(
        id: 'cm3',
        videoId: 'v1',
        userName: 'David Chen',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1527980965255-d3b416303d12?auto=format&fit=crop&w=100&q=80',
        text: 'Please make a dedicated video on video players and background audio services next!',
        timestamp: '18 hours ago',
        likes: 74,
      ),
    ],
  };

  /// Searches videos using the official YouTube Data API v3:
  /// `https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&q=$query&maxResults=20&key=YOUR_API_KEY`
  /// If the API key is not yet configured or quota is exceeded, seamlessly falls back to local data.
  Future<List<VideoModel>> searchVideos(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    // Check if API key is provided
    if (AppConstants.youtubeApiKey != 'YOUR_API_KEY' &&
        AppConstants.youtubeApiKey.isNotEmpty) {
      try {
        final res = await http.get(Uri.parse(
          'https://www.googleapis.com/youtube/v3/search'
          '?part=snippet&type=video&q=${Uri.encodeComponent(cleanQuery)}&maxResults=20&key=${AppConstants.youtubeApiKey}',
        ));

        if (res.statusCode == 200) {
          final decoded = jsonDecode(res.body);
          if (decoded['items'] != null) {
            final items = decoded['items'] as List;
            final results = items
                .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
                .toList();
            if (results.isNotEmpty) {
              return results;
            }
          }
        } else {
          debugPrint('YouTube API response error: ${res.statusCode} -> ${res.body}');
        }
      } catch (e) {
        debugPrint('YouTube Data API search exception: $e');
      }
    }

    // Fallback to local / mock results
    await Future.delayed(const Duration(milliseconds: 250));
    final lower = cleanQuery.toLowerCase();
    return _mockVideos
        .where((v) =>
            v.title.toLowerCase().contains(lower) ||
            v.channelName.toLowerCase().contains(lower) ||
            v.description.toLowerCase().contains(lower) ||
            v.tags.any((t) => t.toLowerCase().contains(lower)))
        .toList();
  }

  /// Direct method for fetching from YouTube Data API v3 with any custom API key:
  Future<List<VideoModel>> searchYouTubeApi(String query, {String? apiKey}) async {
    final key = apiKey ?? AppConstants.youtubeApiKey;
    final res = await http.get(Uri.parse(
      'https://www.googleapis.com/youtube/v3/search'
      '?part=snippet&type=video&q=${Uri.encodeComponent(query)}&maxResults=20&key=$key',
    ));
    final items = jsonDecode(res.body)['items'] as List;
    return items.map((e) => VideoModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<VideoModel>> getHomeVideos({String category = 'All'}) async {
    // If YouTube API Key is configured, search live videos for the selected category
    if (AppConstants.youtubeApiKey != 'YOUR_API_KEY' &&
        AppConstants.youtubeApiKey.isNotEmpty) {
      try {
        final queryParam = category == 'All' ? 'Trending' : category;
        final res = await http.get(Uri.parse(
          'https://www.googleapis.com/youtube/v3/search'
          '?part=snippet&type=video&q=${Uri.encodeComponent(queryParam)}&maxResults=20&key=${AppConstants.youtubeApiKey}',
        ));
        if (res.statusCode == 200) {
          final decoded = jsonDecode(res.body);
          if (decoded['items'] != null) {
            final items = decoded['items'] as List;
            final videos = items
                .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
                .toList();
            if (videos.isNotEmpty) {
              return videos;
            }
          }
        }
      } catch (e) {
        debugPrint('Error fetching live YouTube home videos: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (category == 'All') {
      return List.from(_mockVideos);
    }
    return _mockVideos
        .where((v) => v.tags.any((t) => t.toLowerCase() == category.toLowerCase()))
        .toList();
  }

  Future<List<VideoModel>> getShortsVideos() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_mockShorts);
  }

  Future<List<ChannelModel>> getSubscribedChannels() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockChannels.where((c) => c.isSubscribed).toList();
  }

  Future<List<CommentModel>> getVideoComments(String videoId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockComments[videoId] ?? [
      CommentModel(
        id: 'cm_default',
        videoId: videoId,
        userName: 'Community Member',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80',
        text: 'Awesome video! Keep making great content.',
        timestamp: 'Just now',
        likes: 12,
      ),
    ];
  }

  Future<CommentModel> addComment(String videoId, String text) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final newComment = CommentModel(
      id: 'cm_${DateTime.now().millisecondsSinceEpoch}',
      videoId: videoId,
      userName: 'You',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80',
      text: text,
      timestamp: 'Just now',
      likes: 0,
    );
    _mockComments.putIfAbsent(videoId, () => []).insert(0, newComment);
    return newComment;
  }
}
