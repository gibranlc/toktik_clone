class VideoPost {
  final String id;
  final String assetPath;
  final String userName;
  final String caption;
  final DateTime createdAt;
  int likes;

  VideoPost({
    required this.id,
    required this.assetPath,
    required this.userName,
    required this.caption,
    required this.createdAt,
    this.likes = 0,
  });
}
