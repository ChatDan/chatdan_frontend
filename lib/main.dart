import 'package:chatdan_frontend/pages/account_subpage/login_page.dart';
import 'package:chatdan_frontend/pages/account_subpage/mine_page.dart';
import 'package:chatdan_frontend/pages/account_subpage/register.dart';
import 'package:chatdan_frontend/pages/askbox_subpage/askbox_page.dart';
import 'package:chatdan_frontend/pages/chat_subpage/contact_page.dart';
import 'package:chatdan_frontend/pages/square_subpage/square_page.dart';
import 'package:chatdan_frontend/pages/wall_subpage/wall_page.dart';
import 'package:chatdan_frontend/provider/chatdan_provider.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // load access_token
  await ChatDanRepository().loadAccessToken();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final provider = ChatDanRepository().provider;

  static final GoRouter _router = GoRouter(
    initialLocation: '/home',
    routes: <GoRoute>[
      GoRoute(path: '/placeholder', builder: (context, state) => const Placeholder()),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(
          redirectFrom: state.queryParameters['from'] ?? '/home',
        ),
      ),
      GoRoute(path: '/register', builder: (context, state) => const RegistrationPage()),
      GoRoute(path: '/home', builder: (context, state) => const SquarePage()),
      GoRoute(path: '/wall', builder: (context, state) => const WallPage()),
      GoRoute(path: '/askBox', builder: (context, state) => const AskboxPage()),
      GoRoute(path: '/contact', builder: (context, state) => const ContactsPage()),
      GoRoute(path: '/mine', builder: (context, state) => const MinePage())
    ],
    refreshListenable: provider,
    redirect: (BuildContext context, GoRouterState state) {
      if (state.location == '/') {
        return '/home';
      }

      final bool loggedIn = context.read<ChatDanProvider>().isUserLoggedIn;
      final bool toLogin = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final String redirect = provider.tokenInvalid ? '/home' : state.queryParameters['from'] ?? state.location;

      // 用户未登录，且不是前往登录页或注册页
      if (!loggedIn && !toLogin) {
        return '/login?from=$redirect';
      }

      // 用户已登录
      if (loggedIn && toLogin) {
        return '/home';
      }
      return null;
    },
    observers: <NavigatorObserver>[
      FlutterSmartDialog.observer,
    ],
  );

  @override
  Widget build(BuildContext context) {
    final Widget myApp = MaterialApp.router(
      title: 'ChatDan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: _router,
      builder: FlutterSmartDialog.init(),
    );

    return ChangeNotifierProvider<ChatDanProvider>.value(
      value: provider,
      child: myApp,
    );
  }
}
