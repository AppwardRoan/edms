import 'package:edms/theme/app_theme.dart';
import 'package:flutter/material.dart';


class RecentFileCard extends StatelessWidget {
  final String fileName;
  final String fileType;
  final String date;

  const RecentFileCard({
    required this.fileName,
    required this.fileType,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File Icon
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _getFileColor(fileType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      _getFileIcon(fileType),
                      size: 48,
                      color: _getFileColor(fileType),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // File Name
              Text(
                fileName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // File Type & Date
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getFileColor(fileType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      fileType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getFileColor(fileType),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'docx':
      case 'doc':
        return Icons.description;
      case 'xlsx':
      case 'xls':
        return Icons.table_chart;
      case 'pptx':
      case 'ppt':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFE53935);
      case 'docx':
      case 'doc':
        return const Color(0xFF1976D2);
      case 'xlsx':
      case 'xls':
        return const Color(0xFF2E7D32);
      case 'pptx':
      case 'ppt':
        return const Color(0xFFD84315);
      case 'jpg':
      case 'jpeg':
      case 'png':
        return const Color(0xFF7B1FA2);
      default:
        return AppTheme.textSecondary;
    }
  }
}