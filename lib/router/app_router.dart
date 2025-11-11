import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/pages/home_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: HomePage()),
    ),
  ],
  errorBuilder: (ctx, st) => Scaffold(body: Center(child: Text(st.toString()))),
);
