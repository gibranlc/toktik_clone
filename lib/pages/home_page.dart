import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_feed_provider.dart';
import '../widgets/video_post_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<VideoFeedProvider>();

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: feed.posts.length,
        onPageChanged: (i) =>
            context.read<VideoFeedProvider>().setCurrentIndex(i),
        itemBuilder: (context, index) {
          final post = feed.posts[index];
          final isActive = index == feed.currentIndex;
          return VideoPostWidget(post: post, isActive: isActive);
        },
      ),
    );
  }
}
