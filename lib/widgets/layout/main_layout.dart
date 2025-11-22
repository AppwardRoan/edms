import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'sidebar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          // Sidebar
          const Sidebar(),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top AppBar
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        // Search Bar (placeholder)
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search documents...',
                                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                                filled: true,
                                fillColor: AppTheme.backgroundLight,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Notification Icon
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {},
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Page Content
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}