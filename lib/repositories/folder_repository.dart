import '../models/folder_model.dart';
import '../constants/app_constants.dart';

class FolderRepository {
  // In-memory storage (simulating database)
  final List<FolderModel> _folders = List.from(AppConstants.mockFoldersData);
  final List<FolderModel> _binFolders = List.from(AppConstants.mockBinFolders);

  // Simulate network delay
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Get all active folders (optionally filter by parent)
  Future<List<FolderModel>> getFolders({String? parentFolderId}) async {
    await _delay();
    
    if (parentFolderId != null) {
      // Get subfolders of a specific parent
      return _folders
          .where((folder) => folder.isActive && folder.parentFolderId == parentFolderId)
          .toList();
    } else {
      // Get root level folders only
      return _folders
          .where((folder) => folder.isActive && folder.isRoot)
          .toList();
    }
  }

  // Get all folders (for nested structure)
  Future<List<FolderModel>> getAllFolders() async {
    await _delay();
    return _folders.where((folder) => folder.isActive).toList();
  }

  // Get folders in bin
  Future<List<FolderModel>> getBinFolders() async {
    await _delay();
    return _binFolders.where((folder) => folder.isDeleted).toList();
  }

  // Get folder by ID
  Future<FolderModel?> getFolderById(String id) async {
    await _delay();
    
    try {
      return _folders.firstWhere((folder) => folder.id == id);
    } catch (e) {
      try {
        return _binFolders.firstWhere((folder) => folder.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  // Get folder path (breadcrumb)
  Future<List<FolderModel>> getFolderPath(String folderId) async {
    await _delay();
    
    final path = <FolderModel>[];
    String? currentId = folderId;
    
    while (currentId != null) {
      try {
        final folder = _folders.firstWhere((f) => f.id == currentId);
        path.insert(0, folder); // Add to beginning
        currentId = folder.parentFolderId;
      } catch (e) {
        break;
      }
    }
    
    return path;
  }

  // Create new folder
  Future<FolderModel> createFolder({
    required String name,
    String? parentFolderId,
    required String createdBy,
    String? description,
  }) async {
    await _delay();
    
    // Update parent's subfolder count if has parent
    if (parentFolderId != null) {
      final parentIndex = _folders.indexWhere((f) => f.id == parentFolderId);
      if (parentIndex != -1) {
        final parent = _folders[parentIndex];
        _folders[parentIndex] = parent.copyWith(
          subfolderCount: parent.subfolderCount + 1,
        );
      }
    }
    
    final newFolder = FolderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      parentFolderId: parentFolderId,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      description: description,
    );
    
    _folders.add(newFolder);
    return newFolder;
  }

  // Rename folder
  Future<FolderModel?> renameFolder(String folderId, String newName) async {
    await _delay();
    
    try {
      final folderIndex = _folders.indexWhere((f) => f.id == folderId);
      if (folderIndex == -1) return null;
      
      final updatedFolder = _folders[folderIndex].copyWith(
        name: newName,
        modifiedAt: DateTime.now(),
      );
      
      _folders[folderIndex] = updatedFolder;
      return updatedFolder;
    } catch (e) {
      return null;
    }
  }

  // Move folder to bin (soft delete)
  Future<bool> moveTobin(String folderId) async {
    await _delay();
    
    try {
      final folderIndex = _folders.indexWhere((f) => f.id == folderId);
      if (folderIndex == -1) return false;
      
      final folder = _folders[folderIndex];
      
      // Check if folder is empty
      if (!folder.isEmpty) {
        return false; // Cannot delete non-empty folder
      }
      
      // Update parent's subfolder count if has parent
      if (folder.parentFolderId != null) {
        final parentIndex = _folders.indexWhere((f) => f.id == folder.parentFolderId);
        if (parentIndex != -1) {
          final parent = _folders[parentIndex];
          _folders[parentIndex] = parent.copyWith(
            subfolderCount: parent.subfolderCount - 1,
          );
        }
      }
      
      final deletedFolder = folder.copyWith(
        status: FolderStatus.deleted,
        deletedAt: DateTime.now(),
      );
      
      _folders.removeAt(folderIndex);
      _binFolders.add(deletedFolder);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Restore folder from bin
  Future<bool> restoreFolder(String folderId) async {
    await _delay();
    
    try {
      final folderIndex = _binFolders.indexWhere((f) => f.id == folderId);
      if (folderIndex == -1) return false;
      
      final folder = _binFolders[folderIndex];
      
      // Update parent's subfolder count if has parent
      if (folder.parentFolderId != null) {
        final parentIndex = _folders.indexWhere((f) => f.id == folder.parentFolderId);
        if (parentIndex != -1) {
          final parent = _folders[parentIndex];
          _folders[parentIndex] = parent.copyWith(
            subfolderCount: parent.subfolderCount + 1,
          );
        }
      }
      
      final restoredFolder = folder.copyWith(
        status: FolderStatus.active,
        deletedAt: null,
      );
      
      _binFolders.removeAt(folderIndex);
      _folders.add(restoredFolder);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Permanently delete folder
  Future<bool> permanentlyDelete(String folderId) async {
    await _delay();
    
    try {
      _binFolders.removeWhere((f) => f.id == folderId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update folder document count (when document added/removed)
  Future<void> updateDocumentCount(String folderId, int change) async {
    await _delay();
    
    try {
      final folderIndex = _folders.indexWhere((f) => f.id == folderId);
      if (folderIndex != -1) {
        final folder = _folders[folderIndex];
        _folders[folderIndex] = folder.copyWith(
          documentCount: folder.documentCount + change,
        );
      }
    } catch (e) {
      // Ignore
    }
  }

  // Get subfolders recursively (for displaying tree)
  Future<List<FolderModel>> getSubfoldersRecursive(String folderId) async {
    await _delay();
    
    final subfolders = <FolderModel>[];
    final directSubfolders = _folders
        .where((f) => f.isActive && f.parentFolderId == folderId)
        .toList();
    
    subfolders.addAll(directSubfolders);
    
    for (final subfolder in directSubfolders) {
      final nested = await getSubfoldersRecursive(subfolder.id);
      subfolders.addAll(nested);
    }
    
    return subfolders;
  }
}