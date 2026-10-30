import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  List<ChannelModel> _channels = [];
  List<VideoModel> _videos = [];
  bool _isLoading = false;
  String _selectedFilter = 'All';

  List<ChannelModel> get channels => _channels;
  List<VideoModel> get videos => _videos;
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;

  SubscriptionProvider() {
    fetchSubscriptions();
  }

  Future<void> fetchSubscriptions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _channels = await _apiService.getSubscribedChannels();
      // Fetch home videos as subscription feed
      final allVideos = await _apiService.getHomeVideos();
      _videos = allVideos.where((v) => _storageService.isSubscribed(v.channelId)).toList();
    } catch (e) {
      debugPrint('Error fetching subscriptions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void toggleSubscribe(String channelId) {
    _storageService.toggleSubscription(channelId);
    final index = _channels.indexWhere((c) => c.id == channelId);
    if (index != -1) {
      _channels[index] = _channels[index].copyWith(
        isSubscribed: _storageService.isSubscribed(channelId),
      );
    }
    notifyListeners();
  }
}
