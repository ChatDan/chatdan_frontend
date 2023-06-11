import 'package:chatdan_frontend/pages/account_subpage/login_page.dart';
import 'package:chatdan_frontend/pages/account_subpage/mine_page.dart';
import 'package:chatdan_frontend/pages/account_subpage/register.dart';
import 'package:chatdan_frontend/pages/askbox_subpage/askbox_detail_page.dart';
import 'package:chatdan_frontend/pages/askbox_subpage/askbox_page.dart';
import 'package:chatdan_frontend/pages/chat_subpage/contact_page.dart';
import 'package:chatdan_frontend/pages/square_subpage/square_page.dart';
import 'package:chatdan_frontend/pages/wall_subpage/wall_page.dart';
import 'package:chatdan_frontend/provider/chatdan_provider.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'model/message_box.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // load access_token
  await ChatDanRepository().loadAccessToken();
  Intl.defaultLocale = 'zh_CN';

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
      GoRoute(path: '/askBox', builder: (context, state) => AskboxPage(provider.userInfo!.id, inHomePage: true)),
      GoRoute(
          path: '/askbox/:id',
          builder: (context, state) {
            final int id = int.parse(state.pathParameters['id']!);
            return FutureBuilder(
                future: ChatDanRepository().loadAMessageBox(id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('加载失败');
                  } else if (!snapshot.hasData) {
                    return const Text('加载失败');
                  } else {
                    return AskboxDetailPage(snapshot.data as MessageBox);
                  }
                });
          }),
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
        Locale('zh'),
      ],
      locale: const Locale('zh'),
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
