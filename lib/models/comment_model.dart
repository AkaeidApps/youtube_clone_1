class CommentModel {
  final String id;
  final String videoId;
  final String userName;
  final String userAvatarUrl;
  final String text;
  final String timestamp;
  final int likes;
  final bool isLiked;

  CommentModel({
    required this.id,
    required this.videoId,
    required this.userName,
    required this.userAvatarUrl,
    required this.text,
    required this.timestamp,
    this.likes = 0,
    this.isLiked = false,
  });

  CommentModel copyWith({
    String? id,
    String? videoId,
    String? userName,
    String? userAvatarUrl,
    String? text,
    String? timestamp,
    int? likes,
    bool? isLiked,
  }) {
    return CommentModel(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoId': videoId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'text': text,
      'timestamp': timestamp,
      'likes': likes,
      'isLiked': isLiked,
    };
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      videoId: json['videoId'] as String,
      userName: json['userName'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String,
      text: json['text'] as String,
      timestamp: json['timestamp'] as String,
      likes: json['likes'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }
}
