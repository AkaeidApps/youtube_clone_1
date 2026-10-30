import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/api_service.dart';

class HomeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<VideoModel> _videos = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';

  List<VideoModel> get videos => _videos;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  HomeProvider() {
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _videos = await _apiService.getHomeVideos(category: _selectedCategory);
    } catch (e) {
      debugPrint('Error fetching home videos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    fetchVideos();
  }

  Future<void> refresh() async {
    await fetchVideos();
  }
}
