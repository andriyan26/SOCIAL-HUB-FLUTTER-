import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:social_hub/core/theme/app_theme.dart';
import 'package:social_hub/data/datasources/local_data_source.dart';
import 'package:social_hub/data/repositories/auth_repository_impl.dart';
import 'package:social_hub/data/repositories/post_repository_impl.dart';
import 'package:social_hub/data/repositories/notification_repository_impl.dart';
import 'package:social_hub/data/repositories/friend_repository_impl.dart';

import 'package:social_hub/presentation/providers/auth_provider.dart';
import 'package:social_hub/presentation/providers/feed_provider.dart';
import 'package:social_hub/presentation/providers/community_provider.dart';
import 'package:social_hub/presentation/providers/camera_provider.dart';
import 'package:social_hub/presentation/providers/inbox_provider.dart';
import 'package:social_hub/presentation/providers/profile_provider.dart';
import 'package:social_hub/presentation/providers/ui_frame_provider.dart';

import 'package:social_hub/presentation/widgets/iphone13_frame_wrapper.dart';
import 'package:social_hub/presentation/screens/landing/sequential_flow_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dark status bar and immersive full screen
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Eliminate Flutter release-mode default grey screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('SocialHub Caught Exception: ${details.exception}');
    return const ColoredBox(
      color: Color(0xFF07080C),
      child: Center(
        child: SizedBox.shrink(),
      ),
    );
  };

  final localDataSource = LocalDataSource();
  final authRepository = AuthRepositoryImpl(localDataSource: localDataSource);
  final postRepository = PostRepositoryImpl(localDataSource: localDataSource);
  final notificationRepository = NotificationRepositoryImpl(localDataSource: localDataSource);
  final friendRepository = FriendRepositoryImpl(localDataSource: localDataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UiFrameProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository)..checkAuthSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => FeedProvider(postRepository: postRepository)..loadFeed(),
        ),
        ChangeNotifierProvider(
          create: (_) => CommunityProvider(friendRepository: friendRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CameraProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => InboxProvider(notificationRepository: notificationRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(postRepository: postRepository),
        ),
      ],
      child: const SocialHubApp(),
    ),
  );
}

class SocialHubApp extends StatelessWidget {
  const SocialHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Hub (iPhone 13 Studio)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      builder: (context, child) {
        return IPhone13FrameWrapper(
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SequentialFlowScreen(),
    );
  }
}
