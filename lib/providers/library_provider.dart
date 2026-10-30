import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/storage_service.dart';

class LibraryProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<VideoModel> get history => _storageService.history;
  List<VideoModel> get watchLater => _storageService.watchLater;
  List<VideoModel> get likedVideos => _storageService.likedVideos;

  final List<String> _playlists = [
    'Favorites',
    'Coding Tutorials',
    'Chill & Relaxation',
  ];

  List<String> get playlists => _playlists;

  void addToHistory(VideoModel video) {
    _storageService.addToHistory(video);
    notifyListeners();
  }

  void clearHistory() {
    _storageService.clearHistory();
    notifyListeners();
  }

  void toggleWatchLater(VideoModel video) {
    _storageService.toggleWatchLater(video);
    notifyListeners();
  }

  bool isWatchLater(String videoId) {
    return _storageService.isWatchLater(videoId);
  }

  void toggleLiked(VideoModel video) {
    _storageService.toggleLiked(video);
    notifyListeners();
  }

  bool isLiked(String videoId) {
    return _storageService.isLiked(videoId);
  }

  void createPlaylist(String name) {
    if (name.trim().isNotEmpty && !_playlists.contains(name.trim())) {
      _playlists.add(name.trim());
      notifyListeners();
    }
  }
}
