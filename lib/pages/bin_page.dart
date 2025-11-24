import 'package:edms/widgets/binpage/document_row.dart';
import 'package:edms/widgets/binpage/folder_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/document_provider.dart';
import '../models/document_model.dart';
import '../constants/app_constants.dart';
import '../models/folder_model.dart';
import '../widgets/common/custom_button.dart';

class BinPage extends ConsumerStatefulWidget {
  const BinPage({super.key});

  @override
  ConsumerState<BinPage> createState() => _BinPageState();
}

class _BinPageState extends ConsumerState<BinPage> {
  final Set<String> _selectedDocuments = {};
  final Set<String> _selectedFolders = {};

  @override
  Widget build(BuildContext context) {
    final binDocsState = ref.watch(binDocumentsProvider);
    final binFolders = AppConstants.mockBinFolders; // Using mock folders for now

    final totalSelected = _selectedDocuments.length + _selectedFolders.length;
    final totalItems = (binDocsState.value?.length ?? 0) + binFolders.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bin',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Items in bin will be permanently deleted after 30 days',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
                  ),
                ],
              ),
              if (totalSelected > 0)
                Row(
                  children: [
                    CustomButton(
                      text: 'Restore Selected ($totalSelected)',
                      icon: Icons.restore,
                      onPressed: _restoreSelected,
                      isOutlined: true,
                    ),
                    const SizedBox(width: 12),
                    CustomButton(
                      text: 'Delete Selected ($totalSelected)',
                      icon: Icons.delete_forever,
                      onPressed: () => _showDeleteConfirmation(context, true),
                    ),
                  ],
                )
              else
                CustomButton(
                  text: 'Empty Bin',
                  icon: Icons.delete_sweep,
                  // onPressed: totalItems == 0
                  //     ? null
                  //     : () => _showEmptyBinConfirmation(context),
                  onPressed: () => _showEmptyBinConfirmation(context)
                ),
            ],
          ),
          const SizedBox(height: 32),

          // Content
          binDocsState.when(
            data: (documents) {
              if (documents.isEmpty && binFolders.isEmpty) {
                return _buildEmptyState();
              }
              return _buildItemsList(documents, binFolders);
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Text('Error: $error'),
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
              Icons.delete_outline,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Bin is empty',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Deleted items will appear here',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(List<DocumentModel> documents, List<FolderModel> folders) {
    final allItemsCount = documents.length + folders.length;
    final allSelected = _selectedDocuments.length + _selectedFolders.length == allItemsCount && allItemsCount > 0;

    return Card(
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
                Checkbox(
                  value: allSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedDocuments.addAll(documents.map((d) => d.id));
                        _selectedFolders.addAll(folders.map((f) => f.id));
                      } else {
                        _selectedDocuments.clear();
                        _selectedFolders.clear();
                      }
                    });
                  },
                  activeColor: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Type',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Deleted',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Days Left',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Size',
                    style: TextStyle(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 100),
              ],
            ),
          ),
          
          // Folders First, Then Documents
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Folders
              ...folders.map((folder) => Column(
                children: [
                  FolderRow(
                    folder: folder,
                    isSelected: _selectedFolders.contains(folder.id),
                    onSelect: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedFolders.add(folder.id);
                        } else {
                          _selectedFolders.remove(folder.id);
                        }
                      });
                    },
                    onRestore: () => _restoreFolder(folder.id),
                    onDelete: () => _showDeleteFolderConfirmation(context, folder.id),
                  ),
                  const Divider(height: 1),
                ],
              )),
              
              // Documents
              ...documents.map((doc) => Column(
                children: [
                  DocumentRow(
                    document: doc,
                    isSelected: _selectedDocuments.contains(doc.id),
                    onSelect: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDocuments.add(doc.id);
                        } else {
                          _selectedDocuments.remove(doc.id);
                        }
                      });
                    },
                    onRestore: () => _restoreDocument(doc.id),
                    onDelete: () => _showDeleteConfirmation(context, false, doc.id),
                  ),
                  if (doc != documents.last) const Divider(height: 1),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _restoreDocument(String documentId) async {
    final success = await ref.read(binDocumentsProvider.notifier).restoreDocument(documentId);
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document restored successfully'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      ref.read(documentsProvider.notifier).loadDocuments();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to restore document'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _restoreFolder(String folderId) async {
    // TODO: Implement folder restore when folder provider is ready
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Folder restored successfully (mock)'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
    
    setState(() {
      _selectedFolders.remove(folderId);
    });
  }

  Future<void> _restoreSelected() async {
    // Restore documents
    for (final docId in _selectedDocuments) {
      await ref.read(binDocumentsProvider.notifier).restoreDocument(docId);
    }
    
    // Restore folders (mock for now)
    for (final folderId in _selectedFolders) {
      // TODO: Implement when folder provider is ready
    }
    
    if (!mounted) return;
    
    setState(() {
      _selectedDocuments.clear();
      _selectedFolders.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Items restored successfully'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
    ref.read(documentsProvider.notifier).loadDocuments();
  }

  void _showDeleteConfirmation(BuildContext context, bool isMultiple, [String? documentId]) {
    final count = _selectedDocuments.length + _selectedFolders.length;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permanent Delete'),
        content: Text(
          isMultiple
              ? 'Are you sure you want to permanently delete $count item(s)? This action cannot be undone.'
              : 'Are you sure you want to permanently delete this document? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (isMultiple) {
                _deleteSelected();
              } else if (documentId != null) {
                _deleteDocument(documentId);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteFolderConfirmation(BuildContext context, String folderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permanent Delete'),
        content: const Text(
          'Are you sure you want to permanently delete this folder? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFolder(folderId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDocument(String documentId) async {
    final success = await ref.read(binDocumentsProvider.notifier).permanentlyDelete(documentId);
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document permanently deleted'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete document'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _deleteFolder(String folderId) async {
    // TODO: Implement when folder provider is ready
    if (!mounted) return;
    
    setState(() {
      _selectedFolders.remove(folderId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Folder permanently deleted (mock)'),
      ),
    );
  }

  Future<void> _deleteSelected() async {
    // Delete documents
    for (final docId in _selectedDocuments) {
      await ref.read(binDocumentsProvider.notifier).permanentlyDelete(docId);
    }
    
    // Delete folders (mock for now)
    for (final folderId in _selectedFolders) {
      // TODO: Implement when folder provider is ready
    }
    
    if (!mounted) return;
    
    setState(() {
      _selectedDocuments.clear();
      _selectedFolders.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Items permanently deleted'),
      ),
    );
  }

  void _showEmptyBinConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Bin'),
        content: const Text(
          'Are you sure you want to permanently delete all items in the bin? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _emptyBin();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Empty Bin'),
          ),
        ],
      ),
    );
  }

  Future<void> _emptyBin() async {
    final success = await ref.read(binDocumentsProvider.notifier).emptyBin();
    
    // TODO: Also empty folders when folder provider is ready
    
    if (!mounted) return;
    
    if (success) {
      setState(() {
        _selectedDocuments.clear();
        _selectedFolders.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bin emptied successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to empty bin'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }
}
