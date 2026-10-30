import 'dart:async';
import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../models/comment_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class PlayerProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  VideoModel? _currentVideo;
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _isMiniPlayer = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(minutes: 10, seconds: 30);
  Timer? _playbackTimer;

  List<CommentModel> _comments = [];
  bool _isLoadingComments = false;

  VideoModel? get currentVideo => _currentVideo;
  bool get isPlaying => _isPlaying;
  bool get isMuted => _isMuted;
  bool get isMiniPlayer => _isMiniPlayer;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  List<CommentModel> get comments => _comments;
  bool get isLoadingComments => _isLoadingComments;

  void playVideo(VideoModel video) {
    _currentVideo = video;
    _isPlaying = true;
    _isMiniPlayer = false;
    _currentPosition = Duration.zero;
    _totalDuration = _parseDuration(video.duration);

    _storageService.addToHistory(video);
    _startTimer();
    loadComments(video.id);
    notifyListeners();
  }

  Duration _parseDuration(String durationStr) {
    try {
      final parts = durationStr.split(':').map((e) => int.parse(e.trim())).toList();
      if (parts.length == 3) {
        return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
      } else if (parts.length == 2) {
        return Duration(minutes: parts[0], seconds: parts[1]);
      }
    } catch (_) {}
    return const Duration(minutes: 12, seconds: 45);
  }

  void _startTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying && _currentVideo != null) {
        if (_currentPosition < _totalDuration) {
          _currentPosition += const Duration(seconds: 1);
          notifyListeners();
        } else {
          _isPlaying = false;
          timer.cancel();
          notifyListeners();
        }
      }
    });
  }

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _startTimer();
    } else {
      _playbackTimer?.cancel();
    }
    notifyListeners();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  void seekTo(Duration position) {
    _currentPosition = position;
    if (_currentPosition > _totalDuration) {
      _currentPosition = _totalDuration;
    }
    notifyListeners();
  }

  void setMiniPlayer(bool value) {
    _isMiniPlayer = value;
    notifyListeners();
  }

  void toggleLike() {
    if (_currentVideo == null) return;
    final newLike = !_currentVideo!.isLiked;
    _currentVideo = _currentVideo!.copyWith(
      isLiked: newLike,
      isDisliked: false,
      likes: newLike ? _currentVideo!.likes + 1 : _currentVideo!.likes - 1,
    );
    _storageService.toggleLiked(_currentVideo!);
    notifyListeners();
  }

  void toggleDislike() {
    if (_currentVideo == null) return;
    final newDislike = !_currentVideo!.isDisliked;
    _currentVideo = _currentVideo!.copyWith(
      isDisliked: newDislike,
      isLiked: false,
      likes: _currentVideo!.isLiked ? _currentVideo!.likes - 1 : _currentVideo!.likes,
    );
    notifyListeners();
  }

  void toggleSubscribe() {
    if (_currentVideo == null) return;
    final newSub = !_currentVideo!.isSubscribed;
    _currentVideo = _currentVideo!.copyWith(isSubscribed: newSub);
    _storageService.toggleSubscription(_currentVideo!.channelId);
    notifyListeners();
  }

  Future<void> loadComments(String videoId) async {
    _isLoadingComments = true;
    notifyListeners();

    try {
      _comments = await _apiService.getVideoComments(videoId);
    } catch (e) {
      debugPrint('Error loading comments: $e');
    } finally {
      _isLoadingComments = false;
      notifyListeners();
    }
  }

  Future<void> addComment(String text) async {
    if (_currentVideo == null || text.trim().isEmpty) return;
    final newComment = await _apiService.addComment(_currentVideo!.id, text.trim());
    _comments.insert(0, newComment);
    _currentVideo = _currentVideo!.copyWith(commentCount: _currentVideo!.commentCount + 1);
    notifyListeners();
  }

  void closePlayer() {
    _playbackTimer?.cancel();
    _currentVideo = null;
    _isPlaying = false;
    _isMiniPlayer = false;
    _currentPosition = Duration.zero;
    _comments = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }
}
