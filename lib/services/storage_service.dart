import '../models/video_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final List<VideoModel> _history = [];
  final List<VideoModel> _watchLater = [];
  final List<VideoModel> _likedVideos = [];
  final Set<String> _subscribedChannelIds = {'c1', 'c2', 'c3'};
  final List<String> _searchHistory = [
    'Flutter 3 tutorial',
    'Lofi hip hop beats',
    'Unreal Engine 5 games',
    'Dart clean architecture',
  ];

  // History
  List<VideoModel> get history => List.unmodifiable(_history);
  void addToHistory(VideoModel video) {
    _history.removeWhere((v) => v.id == video.id);
    _history.insert(0, video);
  }

  void clearHistory() {
    _history.clear();
  }

  // Watch Later
  List<VideoModel> get watchLater => List.unmodifiable(_watchLater);
  bool isWatchLater(String videoId) => _watchLater.any((v) => v.id == videoId);
  void toggleWatchLater(VideoModel video) {
    if (isWatchLater(video.id)) {
      _watchLater.removeWhere((v) => v.id == video.id);
    } else {
      _watchLater.insert(0, video);
    }
  }

  // Liked Videos
  List<VideoModel> get likedVideos => List.unmodifiable(_likedVideos);
  bool isLiked(String videoId) => _likedVideos.any((v) => v.id == videoId);
  void toggleLiked(VideoModel video) {
    if (isLiked(video.id)) {
      _likedVideos.removeWhere((v) => v.id == video.id);
    } else {
      _likedVideos.insert(0, video);
    }
  }

  // Subscriptions
  bool isSubscribed(String channelId) => _subscribedChannelIds.contains(channelId);
  void toggleSubscription(String channelId) {
    if (_subscribedChannelIds.contains(channelId)) {
      _subscribedChannelIds.remove(channelId);
    } else {
      _subscribedChannelIds.add(channelId);
    }
  }

  // Search History
  List<String> get searchHistory => List.unmodifiable(_searchHistory);
  void addSearchQuery(String query) {
    final clean = query.trim();
    if (clean.isEmpty) return;
    _searchHistory.removeWhere((q) => q.toLowerCase() == clean.toLowerCase());
    _searchHistory.insert(0, clean);
  }

  void removeSearchQuery(String query) {
    _searchHistory.remove(query);
  }

  void clearSearchHistory() {
    _searchHistory.clear();
  }
}
