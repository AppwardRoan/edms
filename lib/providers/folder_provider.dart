import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/folder_model.dart';
import '../repositories/folder_repository.dart';

// Folder Repository Provider
final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  return FolderRepository();
});

// Current Folder ID Provider (tracks which folder we're viewing)
final currentFolderIdProvider = StateProvider<String?>((ref) => null);

// Folders List Provider (folders in current location)
final foldersProvider = StateNotifierProvider<FoldersNotifier, AsyncValue<List<FolderModel>>>((ref) {
  final repository = ref.watch(folderRepositoryProvider);
  final currentFolderId = ref.watch(currentFolderIdProvider);
  return FoldersNotifier(repository, currentFolderId);
});

// Folder Path Provider (breadcrumb)
final folderPathProvider = FutureProvider<List<FolderModel>>((ref) async {
  final currentFolderId = ref.watch(currentFolderIdProvider);
  if (currentFolderId == null) return [];
  
  final repository = ref.watch(folderRepositoryProvider);
  return repository.getFolderPath(currentFolderId);
});

// Bin Folders Provider
final binFoldersProvider = StateNotifierProvider<BinFoldersNotifier, AsyncValue<List<FolderModel>>>((ref) {
  final repository = ref.watch(folderRepositoryProvider);
  return BinFoldersNotifier(repository);
});

// Folders Notifier
class FoldersNotifier extends StateNotifier<AsyncValue<List<FolderModel>>> {
  final FolderRepository _repository;
  final String? _currentFolderId;

  FoldersNotifier(this._repository, this._currentFolderId) 
      : super(const AsyncValue.loading()) {
    loadFolders();
  }

  // Load folders (root or subfolder)
  Future<void> loadFolders() async {
    state = const AsyncValue.loading();
    
    try {
      final folders = await _repository.getFolders(parentFolderId: _currentFolderId);
      state = AsyncValue.data(folders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Create new folder
  Future<FolderModel?> createFolder({
    required String name,
    required String createdBy,
    String? description,
  }) async {
    try {
      final newFolder = await _repository.createFolder(
        name: name,
        parentFolderId: _currentFolderId,
        createdBy: createdBy,
        description: description,
      );
      
      // Add to current state
      final currentFolders = state.value ?? [];
      state = AsyncValue.data([...currentFolders, newFolder]);
      
      return newFolder;
    } catch (e) {
      return null;
    }
  }

  // Rename folder
  Future<bool> renameFolder(String folderId, String newName) async {
    try {
      final updatedFolder = await _repository.renameFolder(folderId, newName);
      
      if (updatedFolder != null) {
        // Update in current state
        final currentFolders = state.value ?? [];
        state = AsyncValue.data(
          currentFolders.map((f) => f.id == folderId ? updatedFolder : f).toList(),
        );
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // Move folder to bin
  Future<bool> moveTobin(String folderId) async {
    try {
      final success = await _repository.moveTobin(folderId);
      
      if (success) {
        // Remove from current state
        final currentFolders = state.value ?? [];
        state = AsyncValue.data(
          currentFolders.where((f) => f.id != folderId).toList(),
        );
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }

  // Navigate into folder
  void navigateToFolder(String? folderId) {
    // This is handled by currentFolderIdProvider
    // Reload will happen automatically
    loadFolders();
  }
}

// Bin Folders Notifier
class BinFoldersNotifier extends StateNotifier<AsyncValue<List<FolderModel>>> {
  final FolderRepository _repository;

  BinFoldersNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadBinFolders();
  }

  // Load folders in bin
  Future<void> loadBinFolders() async {
    state = const AsyncValue.loading();
    
    try {
      final folders = await _repository.getBinFolders();
      state = AsyncValue.data(folders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Restore folder from bin
  Future<bool> restoreFolder(String folderId) async {
    try {
      final success = await _repository.restoreFolder(folderId);
      
      if (success) {
        // Remove from bin state
        final currentFolders = state.value ?? [];
        state = AsyncValue.data(
          currentFolders.where((f) => f.id != folderId).toList(),
        );
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }

  // Permanently delete folder
  Future<bool> permanentlyDelete(String folderId) async {
    try {
      final success = await _repository.permanentlyDelete(folderId);
      
      if (success) {
        // Remove from bin state
        final currentFolders = state.value ?? [];
        state = AsyncValue.data(
          currentFolders.where((f) => f.id != folderId).toList(),
        );
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }
}