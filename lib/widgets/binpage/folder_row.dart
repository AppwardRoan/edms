import 'package:edms/models/folder_model.dart';
import 'package:edms/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FolderRow extends StatelessWidget {
  final FolderModel folder;
  final bool isSelected;
  final Function(bool) onSelect;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const FolderRow({
    required this.folder,
    required this.isSelected,
    required this.onSelect,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = folder.daysUntilAutoDelete ?? 0;
    
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
                  const Icon(
                    Icons.folder,
                    color: AppTheme.secondaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      folder.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Folder',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryBlue,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                DateFormat('MMM dd, yyyy').format(folder.deletedAt!),
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: daysLeft <= 5 ? AppTheme.errorRed.withOpacity(0.1) : AppTheme.warningOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$daysLeft days',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: daysLeft <= 5 ? AppTheme.errorRed : AppTheme.warningOrange,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${folder.documentCount} items',
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
                    icon: const Icon(Icons.restore, size: 20),
                    onPressed: onRestore,
                    tooltip: 'Restore',
                    color: AppTheme.successGreen,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever, size: 20),
                    onPressed: onDelete,
                    tooltip: 'Delete Permanently',
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