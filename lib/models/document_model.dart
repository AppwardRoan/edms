import 'dart:typed_data';

enum DocumentStatus {
  active,
  deleted, // In bin
}

enum DocumentType {
  pdf,
  docx,
  doc,
  xlsx,
  xls,
  pptx,
  ppt,
  txt,
  jpg,
  jpeg,
  png,
  gif,
  zip,
  other,
}

extension DocumentTypeExtension on DocumentType {
  String get extension {
    switch (this) {
      case DocumentType.pdf:
        return 'pdf';
      case DocumentType.docx:
        return 'docx';
      case DocumentType.doc:
        return 'doc';
      case DocumentType.xlsx:
        return 'xlsx';
      case DocumentType.xls:
        return 'xls';
      case DocumentType.pptx:
        return 'pptx';
      case DocumentType.ppt:
        return 'ppt';
      case DocumentType.txt:
        return 'txt';
      case DocumentType.jpg:
        return 'jpg';
      case DocumentType.jpeg:
        return 'jpeg';
      case DocumentType.png:
        return 'png';
      case DocumentType.gif:
        return 'gif';
      case DocumentType.zip:
        return 'zip';
      case DocumentType.other:
        return 'file';
    }
  }

  static DocumentType fromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return DocumentType.pdf;
      case 'docx':
        return DocumentType.docx;
      case 'doc':
        return DocumentType.doc;
      case 'xlsx':
        return DocumentType.xlsx;
      case 'xls':
        return DocumentType.xls;
      case 'pptx':
        return DocumentType.pptx;
      case 'ppt':
        return DocumentType.ppt;
      case 'txt':
        return DocumentType.txt;
      case 'jpg':
        return DocumentType.jpg;
      case 'jpeg':
        return DocumentType.jpeg;
      case 'png':
        return DocumentType.png;
      case 'gif':
        return DocumentType.gif;
      case 'zip':
        return DocumentType.zip;
      default:
        return DocumentType.other;
    }
  }
}

class DocumentModel {
  final String id;
  final String name;
  final String fileName; // Full name with extension
  final DocumentType type;
  final String size; // e.g., "2.5 MB"
  final int sizeInBytes;
  final String? folderId; // null if in root
  final String uploadedBy; // User ID
  final DateTime uploadedAt;
  final DateTime? modifiedAt;
  final DocumentStatus status;
  final DateTime? deletedAt; // When moved to bin
  final String? description;
  final List<String> tags;
  final Uint8List? fileBytes; // Actual file data for web

  DocumentModel({
    required this.id,
    required this.name,
    required this.fileName,
    required this.type,
    required this.size,
    required this.sizeInBytes,
    this.folderId,
    required this.uploadedBy,
    required this.uploadedAt,
    this.modifiedAt,
    this.status = DocumentStatus.active,
    this.deletedAt,
    this.description,
    this.tags = const [],
    this.fileBytes, // Store actual file bytes
  });

  // Check if document is in bin
  bool get isDeleted => status == DocumentStatus.deleted;

  // Check if document is active
  bool get isActive => status == DocumentStatus.active;

  // Check if document is in root (no folder)
  bool get isInRoot => folderId == null;

  // Days remaining before auto-delete (30 days in bin)
  int? get daysUntilAutoDelete {
    if (deletedAt == null) return null;
    final daysSinceDeleted = DateTime.now().difference(deletedAt!).inDays;
    final remaining = 30 - daysSinceDeleted;
    return remaining > 0 ? remaining : 0;
  }

  DocumentModel copyWith({
    String? id,
    String? name,
    String? fileName,
    DocumentType? type,
    String? size,
    int? sizeInBytes,
    String? folderId,
    String? uploadedBy,
    DateTime? uploadedAt,
    DateTime? modifiedAt,
    DocumentStatus? status,
    DateTime? deletedAt,
    String? description,
    List<String>? tags,
    Uint8List? fileBytes,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      fileName: fileName ?? this.fileName,
      type: type ?? this.type,
      size: size ?? this.size,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      folderId: folderId ?? this.folderId,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      status: status ?? this.status,
      deletedAt: deletedAt ?? this.deletedAt,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      fileBytes: fileBytes ?? this.fileBytes,
    );
  }
}