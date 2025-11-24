import 'package:flutter/material.dart';
import '../models/document_model.dart';

class FileUtils {
  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Get document type from file extension
  static DocumentType getDocumentTypeFromExtension(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return DocumentTypeExtension.fromExtension(extension);
  }

  // Get file icon based on document type
  static IconData getFileIcon(DocumentType type) {
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
      case DocumentType.txt:
        return Icons.text_snippet;
      case DocumentType.jpg:
      case DocumentType.jpeg:
      case DocumentType.png:
      case DocumentType.gif:
        return Icons.image;
      case DocumentType.zip:
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Get file color based on document type
  static Color getFileColor(DocumentType type) {
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
      case DocumentType.txt:
        return const Color(0xFF616161);
      case DocumentType.jpg:
      case DocumentType.jpeg:
      case DocumentType.png:
      case DocumentType.gif:
        return const Color(0xFF7B1FA2);
      case DocumentType.zip:
        return const Color(0xFFFFA000);
      default:
        return const Color(0xFF757575);
    }
  }

  // Validate file size (max 100MB for demo)
  static bool isFileSizeValid(int bytes, {int maxBytes = 100 * 1024 * 1024}) {
    return bytes <= maxBytes;
  }

  // Get allowed file extensions
  static List<String> get allowedExtensions => [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
        'txt',
        'jpg',
        'jpeg',
        'png',
        'gif',
        'zip',
      ];
}