import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/api_service.dart';

class ShortsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<VideoModel> _shorts = [];
  bool _isLoading = false;
  int _currentIndex = 0;

  List<VideoModel> get shorts => _shorts;
  bool get isLoading => _isLoading;
  int get currentIndex => _currentIndex;

  ShortsProvider() {
    fetchShorts();
  }

  Future<void> fetchShorts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _shorts = await _apiService.getShortsVideos();
    } catch (e) {
      debugPrint('Error fetching shorts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void toggleLike(String shortId) {
    final index = _shorts.indexWhere((s) => s.id == shortId);
    if (index != -1) {
      final short = _shorts[index];
      final newIsLiked = !short.isLiked;
      _shorts[index] = short.copyWith(
        isLiked: newIsLiked,
        likes: newIsLiked ? short.likes + 1 : short.likes - 1,
      );
      notifyListeners();
    }
  }

  void toggleSubscribe(String channelId) {
    for (int i = 0; i < _shorts.length; i++) {
      if (_shorts[i].channelId == channelId) {
        _shorts[i] = _shorts[i].copyWith(isSubscribed: !_shorts[i].isSubscribed);
      }
    }
    notifyListeners();
  }
}
