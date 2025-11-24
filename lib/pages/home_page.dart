import 'package:edms/widgets/homepage/folder_row.dart';
import 'package:edms/widgets/homepage/recent_file_card.dart';
import 'package:edms/widgets/homepage/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../constants/app_constants.dart';
import 'package:intl/intl.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Just now';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentUser = authState.value;

    

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Text(
            'Welcome back, ${currentUser?.firstName ?? 'User'}! 👋',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s what\'s happening with your documents today.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.description_outlined,
                  title: 'Total Documents',
                  value: '1,234',
                  color: AppTheme.primaryBlue,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  icon: Icons.folder_outlined,
                  title: 'Total Folders',
                  value: '45',
                  color: AppTheme.secondaryBlue,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  icon: Icons.upload_outlined,
                  title: 'Uploads Today',
                  value: '12',
                  color: AppTheme.successGreen,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  icon: Icons.storage_outlined,
                  title: 'Storage Used',
                  value: '45 GB',
                  color: AppTheme.warningOrange,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Recent Files Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent files',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Recent Files Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: AppConstants.mockRecentFiles.length,
            itemBuilder: (context, index) {
              final file = AppConstants.mockRecentFiles[index];
              return RecentFileCard(
                fileName: file.name,
                fileType: file.type,
                date: _formatDate(file.date),
              );
            },
          ),
          const SizedBox(height: 40),

          // Folders Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text('Folders',style: Theme.of(context).textTheme.titleLarge),

              TextButton(
                onPressed: () {},
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Folders Table
          Card(
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 40),
                      const Expanded(
                        flex: 3,
                        child: Text(
                          'Name',
                          style: TextStyle(fontWeight: FontWeight.w600,fontSize: 14),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Date',
                          style: TextStyle(fontWeight: FontWeight.w600,fontSize: 14,color: AppTheme.textSecondary,
),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Size',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                // Folder Rows
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: AppConstants.mockFolders.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final folder = AppConstants.mockFolders[index];
                    return FolderRow(
                      folderName: folder.name,
                      date: DateFormat('MM/dd/yyyy hh:mm a').format(folder.date),
                      fileCount: '${folder.fileCount} files',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
