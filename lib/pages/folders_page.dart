import 'package:edms/widgets/documents/upload_documents.dart';
import 'package:edms/widgets/folder/bread_crumbs_navigation.dart';
import 'package:edms/widgets/folder/create_folder_dialog.dart';
import 'package:edms/widgets/folder/move_folder_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/folder_provider.dart';
import '../providers/document_provider.dart';
import '../models/folder_model.dart';
import '../models/document_model.dart';
import '../widgets/common/custom_button.dart';
import '../utils/file_utils.dart';

class FoldersPage extends ConsumerStatefulWidget {
  const FoldersPage({super.key});

  @override
  ConsumerState<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends ConsumerState<FoldersPage> {
  @override
  Widget build(BuildContext context) {
    final currentFolderId = ref.watch(currentFolderIdProvider);
    final foldersState = ref.watch(foldersProvider);
    final documentsState = ref.watch(documentsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Breadcrumb
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentFolderId == null ? 'All Documents' : 'Folder Contents',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    const BreadcrumbNavigation(),
                  ],
                ),
              ),
              Row(
                children: [
                  CustomButton(
                    text: 'New Folder',
                    icon: Icons.create_new_folder_outlined,
                    onPressed: _showCreateFolderDialog,
                    isOutlined: true,
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    text: 'Upload',
                    icon: Icons.upload_outlined,
                    onPressed: _showUploadDialog,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Content (Folders + Documents)
          foldersState.when(
            data: (folders) {
              return documentsState.when(
                data: (documents) {
                  // Filter documents by current folder
                  final folderDocuments = currentFolderId == null
                      ? documents.where((d) => d.folderId == null).toList()
                      : documents.where((d) => d.folderId == currentFolderId).toList();

                  if (folders.isEmpty && folderDocuments.isEmpty) {
                    return _buildEmptyState();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Folders Section
                      if (folders.isNotEmpty) ...[
                        Text(
                          'Folders',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildFoldersGrid(folders),
                        const SizedBox(height: 32),
                      ],

                      // Documents Section
                      if (folderDocuments.isNotEmpty) ...[
                        Text(
                          'Documents',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildDocumentsGrid(folderDocuments),
                      ],
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Text('Error loading documents: $error'),
                ),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Text('Error loading folders: $error'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'This folder is empty',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a folder or upload documents to get started',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoldersGrid(List<FolderModel> folders) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        return _FolderCard(folder: folders[index]);
      },
    );
  }

  Widget _buildDocumentsGrid(List<DocumentModel> documents) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        return _DocumentCard(document: documents[index]);
      },
    );
  }

  Future<void> _showCreateFolderDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const CreateFolderDialog(),
    );
  }

  Future<void> _showUploadDialog() async {
    final currentFolderId = ref.read(currentFolderIdProvider);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => UploadDocumentDialog(folderId: currentFolderId),
    );

    if (result == true) {
      ref.read(documentsProvider.notifier).loadDocuments();
    }
  }
}

class _FolderCard extends ConsumerWidget {
  final FolderModel folder;

  const _FolderCard({required this.folder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: () {
          // Navigate into folder
          ref.read(currentFolderIdProvider.notifier).state = folder.id;
          ref.read(foldersProvider.notifier).loadFolders();
        },
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder,
                    size: 64,
                    color: AppTheme.secondaryBlue,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    folder.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${folder.documentCount + folder.subfolderCount} items',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // More Options
            Positioned(
              top: 8,
              right: 8,
              child: PopupMenuButton(
                icon: const Icon(Icons.more_vert, size: 20),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'move',
                    child: Row(
                      children: [
                        Icon(Icons.drive_file_move, size: 18),
                        SizedBox(width: 8),
                        Text('Move to...'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Rename'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: AppTheme.errorRed),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'move') {
                    _showMoveFolderDialog(context, ref, folder);
                  } else if (value == 'rename') {
                    _showRenameDialog(context, ref, folder);
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, ref, folder);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoveFolderDialog(BuildContext context, WidgetRef ref, FolderModel folder) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => MoveFolderDialog(
        folderId: folder.id,
        currentParentId: folder.parentFolderId,
      ),
    );

    if (result == true) {
      ref.read(foldersProvider.notifier).loadFolders();
    }
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, FolderModel folder) {
    final controller = TextEditingController(text: folder.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Folder Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                Navigator.pop(context);
                final success = await ref.read(foldersProvider.notifier).renameFolder(
                      folder.id,
                      newName,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Folder renamed' : 'Failed to rename folder'),
                      backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
                    ),
                  );
                }
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, FolderModel folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text(
          folder.isEmpty
              ? 'Are you sure you want to delete "${folder.name}"?'
              : 'This folder contains ${folder.documentCount + folder.subfolderCount} items. Please empty it first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (folder.isEmpty)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await ref.read(foldersProvider.notifier).moveTobin(folder.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Folder moved to bin' : 'Failed to delete folder'),
                      backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
                    ),
                  );
                  if (success) {
                    ref.read(binFoldersProvider.notifier).loadBinFolders();
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
              child: const Text('Delete'),
            ),
        ],
      ),
    );
  }
}

class _DocumentCard extends ConsumerWidget {
  final DocumentModel document;

  const _DocumentCard({required this.document});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: () => context.go('/documents/${document.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FileUtils.getFileColor(document.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      FileUtils.getFileIcon(document.type),
                      size: 48,
                      color: FileUtils.getFileColor(document.type),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                document.fileName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: FileUtils.getFileColor(document.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      document.type.extension.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: FileUtils.getFileColor(document.type),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    document.size,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}