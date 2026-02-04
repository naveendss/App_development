enum PostType { text, image, motivation, event }

enum AuthorType { customer, vendor }

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorImage;
  final AuthorType authorType;
  final PostType postType;
  final String content;
  final String? imageUrl;
  final DateTime? eventDate;
  final String? eventLocation;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorImage,
    required this.authorType,
    required this.postType,
    required this.content,
    this.imageUrl,
    this.eventDate,
    this.eventLocation,
    required this.likesCount,
    required this.commentsCount,
    this.isLiked = false,
    required this.createdAt,
  });

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}
