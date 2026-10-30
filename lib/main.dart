import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/constants.dart';
import 'providers/home_provider.dart';
import 'providers/shorts_provider.dart';
import 'providers/search_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/library_provider.dart';
import 'providers/player_provider.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YouTubeApp());
}

class YouTubeApp extends StatelessWidget {
  const YouTubeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ShortsProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: AppConstants.primaryRed,
          scaffoldBackgroundColor: AppConstants.lightBackground,
          cardColor: AppConstants.lightCard,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppConstants.lightBackground,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppConstants.lightBackground,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
          ),
          colorScheme: const ColorScheme.light(
            primary: AppConstants.primaryRed,
            surface: AppConstants.lightSurface,
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: AppConstants.primaryRed,
          scaffoldBackgroundColor: AppConstants.darkBackground,
          cardColor: AppConstants.darkCard,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppConstants.darkBackground,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppConstants.darkBackground,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
          ),
          colorScheme: const ColorScheme.dark(
            primary: AppConstants.primaryRed,
            surface: AppConstants.darkSurface,
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}
