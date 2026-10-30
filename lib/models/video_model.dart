class VideoModel {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final String duration;
  final String viewCount;
  final String uploadDate;
  final String channelId;
  final String channelName;
  final String channelAvatarUrl;
  final String subscriberCount;
  final int likes;
  final int dislikes;
  final bool isLiked;
  final bool isDisliked;
  final bool isSubscribed;
  final bool isShort;
  final int commentCount;
  final List<String> tags;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
    required this.viewCount,
    required this.uploadDate,
    required this.channelId,
    required this.channelName,
    required this.channelAvatarUrl,
    required this.subscriberCount,
    this.likes = 0,
    this.dislikes = 0,
    this.isLiked = false,
    this.isDisliked = false,
    this.isSubscribed = false,
    this.isShort = false,
    this.commentCount = 0,
    this.tags = const [],
  });

  VideoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
    String? duration,
    String? viewCount,
    String? uploadDate,
    String? channelId,
    String? channelName,
    String? channelAvatarUrl,
    String? subscriberCount,
    int? likes,
    int? dislikes,
    bool? isLiked,
    bool? isDisliked,
    bool? isSubscribed,
    bool? isShort,
    int? commentCount,
    List<String>? tags,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      viewCount: viewCount ?? this.viewCount,
      uploadDate: uploadDate ?? this.uploadDate,
      channelId: channelId ?? this.channelId,
      channelName: channelName ?? this.channelName,
      channelAvatarUrl: channelAvatarUrl ?? this.channelAvatarUrl,
      subscriberCount: subscriberCount ?? this.subscriberCount,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      isLiked: isLiked ?? this.isLiked,
      isDisliked: isDisliked ?? this.isDisliked,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      isShort: isShort ?? this.isShort,
      commentCount: commentCount ?? this.commentCount,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'viewCount': viewCount,
      'uploadDate': uploadDate,
      'channelId': channelId,
      'channelName': channelName,
      'channelAvatarUrl': channelAvatarUrl,
      'subscriberCount': subscriberCount,
      'likes': likes,
      'dislikes': dislikes,
      'isLiked': isLiked,
      'isDisliked': isDisliked,
      'isSubscribed': isSubscribed,
      'isShort': isShort,
      'commentCount': commentCount,
      'tags': tags,
    };
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    // Check if this is a response from the official YouTube Data API v3
    if (json.containsKey('snippet')) {
      final snippet = json['snippet'] as Map<String, dynamic>? ?? {};

      String videoId = '';
      if (json['id'] is Map) {
        final idMap = json['id'] as Map<String, dynamic>;
        videoId = idMap['videoId'] as String? ??
            idMap['channelId'] as String? ??
            idMap['playlistId'] as String? ??
            '';
      } else if (json['id'] is String) {
        videoId = json['id'] as String;
      }

      final thumbnails = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
      final highThumb = thumbnails['high'] as Map<String, dynamic>?;
      final mediumThumb = thumbnails['medium'] as Map<String, dynamic>?;
      final defaultThumb = thumbnails['default'] as Map<String, dynamic>?;

      final thumbUrl = highThumb?['url'] as String? ??
          mediumThumb?['url'] as String? ??
          defaultThumb?['url'] as String? ??
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80';

      final publishedAt = snippet['publishedAt'] as String? ?? '';
      String formattedDate = 'Recently';
      if (publishedAt.isNotEmpty) {
        try {
          final dt = DateTime.parse(publishedAt);
          final diff = DateTime.now().difference(dt);
          if (diff.inDays > 365) {
            formattedDate = '${(diff.inDays / 365).floor()} years ago';
          } else if (diff.inDays > 30) {
            formattedDate = '${(diff.inDays / 30).floor()} months ago';
          } else if (diff.inDays > 0) {
            formattedDate = '${diff.inDays} days ago';
          } else if (diff.inHours > 0) {
            formattedDate = '${diff.inHours} hours ago';
          } else {
            formattedDate = 'Just now';
          }
        } catch (_) {}
      }

      return VideoModel(
        id: videoId.isNotEmpty ? videoId : 'yt_${DateTime.now().millisecondsSinceEpoch}',
        title: snippet['title'] as String? ?? 'Untitled Video',
        description: snippet['description'] as String? ?? '',
        videoUrl: 'https://www.youtube.com/watch?v=$videoId',
        thumbnailUrl: thumbUrl,
        duration: '10:45',
        viewCount: '1.2M views',
        uploadDate: formattedDate,
        channelId: snippet['channelId'] as String? ?? '',
        channelName: snippet['channelTitle'] as String? ?? 'YouTube Creator',
        channelAvatarUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
        subscriberCount: '1M subscribers',
        likes: 45000,
        commentCount: 820,
        tags: const ['YouTube', 'Video'],
      );
    }

    // Default internal JSON parsing
    return VideoModel(
      id: json['id'] as String? ?? 'v_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      videoUrl: json['videoUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      duration: json['duration'] as String? ?? '00:00',
      viewCount: json['viewCount'] as String? ?? '0 views',
      uploadDate: json['uploadDate'] as String? ?? 'Just now',
      channelId: json['channelId'] as String? ?? '',
      channelName: json['channelName'] as String? ?? 'Channel',
      channelAvatarUrl: json['channelAvatarUrl'] as String? ?? '',
      subscriberCount: json['subscriberCount'] as String? ?? '0 subscribers',
      likes: json['likes'] as int? ?? 0,
      dislikes: json['dislikes'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isDisliked: json['isDisliked'] as bool? ?? false,
      isSubscribed: json['isSubscribed'] as bool? ?? false,
      isShort: json['isShort'] as bool? ?? false,
      commentCount: json['commentCount'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }
}

class ChannelModel {
  final String id;
  final String name;
  final String handle;
  final String avatarUrl;
  final String bannerUrl;
  final String subscriberCount;
  final int videoCount;
  final bool isSubscribed;
  final bool hasUnseenVideos;

  ChannelModel({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatarUrl,
    required this.bannerUrl,
    required this.subscriberCount,
    this.videoCount = 0,
    this.isSubscribed = false,
    this.hasUnseenVideos = false,
  });

  ChannelModel copyWith({
    String? id,
    String? name,
    String? handle,
    String? avatarUrl,
    String? bannerUrl,
    String? subscriberCount,
    int? videoCount,
    bool? isSubscribed,
    bool? hasUnseenVideos,
  }) {
    return ChannelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      handle: handle ?? this.handle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      subscriberCount: subscriberCount ?? this.subscriberCount,
      videoCount: videoCount ?? this.videoCount,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      hasUnseenVideos: hasUnseenVideos ?? this.hasUnseenVideos,
    );
  }
}
