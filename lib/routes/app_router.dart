
import 'package:go_router/go_router.dart';
import 'package:guide_app/screens/chapter_details_screen.dart';
import 'package:guide_app/screens/chapters_screen.dart';
import 'package:guide_app/screens/downloads_screen.dart';
import 'package:guide_app/screens/home_screen.dart';
import 'package:guide_app/screens/lesson_screen.dart';
import 'package:guide_app/screens/quiz_screen.dart';
import 'package:guide_app/screens/search_screen.dart';
import 'package:guide_app/screens/settings_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/chapters',
        builder: (context, state) => const ChaptersScreen(),
      ),
      GoRoute(
        path: '/chapter/:chapterId',
        builder: (context, state) {
          final chapterId = state.pathParameters['chapterId']!;
          return ChapterDetailsScreen(chapterId: chapterId);
        },
      ),
      GoRoute(
        path: '/lesson/:lessonId',
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          return LessonScreen(lessonId: lessonId);
        },
      ),
      GoRoute(
        path: '/quiz/:quizId',
        builder: (context, state) {
          final quizId = state.pathParameters['quizId']!;
          return QuizScreen(quizId: quizId);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/downloads',
        builder: (context, state) => const DownloadsScreen(),
      ),
    ],
  );
}