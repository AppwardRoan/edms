import 'package:edms/models/document_model.dart';
import 'package:edms/theme/app_theme.dart';
import 'package:edms/utils/file_utils.dart';
import 'package:flutter/material.dart';
class DocumentListRow extends StatelessWidget {
  final DocumentModel document;
  final bool isSelected;
  final Function(bool) onSelect;
  final VoidCallback onDelete;

  const DocumentListRow({
    required this.document,
    required this.isSelected,
    required this.onSelect,
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
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
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
                  document.uploadedBy.toUpperCase(),
                // DateFormat('MMM dd, yyyy').format(document.uploadedAt),
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