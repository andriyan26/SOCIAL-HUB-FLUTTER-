import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_hub/presentation/core/constants/app_colors.dart';
import 'package:social_hub/presentation/screens/providers/inbox_provider.dart';
import 'package:social_hub/presentation/screens/providers/auth_provider.dart';
import 'package:social_hub/presentation/screens/widgets/tiktok_nav_bar.dart';
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

  final List<Widget> _pages = const [
    FeedScreen(),
    CommunityScreen(),
    SizedBox.shrink(), // Camera placeholder
    InboxScreen(),
    ProfileScreen(),
  ];

  void _onTabSelected(int index) {
    if (index == 2) {
      // Open Camera Studio
      _previousIndex = _currentIndex;
      setState(() {
        _isCameraOpen = true;
      });
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _closeCamera() {
    setState(() {
      _isCameraOpen = false;
      _currentIndex = _previousIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<InboxProvider>().unreadCount;

    if (_isCameraOpen) {
      return CameraStudioScreen(onClose: _closeCamera);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: TikTokNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        unreadNotificationCount: unreadCount,
      ),
    );
  }
}

