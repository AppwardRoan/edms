import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../providers/document_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/file_utils.dart';

class UploadDocumentDialog extends ConsumerStatefulWidget {
  final String? folderId;

  const UploadDocumentDialog({super.key, this.folderId});

  @override
  ConsumerState<UploadDocumentDialog> createState() => _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends ConsumerState<UploadDocumentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  PlatformFile? _selectedFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: FileUtils.allowedExtensions,
        withData: true, // For web
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Validate file size (max 100MB)
        if (!FileUtils.isFileSizeValid(file.size)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File size must be less than 100MB'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
          return;
        }

        setState(() {
          _selectedFile = file;
          // Auto-fill name from filename (without extension)
          if (_nameController.text.isEmpty) {
            final nameWithoutExt = file.name.split('.').first;
            _nameController.text = nameWithoutExt;
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _uploadDocument() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file first'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    final currentUser = ref.read(authProvider).value;
    if (currentUser == null) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      return;
    }

    // Parse tags
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    // Get document type from file extension
    final docType = FileUtils.getDocumentTypeFromExtension(_selectedFile!.name);

    final success = await ref.read(documentsProvider.notifier).uploadDocument(
          name: _nameController.text.trim(),
          fileName: _selectedFile!.name,
          type: docType,
          size: FileUtils.formatFileSize(_selectedFile!.size),
          sizeInBytes: _selectedFile!.size,
          folderId: widget.folderId,
          uploadedBy: currentUser.id,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          tags: tags,
          fileBytes: _selectedFile!.bytes, // Pass actual file bytes!
        );

    if (!mounted) return;

    setState(() => _isUploading = false);

    if (success) {
      Navigator.of(context).pop(true); // Return true to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document uploaded successfully'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upload document'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upload Document',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // File Picker Area
                InkWell(
                  onTap: _isUploading ? null : _pickFile,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedFile != null
                            ? AppTheme.primaryBlue
                            : AppTheme.borderColor,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: _selectedFile != null
                          ? AppTheme.primaryBlue.withOpacity(0.05)
                          : AppTheme.backgroundLight,
                    ),
                    child: _selectedFile == null
                        ? Column(
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 64,
                                color: AppTheme.primaryBlue.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Click to select file',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Supported: PDF, DOC, XLS, PPT, Images, ZIP (Max 100MB)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: FileUtils.getFileColor(
                                    FileUtils.getDocumentTypeFromExtension(_selectedFile!.name),
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  FileUtils.getFileIcon(
                                    FileUtils.getDocumentTypeFromExtension(_selectedFile!.name),
                                  ),
                                  color: FileUtils.getFileColor(
                                    FileUtils.getDocumentTypeFromExtension(_selectedFile!.name),
                                  ),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedFile!.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      FileUtils.formatFileSize(_selectedFile!.size),
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _selectedFile = null;
                                  });
                                },
                                color: AppTheme.errorRed,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Document Name
                CustomTextField(
                  label: 'Document Name',
                  hintText: 'Enter document name',
                  controller: _nameController,
                  prefixIcon: Icons.edit_document,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter document name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Description
                CustomTextField(
                  label: 'Description (Optional)',
                  hintText: 'Enter description',
                  controller: _descriptionController,
                  prefixIcon: Icons.description_outlined,
                ),
                const SizedBox(height: 20),

                // Tags
                CustomTextField(
                  label: 'Tags (Optional)',
                  hintText: 'Enter tags separated by commas',
                  controller: _tagsController,
                  prefixIcon: Icons.label_outlined,
                ),
                const SizedBox(height: 8),
                Text(
                  'Example: finance, report, Q4',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      text: 'Cancel',
                      onPressed: _isUploading
                          ? null
                          : () => Navigator.of(context).pop(),
                      isOutlined: true,
                    ),
                    const SizedBox(width: 12),
                    CustomButton(
                      text: 'Upload',
                      icon: Icons.upload,
                      onPressed: _uploadDocument,
                      isLoading: _isUploading,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}