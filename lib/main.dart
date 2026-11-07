import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/local_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/post_repository_impl.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'data/repositories/friend_repository_impl.dart';

import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/feed_provider.dart';
import 'presentation/providers/community_provider.dart';
import 'presentation/providers/camera_provider.dart';
import 'presentation/providers/inbox_provider.dart';
import 'presentation/providers/profile_provider.dart';

import 'presentation/screens/landing/landing_screen.dart';
import 'presentation/screens/main/main_screen.dart';

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

  final localDataSource = LocalDataSource();
  final authRepository = AuthRepositoryImpl(localDataSource: localDataSource);
  final postRepository = PostRepositoryImpl(localDataSource: localDataSource);
  final notificationRepository = NotificationRepositoryImpl(localDataSource: localDataSource);
  final friendRepository = FriendRepositoryImpl(localDataSource: localDataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository)..checkAuthSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => FeedProvider(postRepository: postRepository),
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
      title: 'Social Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppRootRouter(),
    );
  }
}

class AppRootRouter extends StatelessWidget {
  const AppRootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Initial loading splash state
    if (authProvider.status == AuthStatus.initial || authProvider.status == AuthStatus.authenticating) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SOCIAL HUB',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: Color(0xFFFE2C55),
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFE2C55)),
              ),
            ],
          ),
        ),
      );
    }

    // Auto-login persistence check:
    // If user has saved session in SQLite/SharedPreferences, go straight to MainScreen!
    if (authProvider.isAuthenticated) {
      return const MainScreen();
    }

    // Otherwise show cinematic landing screen
    return const LandingScreen();
  }
}

