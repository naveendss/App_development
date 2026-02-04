import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../models/post_model.dart';
import '../widgets/post_card.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.black),
            ),
            onPressed: () => context.push('/community/create-post'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 2,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.4),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(text: 'Feed'),
                Tab(text: 'Following'),
                Tab(text: 'Events'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFeedTab(),
                _buildFollowingTab(),
                _buildEventsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedTab() {
    final posts = _getMockPosts();
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        return PostCard(
          post: posts[index],
          onLike: () => _handleLike(posts[index]),
          onComment: () => context.push('/community/post/${posts[index].id}'),
          onTap: () => context.push('/community/post/${posts[index].id}'),
        );
      },
    );
  }

  Widget _buildFollowingTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No posts from people you follow',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    final events = _getMockPosts()
        .where((post) => post.postType == PostType.event)
        .toList();
    
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        return PostCard(
          post: events[index],
          onTap: () => context.push('/community/post/${events[index].id}'),
        );
      },
    );
  }

  void _handleLike(PostModel post) {
    // TODO: Implement like functionality
    setState(() {});
  }

  List<PostModel> _getMockPosts() {
    return [
      PostModel(
        id: '1',
        authorId: 'vendor1',
        authorName: 'Iron Haven Gym',
        authorType: AuthorType.vendor,
        postType: PostType.image,
        content: 'New squat racks are finally here! High performance equipment for the best results. Come test them out this week.',
        imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
        likesCount: 124,
        commentsCount: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PostModel(
        id: '2',
        authorId: 'user1',
        authorName: 'Alex R.',
        authorType: AuthorType.customer,
        postType: PostType.motivation,
        content: '"Consistency is the only secret. See you at the rack at 6 AM. 🏋️‍♂️"',
        imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800',
        likesCount: 482,
        commentsCount: 24,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      PostModel(
        id: '3',
        authorId: 'vendor2',
        authorName: 'Openkora HQ',
        authorType: AuthorType.vendor,
        postType: PostType.event,
        content: 'Saturday Powerlifting Workshop',
        eventDate: DateTime.now().add(const Duration(days: 5)),
        eventLocation: 'Openkora HQ, Downtown',
        likesCount: 89,
        commentsCount: 15,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      PostModel(
        id: '4',
        authorId: 'user2',
        authorName: 'Sarah Jenkins',
        authorType: AuthorType.customer,
        postType: PostType.text,
        content: 'Just hit a personal best on deadlifts! 180kg never felt so light. Huge thanks to the Openkora community for the support this month. 🔥',
        likesCount: 89,
        commentsCount: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }
}
