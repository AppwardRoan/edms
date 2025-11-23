import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/home_page.dart';
import '../pages/documents_page.dart';
import '../pages/folders_page.dart';
import '../pages/users_page.dart';
import '../pages/settings_page.dart';
import '../widgets/layout/main_layout.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null; // Check if user is logged in
      final isLoginRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register'; // Login/Register routes

      /*
      Scenario Table for User:

      | User’s status  | Page he tries to visit | isLoggedIn | isLoginRoute | What happens?                                      |
      |----------------|------------------------|------------|--------------|--------------------------------------------        |
      | Not logged in  | /login or /register    | false      | true         | Allowed (User can see login/register)              |
      | Not logged in  | /home, /folders, etc.  | false      | false        | Redirect to /login (cannot access protected pages) |
      | Logged in      | /login or /register    | true       | true         | Redirect to /home (cannot access login/register)   |
      | Logged in      | /home, /folders, etc.  | true       | false        | Allowed (can access protected pages)               |
      */

      // If not logged in and trying to access protected route
      if (!isLoggedIn && !isLoginRoute) { // false, false
        return '/login'; // Scenario: Not logged in & protected page → redirect to login
      }
      
      // If logged in and trying to access login/register
      if (isLoggedIn && isLoginRoute) { // true, true
        return '/home'; // Scenario: Logged in & tries to access login/register → redirect to home

      }
      // Otherwise, no redirect
      // Scenario: 
      // 1. Not logged in & on /login or /register → stays 
      // 2. Logged in & on a protected page → stays
      return null;
    },
    routes: [
      // Auth Routes (without layout)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      
      // Protected Routes (with sidebar layout)
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/documents',
            builder: (context, state) => const DocumentsPage(),
          ),
          GoRoute(
            path: '/folders',
            builder: (context, state) => const FoldersPage(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
});