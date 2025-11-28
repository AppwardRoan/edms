import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../providers/folder_provider.dart';
import '../../providers/auth_provider.dart';

class CreateFolderDialog extends ConsumerStatefulWidget {
  const CreateFolderDialog({super.key});

  @override
  ConsumerState<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends ConsumerState<CreateFolderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createFolder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    final currentUser = ref.read(authProvider).value;
    if (currentUser == null) {
      if (!mounted) return;
      setState(() => _isCreating = false);
      return;
    }

    final folder = await ref.read(foldersProvider.notifier).createFolder(
          name: _nameController.text.trim(),
          createdBy: currentUser.id,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );

    if (!mounted) return;

    setState(() => _isCreating = false);

    if (folder != null) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Folder created successfully'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create folder'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create New Folder',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Folder Icon Preview
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.folder,
                    size: 64,
                    color: AppTheme.secondaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Folder Name
              CustomTextField(
                label: 'Folder Name',
                hintText: 'Enter folder name',
                controller: _nameController,
                prefixIcon: Icons.create_new_folder,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter folder name';
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
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'Cancel',
                    onPressed: _isCreating
                        ? null
                        : () => Navigator.of(context).pop(),
                    isOutlined: true,
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    text: 'Create',
                    icon: Icons.create_new_folder,
                    onPressed: _createFolder,
                    isLoading: _isCreating,
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