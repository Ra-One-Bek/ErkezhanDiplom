import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/history_screen.dart';
import '../screens/image_selection_screen.dart';
import '../screens/result_screen.dart';
import '../screens/analyzing_screen.dart';
import '../screens/disease_detail_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/splash_screen.dart'; 

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: "/login",
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: "/register",
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: "/home",
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: "/history",
      builder: (context, state) =>
          const HistoryScreen(),
    ),
    GoRoute(
      path: "/image",
      builder: (context, state) =>
          const ImageSelectionScreen(),
    ),
    GoRoute(
      path: "/result",
      builder: (context, state) => const ResultScreen(),
    ),
    GoRoute(
      path: "/analyzing",
      builder: (context, state) =>
          const AnalyzingScreen(),
    ),
    GoRoute(
      path: "/details",
      builder: (context, state) {
        final data = state.extra as Map<String, String>;

        return DiseaseDetailScreen(
          plantName: data["plantName"] ?? "-",
          diseaseName: data["diseaseName"] ?? "-",
          confidence: data["confidence"] ?? "-",
          imagePath: data["imagePath"],
        );
      },
    ),
    GoRoute(
      path: "/profile",
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);