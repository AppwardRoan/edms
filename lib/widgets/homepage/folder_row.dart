import 'package:edms/theme/app_theme.dart';
import 'package:flutter/material.dart';


class FolderRow extends StatelessWidget {
  final String folderName;
  final String date;
  final String fileCount;

  const FolderRow({
    required this.folderName,
    required this.date,
    required this.fileCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: false,
              onChanged: (value) {},
              activeColor: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 8),
            // Folder Icon & Name
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
                      folderName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Date
            Expanded(
              flex: 2,
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            // File Count
            Expanded(
              child: Text(
                fileCount,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            // More Options
            IconButton(
              icon: const Icon(Icons.more_vert, size: 20),
              onPressed: () {},
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}