import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class SearchProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  String _query = '';
  List<VideoModel> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  String get query => _query;
  List<VideoModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;
  List<String> get searchHistory => _storageService.searchHistory;

  Future<void> search(String query) async {
    _query = query.trim();
    if (_query.isEmpty) {
      _searchResults = [];
      _hasSearched = false;
      notifyListeners();
      return;
    }

    _storageService.addSearchQuery(_query);
    _isLoading = true;
    _hasSearched = true;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchVideos(_query);
    } catch (e) {
      debugPrint('Error searching videos: $e');
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearQuery() {
    _query = '';
    _searchResults = [];
    _hasSearched = false;
    notifyListeners();
  }

  void removeHistoryItem(String item) {
    _storageService.removeSearchQuery(item);
    notifyListeners();
  }

  void clearAllHistory() {
    _storageService.clearSearchHistory();
    notifyListeners();
  }
}
