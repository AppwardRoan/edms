import 'package:edms/models/document_model.dart';
import 'package:edms/theme/app_theme.dart';
import 'package:edms/utils/file_utils.dart';
import 'package:flutter/material.dart';

class DocumentGridCard extends StatelessWidget {
  final DocumentModel document;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DocumentGridCard({
    required this.document,
    required this.isSelected,
    required this.onTap,
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
              child: PopupMenuButton(
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
            ),
          ],
        ),
      ),
    );
  }
}
