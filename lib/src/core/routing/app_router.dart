import 'package:go_router/go_router.dart';
import 'package:smartcity/src/core/services/session_service.dart';
import 'package:smartcity/src/features/auth/presentation/onboarding/onboarding_screen.dart';
import 'package:smartcity/src/features/auth/presentation/login/login_page.dart';
import 'package:smartcity/src/features/auth/presentation/register/register_page.dart';
import 'package:smartcity/src/features/home/presentation/home_page.dart';
import 'package:smartcity/src/features/problems/presentation/problem_detail_page.dart';
import 'package:smartcity/src/features/home/presentation/all_problems_page.dart';
import 'package:smartcity/src/features/home/presentation/mes_signalements_page.dart';
import 'package:smartcity/src/features/problems/presentation/new_problem_page.dart';
import 'package:smartcity/src/features/home/presentation/profile_page.dart';
import 'package:smartcity/src/features/home/presentation/notifications_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const OnboardingScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/problem/new',
      builder: (context, state) => const NewProblemPage(),
    ),
    GoRoute(
      path: '/problem/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProblemDetailPage(problemId: id);
      },
    ),
    GoRoute(
      path: '/category/:code',
      builder: (context, state) {
        final code = state.pathParameters['code']!;
        return HomePage(initialCategory: code);
      },
    ),
    GoRoute(
      path: '/problems',
      builder: (context, state) => const AllProblemsPage(),
    ),
    GoRoute(
      path: '/my-reports',
      builder: (context, state) {
        final user = SessionService.currentUser;

        // Sécurité : pas connecté → login
        if (user == null || user['id'] == null) {
          return const LoginPage();
        }

        return MesSignalementsPage(
          currentUserId: user['id'].toString(), // ✅ UUID réel
        );
      },
    ),


    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
  ],
);
