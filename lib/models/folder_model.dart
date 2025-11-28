enum FolderStatus {
  active,
  deleted, // In bin
}

class FolderModel {
  final String id;
  final String name;
  final String? parentFolderId; // null if root folder, otherwise parent's ID
  final String createdBy; // User ID
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final FolderStatus status;
  final DateTime? deletedAt; // When moved to bin
  final String? description;
  final int documentCount; // Number of documents in folder
  final int subfolderCount; // Number of subfolders

  FolderModel({
    required this.id,
    required this.name,
    this.parentFolderId,
    required this.createdBy,
    required this.createdAt,
    this.modifiedAt,
    this.status = FolderStatus.active,
    this.deletedAt,
    this.description,
    this.documentCount = 0,
    this.subfolderCount = 0,
  });

  // Check if folder is in bin
  bool get isDeleted => status == FolderStatus.deleted;

  // Check if folder is active
  bool get isActive => status == FolderStatus.active;

  // Check if folder is root level
  bool get isRoot => parentFolderId == null;

  // Days remaining before auto-delete (30 days in bin)
  int? get daysUntilAutoDelete {
    if (deletedAt == null) return null;
    final daysSinceDeleted = DateTime.now().difference(deletedAt!).inDays;
    final remaining = 30 - daysSinceDeleted;
    return remaining > 0 ? remaining : 0;
  }

  // Check if folder is empty
  bool get isEmpty => documentCount == 0 && subfolderCount == 0;

  FolderModel copyWith({
    String? id,
    String? name,
    String? parentFolderId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? modifiedAt,
    FolderStatus? status,
    DateTime? deletedAt,
    String? description,
    int? documentCount,
    int? subfolderCount,
  }) {
    return FolderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      status: status ?? this.status,
      deletedAt: deletedAt ?? this.deletedAt,
      description: description ?? this.description,
      documentCount: documentCount ?? this.documentCount,
      subfolderCount: subfolderCount ?? this.subfolderCount,
    );
  }
}