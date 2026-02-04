import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../widgets/comment_card.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = _getMockPost();
    final comments = _getMockComments();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildOriginalPost(post),
                const Divider(height: 1, color: Colors.white10),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'COMMUNITY DISCUSSION',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                ...comments.map((comment) => CommentCard(
                      comment: comment,
                      onLike: () => _handleCommentLike(comment),
                      onReply: () => _handleReply(comment),
                    )),
              ],
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildOriginalPost(PostModel post) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: post.authorImage != null
                ? NetworkImage(post.authorImage!)
                : null,
            backgroundColor: post.authorType == AuthorType.vendor
                ? AppTheme.primaryColor
                : Colors.grey.shade800,
            child: post.authorImage == null
                ? Icon(
                    post.authorType == AuthorType.vendor
                        ? Icons.fitness_center
                        : Icons.person,
                    color: post.authorType == AuthorType.vendor
                        ? Colors.black
                        : Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (post.authorType == AuthorType.vendor) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'VENDOR',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  post.timeAgo,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  post.content,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 20,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      post.likesCount.toString(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Icon(
                      Icons.chat_bubble,
                      size: 20,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      post.commentsCount.toString(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade800,
            child: const Icon(Icons.person, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, size: 18),
                      color: Colors.black,
                      onPressed: _handleSendComment,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCommentLike(CommentModel comment) {
    // TODO: Implement comment like
    setState(() {});
  }

  void _handleReply(CommentModel comment) {
    _commentController.text = '@${comment.authorName} ';
  }

  void _handleSendComment() {
    if (_commentController.text.trim().isEmpty) return;
    // TODO: Implement send comment
    _commentController.clear();
  }

  PostModel _getMockPost() {
    return PostModel(
      id: widget.postId,
      authorId: 'user1',
      authorName: 'Marcus Thorne',
      authorType: AuthorType.customer,
      postType: PostType.text,
      content: 'Just finished a session at the new Westside branch. The lifting platforms are top-tier. Highly recommend the recovery zone after! 🏋️‍♂️🔥',
      likesCount: 128,
      commentsCount: 24,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    );
  }

  List<CommentModel> _getMockComments() {
    return [
      CommentModel(
        id: '1',
        postId: widget.postId,
        authorId: 'user2',
        authorName: 'Alex Rivera',
        authorType: AuthorType.customer,
        content: 'Anyone tried the new power rack at the Downtown branch? It looks solid!',
        likesCount: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CommentModel(
        id: '2',
        postId: widget.postId,
        authorId: 'vendor1',
        authorName: 'Openkora Pro',
        authorType: AuthorType.vendor,
        content: 'It\'s our latest addition! We\'ve also added calibrated plates. Come check it out!',
        likesCount: 24,
        isLiked: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      CommentModel(
        id: '3',
        postId: widget.postId,
        authorId: 'user3',
        authorName: 'Sarah Chen',
        authorType: AuthorType.customer,
        content: 'Is it usually busy around 6 PM? Trying to plan my leg day.',
        likesCount: 3,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      CommentModel(
        id: '4',
        postId: widget.postId,
        authorId: 'user4',
        authorName: 'James Miller',
        authorType: AuthorType.customer,
        content: 'The lighting in that branch is perfect for progress shots haha! See you all there tonight.',
        likesCount: 0,
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
    ];
  }
}
