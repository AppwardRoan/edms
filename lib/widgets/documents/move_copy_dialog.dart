import 'package:edms/providers/document_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../models/folder_model.dart';
import '../../providers/folder_provider.dart';
import '../../widgets/common/custom_button.dart';

enum MoveOrCopy { move, copy }

class MoveOrCopyDocumentDialog extends ConsumerStatefulWidget {
  final List<String> documentIds;
  final String? currentFolderId;
  final MoveOrCopy mode;

  const MoveOrCopyDocumentDialog({
    super.key,
    required this.documentIds,
    this.currentFolderId,
    this.mode = MoveOrCopy.move,
  });

  @override
  ConsumerState<MoveOrCopyDocumentDialog> createState() => _MoveOrCopyDocumentDialogState();
}

class _MoveOrCopyDocumentDialogState extends ConsumerState<MoveOrCopyDocumentDialog> {
  String? _selectedFolderId;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedFolderId = widget.currentFolderId;
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
                  widget.mode == MoveOrCopy.move
                      ? 'Move ${widget.documentIds.length} Document(s)'
                      : 'Copy ${widget.documentIds.length} Document(s)',
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
                        ..._buildFolderTree(folders, null, 0),
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
                  text: widget.mode == MoveOrCopy.move ? 'Move Here' : 'Copy Here',
                  icon: widget.mode == MoveOrCopy.move ? Icons.drive_file_move : Icons.content_copy,
                  onPressed: _processAction,
                  isLoading: _isProcessing,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFolderTree(List<FolderModel> allFolders, String? parentId, int level) {
    final children = allFolders.where((f) => f.parentFolderId == parentId).toList();
    
    final widgets = <Widget>[];
    for (final folder in children) {
      // Don't show current folder when moving (can't move to itself)
      if (widget.mode == MoveOrCopy.move && folder.id == widget.currentFolderId) {
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
      widgets.addAll(_buildFolderTree(allFolders, folder.id, level + 1));
      
      if (folder != children.last) {
        widgets.add(const Divider(height: 1));
      }
    }
    
    return widgets;
  }

  Future<void> _processAction() async {
    setState(() => _isProcessing = true);

    // Call appropriate provider method based on mode
    bool success = false;
    if (widget.mode == MoveOrCopy.move) {
      success = await ref.read(documentRepositoryProvider).moveDocuments(
        widget.documentIds,
        _selectedFolderId,
      );
    } else {
      success = await ref.read(documentRepositoryProvider).copyDocuments(
        widget.documentIds,
        _selectedFolderId,
      );
    }

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.mode == MoveOrCopy.move
                ? '${widget.documentIds.length} document(s) moved successfully'
                : '${widget.documentIds.length} document(s) copied successfully',
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.mode == MoveOrCopy.move
                ? 'Failed to move documents'
                : 'Failed to copy documents',
          ),
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
                folder?.name ?? 'All Documents (Root)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                ),
              ),
            ),
            if (folder != null) ...[
              Text(
                '${folder!.documentCount} docs',
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

// Provider to get all folders (not filtered by parent)
final allFoldersProvider = FutureProvider<List<FolderModel>>((ref) async {
  final repository = ref.watch(folderRepositoryProvider);
  return repository.getAllFolders();
});