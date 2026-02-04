import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';

class CommentCard extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback? onLike;
  final VoidCallback? onReply;

  const CommentCard({
    super.key,
    required this.comment,
    this.onLike,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: comment.authorImage != null
                ? NetworkImage(comment.authorImage!)
                : null,
            backgroundColor: comment.authorType == AuthorType.vendor
                ? AppTheme.primaryColor
                : Colors.grey.shade800,
            child: comment.authorImage == null
                ? Icon(
                    comment.authorType == AuthorType.vendor
                        ? Icons.fitness_center
                        : Icons.person,
                    size: 18,
                    color: comment.authorType == AuthorType.vendor
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
                      comment.authorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (comment.authorType == AuthorType.vendor) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'VENDOR',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      comment.timeAgo,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.content,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    InkWell(
                      onTap: onLike,
                      child: Row(
                        children: [
                          Icon(
                            comment.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            size: 16,
                            color: comment.isLiked
                                ? AppTheme.primaryColor
                                : Colors.white.withOpacity(0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            comment.likesCount.toString(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    InkWell(
                      onTap: onReply,
                      child: Text(
                        'REPLY',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
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
}
