import 'package:edms/models/document_model.dart';
import 'package:edms/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DocumentRow extends StatelessWidget {
  final DocumentModel document;
  final bool isSelected;
  final Function(bool) onSelect;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const DocumentRow({
    required this.document,
    required this.isSelected,
    required this.onSelect,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = document.daysUntilAutoDelete ?? 0;
    
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
                    _getFileIcon(document.type),
                    color: _getFileColor(document.type),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      document.fileName,
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
                  color: _getFileColor(document.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  document.type.extension.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getFileColor(document.type),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                DateFormat('MMM dd, yyyy').format(document.deletedAt!),
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

  IconData _getFileIcon(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return Icons.picture_as_pdf;
      case DocumentType.docx:
      case DocumentType.doc:
        return Icons.description;
      case DocumentType.xlsx:
      case DocumentType.xls:
        return Icons.table_chart;
      case DocumentType.pptx:
      case DocumentType.ppt:
        return Icons.slideshow;
      case DocumentType.jpg:
      case DocumentType.jpeg:
      case DocumentType.png:
      case DocumentType.gif:
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return const Color(0xFFE53935);
      case DocumentType.docx:
      case DocumentType.doc:
        return const Color(0xFF1976D2);
      case DocumentType.xlsx:
      case DocumentType.xls:
        return const Color(0xFF2E7D32);
      case DocumentType.pptx:
      case DocumentType.ppt:
        return const Color(0xFFD84315);
      case DocumentType.jpg:
      case DocumentType.jpeg:
      case DocumentType.png:
      case DocumentType.gif:
        return const Color(0xFF7B1FA2);
      default:
        return AppTheme.textSecondary;
    }
  }
}