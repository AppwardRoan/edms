import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/folder_provider.dart';
import '../../models/folder_model.dart';

class DocumentLocationWidget extends ConsumerWidget {
  final String? folderId;
  final bool showIcon;
  final double fontSize;

  const DocumentLocationWidget({
    super.key,
    required this.folderId,
    this.showIcon = true,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If no folder, show root
    if (folderId == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.folder_outlined,
              size: fontSize + 2,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            'All Documents',
            style: TextStyle(
              fontSize: fontSize,
              color: AppTheme.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    // Get folder path
    final repository = ref.watch(folderRepositoryProvider);
    
    return FutureBuilder<List<FolderModel>>(
      future: repository.getFolderPath(folderId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon) ...[
                Icon(
                  Icons.folder_outlined,
                  size: fontSize + 2,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                'Unknown',
                style: TextStyle(
                  fontSize: fontSize,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          );
        }

        final path = snapshot.data!;
        final pathString = path.map((f) => f.name).join(' / ');

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                Icons.folder_outlined,
                size: fontSize + 2,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                pathString,
                style: TextStyle(
                  fontSize: fontSize,
                  color: AppTheme.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}