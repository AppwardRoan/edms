import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';

final sidebarExpandedProvider = StateProvider<bool>((ref) => true);

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(sidebarExpandedProvider);
    final authState = ref.watch(authProvider);
    final currentUser = authState.value;
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? 250 : 90,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo & Toggle
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.borderColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                if (isExpanded) ...[
                  Expanded(
                    child: const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
                if (!isExpanded) const Spacer(),
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.menu_open : Icons.menu,
                    color: AppTheme.primaryBlue,
                  ),
                  onPressed: () {
                    ref.read(sidebarExpandedProvider.notifier).state = !isExpanded;
                  },
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: AppConstants.sidebarItems.map((item) {
                // Check if user has required role
                if (item.requiredRole != null && currentUser != null) {
                  if (!currentUser.hasRole(item.requiredRole!)) {
                    return const SizedBox.shrink();
                  }
                }

                final isActive = currentRoute == item.route;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Material(
                    color: isActive ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () => context.go(item.route),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Text(
                              item.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                            if (isExpanded) ...[
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                    color: isActive ? AppTheme.primaryBlue : AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // User Profile & Logout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.borderColor, width: 1),
              ),
            ),
            child: Column(
              children: [
                if (currentUser != null) ...[
                  if (isExpanded) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryBlue,
                          child: Text(
                            currentUser.firstName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentUser.fullName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                currentUser.roleLabel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(authProvider.notifier).logout();
                        },
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Logout'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ] else ...[
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppTheme.errorRed),
                      onPressed: () {
                        ref.read(authProvider.notifier).logout();
                      },
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}