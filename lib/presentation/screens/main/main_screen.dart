import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/presentation/providers/inbox_provider.dart';
import 'package:social_hub/presentation/providers/feed_provider.dart';
import 'package:social_hub/presentation/widgets/tiktok_nav_bar.dart';
import 'package:social_hub/presentation/screens/feed/feed_screen.dart';
import 'package:social_hub/presentation/screens/community/community_screen.dart';
import 'package:social_hub/presentation/screens/camera/camera_studio_screen.dart';
import 'package:social_hub/presentation/screens/inbox/inbox_screen.dart';
import 'package:social_hub/presentation/screens/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _previousIndex = 0;
  bool _isCameraOpen = false;

  void _onTabSelected(int index) {
    if (index == 2) {
      // Open Camera Studio: immediately stop Beranda video and sound
      _previousIndex = _currentIndex;
      context.read<FeedProvider>().setFeedActive(false);
      setState(() {
        _isCameraOpen = true;
      });
    } else {
      // If switching away from Beranda (index != 0), silence Beranda immediately!
      final isFeedActive = (index == 0);
      context.read<FeedProvider>().setFeedActive(isFeedActive);
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _closeCamera() {
    final shouldResumeFeed = (_previousIndex == 0);
    context.read<FeedProvider>().setFeedActive(shouldResumeFeed);
    setState(() {
      _isCameraOpen = false;
      _currentIndex = _previousIndex;
    });
  }

  void _onPublishSuccess() {
    context.read<FeedProvider>().setFeedActive(true);
    setState(() {
      _isCameraOpen = false;
      _currentIndex = 0; // Return straight to Beranda (Feed) to see the new post!
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<InboxProvider>().unreadCount;

    if (_isCameraOpen) {
      return CameraStudioScreen(
        onClose: _closeCamera,
        onPublishSuccess: _onPublishSuccess,
      );
    }

    final isFeedTabActive = (_currentIndex == 0 && !_isCameraOpen);

    final pages = [
      FeedScreen(isActive: isFeedTabActive),
      const CommunityScreen(),
      const SizedBox.shrink(), // Camera placeholder
      const InboxScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: TikTokNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        unreadNotificationCount: unreadCount,
      ),
    );
  }
}
