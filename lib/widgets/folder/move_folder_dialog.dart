import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../models/folder_model.dart';
import '../../providers/folder_provider.dart';
import '../../widgets/common/custom_button.dart';

class MoveFolderDialog extends ConsumerStatefulWidget {
  final String folderId;
  final String? currentParentId;

  const MoveFolderDialog({
    super.key,
    required this.folderId,
    this.currentParentId,
  });

  @override
  ConsumerState<MoveFolderDialog> createState() => _MoveFolderDialogState();
}

class _MoveFolderDialogState extends ConsumerState<MoveFolderDialog> {
  String? _selectedFolderId;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedFolderId = widget.currentParentId;
  }

  @override
  Widget build(BuildContext context) {
    final foldersAsync = ref.watch(allFoldersProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Move Folder',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select destination folder',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Folder List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: foldersAsync.when(
                  data: (folders) {
                    // Get subfolders of the folder being moved (to prevent moving into its own children)
                    final movingFolderSubfolders = _getSubfolderIds(folders, widget.folderId);
                    
                    return ListView(
                      children: [
                        // Root folder option
                        _FolderTile(
                          folder: null,
                          isSelected: _selectedFolderId == null,
                          onTap: () {
                            setState(() {
                              _selectedFolderId = null;
                            });
                          },
                          level: 0,
                        ),
                        const Divider(height: 1),
                        // Folder tree
                        ..._buildFolderTree(folders, null, 0, movingFolderSubfolders),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Error loading folders: $error'),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  text: 'Cancel',
                  onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                  isOutlined: true,
                ),
                const SizedBox(width: 12),
                CustomButton(
                  text: 'Move Here',
                  icon: Icons.drive_file_move,
                  onPressed: _processMove,
                  isLoading: _isProcessing,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Set<String> _getSubfolderIds(List<FolderModel> allFolders, String parentId) {
    final subfolderIds = <String>{};
    final directChildren = allFolders.where((f) => f.parentFolderId == parentId).toList();
    
    for (final child in directChildren) {
      subfolderIds.add(child.id);
      subfolderIds.addAll(_getSubfolderIds(allFolders, child.id));
    }
    
    return subfolderIds;
  }

  List<Widget> _buildFolderTree(
    List<FolderModel> allFolders,
    String? parentId,
    int level,
    Set<String> excludedIds,
  ) {
    final children = allFolders.where((f) => f.parentFolderId == parentId).toList();
    
    final widgets = <Widget>[];
    for (final folder in children) {
      // Don't show the folder being moved or its children
      if (folder.id == widget.folderId || excludedIds.contains(folder.id)) {
        continue;
      }

      widgets.add(_FolderTile(
        folder: folder,
        isSelected: _selectedFolderId == folder.id,
        onTap: () {
          setState(() {
            _selectedFolderId = folder.id;
          });
        },
        level: level,
      ));
      
      // Add children recursively
      widgets.addAll(_buildFolderTree(allFolders, folder.id, level + 1, excludedIds));
      
      if (folder != children.last) {
        widgets.add(const Divider(height: 1));
      }
    }
    
    return widgets;
  }

  Future<void> _processMove() async {
    setState(() => _isProcessing = true);

    final success = await ref.read(folderRepositoryProvider).moveFolder(
      widget.folderId,
      _selectedFolderId,
    );

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Folder moved successfully'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to move folder'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }
}

class _FolderTile extends StatelessWidget {
  final FolderModel? folder;
  final bool isSelected;
  final VoidCallback onTap;
  final int level;

  const _FolderTile({
    required this.folder,
    required this.isSelected,
    required this.onTap,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: 16.0 + (level * 24.0),
          right: 16,
          top: 12,
          bottom: 12,
        ),
        color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : null,
        child: Row(
          children: [
            Icon(
              folder == null ? Icons.home : Icons.folder,
              color: isSelected 
                  ? AppTheme.primaryBlue 
                  : folder == null 
                      ? AppTheme.textPrimary 
                      : AppTheme.secondaryBlue,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                folder?.name ?? 'Root',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                ),
              ),
            ),
            if (folder != null) ...[
              Text(
                '${folder!.subfolderCount} folders',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}