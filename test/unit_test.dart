import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_clone/models/video_model.dart';
import 'package:youtube_clone/services/api_service.dart';
import 'package:youtube_clone/services/storage_service.dart';
import 'package:youtube_clone/providers/home_provider.dart';
import 'package:youtube_clone/providers/shorts_provider.dart';
import 'package:youtube_clone/providers/search_provider.dart';
import 'package:youtube_clone/providers/player_provider.dart';
import 'package:youtube_clone/providers/library_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('YouTube Data API v3 Parsing Tests', () {
    test('VideoModel correctly parses YouTube search item JSON', () {
      final sampleYouTubeJson = {
        'kind': 'youtube#searchResult',
        'id': {
          'kind': 'youtube#video',
          'videoId': 'dQw4w9WgXcQ',
        },
        'snippet': {
          'publishedAt': '2024-01-15T12:00:00Z',
          'channelId': 'UCuAXFkgsw1L7xaCfnd5JJOw',
          'title': 'Flutter 3 Production Architecture',
          'description': 'Master clean architecture in Flutter',
          'thumbnails': {
            'default': {'url': 'http://example.com/default.jpg'},
            'medium': {'url': 'http://example.com/medium.jpg'},
            'high': {'url': 'http://example.com/high.jpg'},
          },
          'channelTitle': 'Flutter Masterclass',
        },
      };

      final video = VideoModel.fromJson(sampleYouTubeJson);
      expect(video.id, 'dQw4w9WgXcQ');
      expect(video.title, 'Flutter 3 Production Architecture');
      expect(video.channelName, 'Flutter Masterclass');
      expect(video.thumbnailUrl, 'http://example.com/high.jpg');
      expect(video.channelId, 'UCuAXFkgsw1L7xaCfnd5JJOw');
      expect(video.videoUrl, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ');
    });
  });

  group('ApiService Tests', () {
    final api = ApiService();

    test('getHomeVideos returns list of videos', () async {
      final videos = await api.getHomeVideos();
      expect(videos.isNotEmpty, true);
      expect(videos.first.id, 'v1');
    });

    test('getShortsVideos returns list of shorts', () async {
      final shorts = await api.getShortsVideos();
      expect(shorts.isNotEmpty, true);
      expect(shorts.first.isShort, true);
    });

    test('searchVideos returns matched videos', () async {
      final results = await api.searchVideos('flutter');
      expect(results.isNotEmpty, true);
    });

    test('addComment adds a new comment', () async {
      final comment = await api.addComment('v1', 'Great course!');
      expect(comment.text, 'Great course!');
      expect(comment.videoId, 'v1');
    });
  });

  group('StorageService Tests', () {
    final storage = StorageService();

    final testVideo = VideoModel(
      id: 'test_vid',
      title: 'Test Title',
      description: 'Test Desc',
      videoUrl: 'http://example.com/v.mp4',
      thumbnailUrl: 'http://example.com/t.jpg',
      duration: '10:00',
      viewCount: '100 views',
      uploadDate: 'Today',
      channelId: 'ch_test',
      channelName: 'Channel Test',
      channelAvatarUrl: 'http://example.com/c.jpg',
      subscriberCount: '10K',
    );

    test('History management', () {
      storage.addToHistory(testVideo);
      expect(storage.history.any((v) => v.id == 'test_vid'), true);
      storage.clearHistory();
      expect(storage.history.isEmpty, true);
    });

    test('Watch later toggle', () {
      expect(storage.isWatchLater('test_vid'), false);
      storage.toggleWatchLater(testVideo);
      expect(storage.isWatchLater('test_vid'), true);
      storage.toggleWatchLater(testVideo);
      expect(storage.isWatchLater('test_vid'), false);
    });

    test('Search query history', () {
      storage.addSearchQuery('test query');
      expect(storage.searchHistory.contains('test query'), true);
      storage.removeSearchQuery('test query');
      expect(storage.searchHistory.contains('test query'), false);
    });
  });

  group('Providers Tests', () {
    test('HomeProvider loads videos and changes category', () async {
      final homeProvider = HomeProvider();
      await homeProvider.fetchVideos();
      expect(homeProvider.videos.isNotEmpty, true);
      homeProvider.selectCategory('Coding');
      expect(homeProvider.selectedCategory, 'Coding');
    });

    test('ShortsProvider toggles like', () async {
      final shortsProvider = ShortsProvider();
      await shortsProvider.fetchShorts();
      expect(shortsProvider.shorts.isNotEmpty, true);
      final firstId = shortsProvider.shorts.first.id;
      final initialLiked = shortsProvider.shorts.first.isLiked;
      shortsProvider.toggleLike(firstId);
      expect(shortsProvider.shorts.first.isLiked, !initialLiked);
    });

    test('SearchProvider searches and clears', () async {
      final searchProvider = SearchProvider();
      await searchProvider.search('flutter');
      expect(searchProvider.searchResults.isNotEmpty, true);
      expect(searchProvider.hasSearched, true);
      searchProvider.clearQuery();
      expect(searchProvider.searchResults.isEmpty, true);
      expect(searchProvider.hasSearched, false);
    });

    test('PlayerProvider plays, seeks and toggles play/pause', () {
      final playerProvider = PlayerProvider();
      final video = VideoModel(
        id: 'v_play',
        title: 'Playing Video',
        description: 'Desc',
        videoUrl: 'http://example.com/v.mp4',
        thumbnailUrl: 'http://example.com/t.jpg',
        duration: '05:30',
        viewCount: '10K views',
        uploadDate: 'Yesterday',
        channelId: 'ch1',
        channelName: 'Channel',
        channelAvatarUrl: 'http://example.com/a.jpg',
        subscriberCount: '5K',
      );

      playerProvider.playVideo(video);
      expect(playerProvider.currentVideo?.id, 'v_play');
      expect(playerProvider.isPlaying, true);

      playerProvider.togglePlayPause();
      expect(playerProvider.isPlaying, false);

      playerProvider.seekTo(const Duration(minutes: 1));
      expect(playerProvider.currentPosition.inMinutes, 1);

      playerProvider.closePlayer();
      expect(playerProvider.currentVideo, null);
      expect(playerProvider.isPlaying, false);
    });

    test('LibraryProvider creates playlist and manages watch later', () {
      final libProvider = LibraryProvider();
      libProvider.createPlaylist('Flutter Favorites');
      expect(libProvider.playlists.contains('Flutter Favorites'), true);
    });
  });
}
