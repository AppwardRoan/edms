import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/folder_provider.dart';

class BreadcrumbNavigation extends ConsumerWidget {
  const BreadcrumbNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFolderId = ref.watch(currentFolderIdProvider);
    final folderPathAsync = ref.watch(folderPathProvider);

    return folderPathAsync.when(
      data: (path) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Home / All Documents
              _BreadcrumbItem(
                label: 'All Documents',
                icon: Icons.home,
                isActive: currentFolderId == null,
                onTap: () {
                  ref.read(currentFolderIdProvider.notifier).state = null;
                  ref.read(foldersProvider.notifier).loadFolders();
                },
              ),
              
              // Folder path
              ...path.asMap().entries.map((entry) {
                final index = entry.key;
                final folder = entry.value;
                final isLast = index == path.length - 1;
                
                return Row(
                  children: [
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    _BreadcrumbItem(
                      label: folder.name,
                      icon: Icons.folder,
                      isActive: isLast,
                      onTap: () {
                        ref.read(currentFolderIdProvider.notifier).state = folder.id;
                        ref.read(foldersProvider.notifier).loadFolders();
                      },
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

class _BreadcrumbItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _BreadcrumbItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isActive ? null : onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}