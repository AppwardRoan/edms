import 'package:edms/widgets/documents/upload_documents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/document_provider.dart';
import '../models/document_model.dart';
import '../widgets/common/custom_button.dart';
import '../utils/file_utils.dart';

class DocumentsPage extends ConsumerStatefulWidget {
  const DocumentsPage({super.key});

  @override
  ConsumerState<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends ConsumerState<DocumentsPage> {
  final _searchController = TextEditingController();
  final Set<String> _selectedDocuments = {};
  bool _isGridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final documentsState = ref.watch(documentsProvider);

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
                    'Documents',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage all your documents',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
                  ),
                ],
              ),
              CustomButton(
                text: 'Upload Document',
                icon: Icons.upload_outlined,
                onPressed: _showUploadDialog,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search & View Toggle
          Row(
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search documents...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(documentsProvider.notifier).loadDocuments();
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        ref.read(documentsProvider.notifier).loadDocuments();
                      }
                    },
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        ref.read(documentsProvider.notifier).searchDocuments(value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // View Toggle
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.grid_view,
                        color: _isGridView ? AppTheme.primaryBlue : AppTheme.textSecondary,
                      ),
                      onPressed: () => setState(() => _isGridView = true),
                      tooltip: 'Grid View',
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: AppTheme.borderColor,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.list,
                        color: !_isGridView ? AppTheme.primaryBlue : AppTheme.textSecondary,
                      ),
                      onPressed: () => setState(() => _isGridView = false),
                      tooltip: 'List View',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Selected Actions
          if (_selectedDocuments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Text(
                    '${_selectedDocuments.length} selected',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: _deleteSelected,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selectedDocuments.clear()),
                    child: const Text('Clear Selection'),
                  ),
                ],
              ),
            ),

          // Documents Content
          documentsState.when(
            data: (documents) {
              if (documents.isEmpty) {
                return _buildEmptyState();
              }
              return _isGridView
                  ? _buildGridView(documents)
                  : _buildListView(documents);
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
              Icons.description_outlined,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No documents yet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your first document to get started',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Upload Document',
              icon: Icons.upload_outlined,
              onPressed: _showUploadDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(List<DocumentModel> documents) {
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
        final doc = documents[index];
        final isSelected = _selectedDocuments.contains(doc.id);

        return _DocumentGridCard(
          document: doc,
          isSelected: isSelected,
          onTap: () => _toggleSelection(doc.id),
          onPreview: () => context.push('/documents/${doc.id}'),
          onDelete: () => _deleteDocument(doc.id),
        );
      },
    );
  }

  Widget _buildListView(List<DocumentModel> documents) {
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
                  value: _selectedDocuments.length == documents.length && documents.isNotEmpty,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedDocuments.addAll(documents.map((d) => d.id));
                      } else {
                        _selectedDocuments.clear();
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
                    'Uploaded',
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
          // Document Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: documents.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = documents[index];
              final isSelected = _selectedDocuments.contains(doc.id);

              return _DocumentListRow(
                document: doc,
                isSelected: isSelected,
                onSelect: (selected) => _toggleSelection(doc.id),
                onPreview: () => context.push('/documents/${doc.id}'),
                onDelete: () => _deleteDocument(doc.id),
              );
            },
          ),
        ],
      ),
    );
  }

  void _toggleSelection(String docId) {
    setState(() {
      if (_selectedDocuments.contains(docId)) {
        _selectedDocuments.remove(docId);
      } else {
        _selectedDocuments.add(docId);
      }
    });
  }

  Future<void> _showUploadDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const UploadDocumentDialog(),
    );

    if (result == true) {
      // Refresh documents list
      ref.read(documentsProvider.notifier).loadDocuments();
    }
  }

  Future<void> _deleteDocument(String documentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Bin'),
        content: const Text('Are you sure you want to move this document to bin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Move to Bin'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref.read(documentsProvider.notifier).moveTobin(documentId);

    if (!mounted) return;

    if (success) {
      setState(() {
        _selectedDocuments.remove(documentId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document moved to bin'),
        ),
      );

      // Refresh bin documents
      ref.read(binDocumentsProvider.notifier).loadBinDocuments();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to move document to bin'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _deleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Bin'),
        content: Text('Are you sure you want to move ${_selectedDocuments.length} document(s) to bin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Move to Bin'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    for (final docId in _selectedDocuments) {
      await ref.read(documentsProvider.notifier).moveTobin(docId);
    }

    if (!mounted) return;

    setState(() {
      _selectedDocuments.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Documents moved to bin'),
      ),
    );

    ref.read(binDocumentsProvider.notifier).loadBinDocuments();
  }
}

class _DocumentGridCard extends StatelessWidget {
  final DocumentModel document;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onPreview;
  final VoidCallback onDelete;

  const _DocumentGridCard({
    required this.document,
    required this.isSelected,
    required this.onTap,
    required this.onPreview,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // File Icon
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
                  // File Name
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
                  // File Type & Size
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
            // Selection Checkbox
            Positioned(
              top: 8,
              right: 8,
              child: Checkbox(
                value: isSelected,
                onChanged: (value) => onTap(),
                activeColor: AppTheme.primaryBlue,
              ),
            ),
            // More Options
            Positioned(
              top: 8,
              left: 8,
              child: Row(
                children: [
                  // Preview Button
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.visibility, size: 18, color: Colors.white),
                      onPressed: onPreview,
                      tooltip: 'Preview',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // More Options Menu
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: AppTheme.errorRed),
                            SizedBox(width: 8),
                            Text('Move to Bin'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentListRow extends StatelessWidget {
  final DocumentModel document;
  final bool isSelected;
  final Function(bool) onSelect;
  final VoidCallback onPreview;
  final VoidCallback onDelete;

  const _DocumentListRow({
    required this.document,
    required this.isSelected,
    required this.onSelect,
    required this.onPreview,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelect(!isSelected),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (value) => onSelect(value ?? false),
              activeColor: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Icon(
                    FileUtils.getFileIcon(document.type),
                    color: FileUtils.getFileColor(document.type),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.fileName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (document.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            document.description!,
                            style: const TextStyle(fontSize: 12,color: AppTheme.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: FileUtils.getFileColor(document.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  document.type.extension.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: FileUtils.getFileColor(document.type),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                DateFormat('MMM dd, yyyy').format(document.uploadedAt),
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ),
            Expanded(
              child: Text(
                document.size,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, size: 20),
                    onPressed: onPreview,
                    tooltip: 'Preview',
                    color: AppTheme.primaryBlue,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                    tooltip: 'Move to Bin',
                    color: AppTheme.errorRed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}