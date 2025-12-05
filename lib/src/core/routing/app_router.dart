import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/onboarding/onboarding_screen.dart';
import '../../features/auth/presentation/login/login_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/problems/presentation/problem_detail_page.dart';
import '../../features/home/presentation/all_problems_page.dart';
// import '../../features/problems/presentation/my_reports_page.dart'; //
import '../../features/home/presentation/mes_signalements_page.dart'; //'


final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/home', builder: (_, __) => const HomePage()),

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
      builder: (_, __) => const AllProblemsPage(),
    ),

    // ⭐ NEW : Mes signalements (pending, treated)
    GoRoute(
      path: '/my-reports',
      builder: (_, __) => MesSignalementsPage(currentUserId: 'user1'),

    ),
  ],
);
