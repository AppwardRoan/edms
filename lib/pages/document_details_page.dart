import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/document_model.dart';
import '../providers/document_provider.dart';
import '../utils/file_utils.dart';
import '../constants/app_constants.dart';

class DocumentDetailsPage extends ConsumerWidget {
  final String documentId;

  const DocumentDetailsPage({super.key, required this.documentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsState = ref.watch(documentsProvider);

    return documentsState.when(
      data: (documents) {
        // Find document by ID
        DocumentModel? document;
        try {
          document = documents.firstWhere((doc) => doc.id == documentId);
        } catch (e) {
          return _buildNotFound(context);
        }

        return _buildDetailsPage(context, ref, document);
      },
      loading:
          () => Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, stack) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Error: $error')),
          ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 80,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Document not found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/documents'),
              child: const Text('Back to Documents'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsPage(
    BuildContext context,
    WidgetRef ref,
    DocumentModel document,
  ) {
    final uploader = AppConstants.mockUsers.firstWhere(
      (user) => user.id == document.uploadedBy,
      orElse: () => AppConstants.mockUsers.first,
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(document.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(), 
        ),
        actions: [
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'More actions',
              offset: const Offset(0, 45),
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'favorite',
                      child: Row(
                        children: [
                          Icon(Icons.star_outline,size: 20,color: AppTheme.warningOrange),
                          SizedBox(width: 12),
                          Text('Add to Favorites'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(Icons.download_outlined,size: 20,color: AppTheme.primaryBlue),
                          SizedBox(width: 12),
                          Text('Download'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share_outlined,size: 20,color: AppTheme.primaryBlue),
                          SizedBox(width: 12),
                          Text('Share'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,size: 20,color: AppTheme.errorRed),
                          SizedBox(width: 12),
                          Text('Move to Bin'),
                        ],
                      ),
                    ),
                  ],
              onSelected: (value) {
                switch (value) {
                  case 'favorite':
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to favorites')));
                    break;
                  case 'download':
                    _downloadDocument(context, document);
                    break;
                  case 'share':
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share feature coming soon')));
                    break;
                  case 'delete':
                    _showDeleteDialog(context, ref, document);
                    break;
                }
              },
            ),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Content - Document Preview
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Document Name
                  Text(
                    document.name,
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Document Preview/Icon
                  _buildDocumentPreview(document),
                  const SizedBox(height: 24),

                  // File Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                        decoration: BoxDecoration(
                          color: FileUtils.getFileColor(document.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          document.type.extension.toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: FileUtils.getFileColor(document.type),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        document.size,
                        style: const TextStyle(fontSize: 14,color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Right Sidebar - Details & Collaborators
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(-2, 0),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Collaborators Section
                  const Text(
                    'Collaborators',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _buildCollaborator(
                    name: uploader.fullName,
                    role: 'Owner',
                    avatarText: uploader.firstName[0],
                  ),
                  const SizedBox(height: 8),
                  _buildCollaborator(
                    name: 'Jennifer Hudson',
                    role: 'Editor',
                    avatarText: 'J',
                  ),
                  const SizedBox(height: 8),
                  _buildCollaborator(
                    name: 'James Dean',
                    role: 'Viewer',
                    avatarText: 'J',
                  ),
                  const SizedBox(height: 32),

                  // Document Details
                  const Text(
                    'Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  // Owner
                  _buildDetailRow('Owner', uploader.fullName),
                  const SizedBox(height: 16),

                  // Description
                  _buildDetailRow(
                    'Description',
                    document.description ?? 'No description provided',
                  ),
                  const SizedBox(height: 16),

                  // Created At
                  _buildDetailRow(
                    'Created at',
                    DateFormat('MM/dd/yyyy hh:mm a').format(document.uploadedAt),
                  ),
                  const SizedBox(height: 16),

                  // Modified By
                  _buildDetailRow(
                    'Modified By',
                    document.modifiedAt != null
                        ? '${uploader.fullName} on ${DateFormat('MM/dd/yyyy').format(document.modifiedAt!)}'
                        : 'Not modified',
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  if (document.tags.isNotEmpty) ...[
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          document.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(fontSize: 12,color: AppTheme.primaryBlue),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // File Info
                  _buildDetailRow('File Name', document.fileName),
                  const SizedBox(height: 16),
                  _buildDetailRow('File Size', document.size),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'File Type',
                    document.type.extension.toUpperCase(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPreview(DocumentModel document) {
    return Container(
      width: 600,
      height: 700,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FileUtils.getFileIcon(document.type),
            size: 120,
            color: FileUtils.getFileColor(document.type),
          ),
          const SizedBox(height: 24),
          Text(
            document.fileName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Preview not available',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Click download to view the file',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaborator({
    required String name,
    required String role,
    required String avatarText,
  }) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppTheme.primaryBlue,
          radius: 20,
          child: Text(
            avatarText,
            style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w600),
              ),
              Text(
                role,
                style: const TextStyle(fontSize: 12,color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  void _downloadDocument(BuildContext context, DocumentModel document) {
    // Mock download - In production, this would trigger actual file download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.download, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Download Started',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    document.fileName,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    DocumentModel document,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Move to Bin'),
            content: Text('Are you sure you want to move "${document.name}" to bin?'),
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

    final success = await ref.read(documentsProvider.notifier).moveTobin(document.id);

    if (!context.mounted) return;

    if (success) {
      // Refresh bin documents list
      ref.read(binDocumentsProvider.notifier).loadBinDocuments();

      context.go('/documents');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document moved to bin')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to move document to bin'),backgroundColor: AppTheme.errorRed),
      );
    }
  }
}
