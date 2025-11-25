import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/document_model.dart';
import '../repositories/document_repository.dart';

// Document Repository Provider
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository();
});

// Documents List Provider (Active Documents)
final documentsProvider = StateNotifierProvider<DocumentsNotifier, AsyncValue<List<DocumentModel>>>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return DocumentsNotifier(repository);
});

// Bin Documents Provider (Deleted Documents)
final binDocumentsProvider = StateNotifierProvider<BinDocumentsNotifier, AsyncValue<List<DocumentModel>>>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return BinDocumentsNotifier(repository);
});

// Documents Notifier
class DocumentsNotifier extends StateNotifier<AsyncValue<List<DocumentModel>>> {
  final DocumentRepository _repository;

  DocumentsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadDocuments();
  }

  // Load all active documents
  Future<void> loadDocuments({String? folderId}) async {
    state = const AsyncValue.loading();
    
    try {
      final documents = await _repository.getDocuments(folderId: folderId);
      state = AsyncValue.data(documents);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Upload new document
  Future<bool> uploadDocument({
    required String name,
    required String fileName,
    required DocumentType type,
    required String size,
    required int sizeInBytes,
    String? folderId,
    required String uploadedBy,
    String? description,
    List<String> tags = const [],
    Uint8List? fileBytes, // Accept file bytes
  }) async {
    try {
      final newDoc = await _repository.uploadDocument(
        name: name,
        fileName: fileName,
        type: type,
        size: size,
        sizeInBytes: sizeInBytes,
        folderId: folderId,
        uploadedBy: uploadedBy,
        description: description,
        tags: tags,
        fileBytes: fileBytes, // Pass file bytes
      );
      
      // Add to current state
      final currentDocs = state.value ?? [];
      state = AsyncValue.data([...currentDocs, newDoc]);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Move document to bin
  Future<bool> moveTobin(String documentId) async {
    try {
      final success = await _repository.moveTobin(documentId);
      
      if (success) {
        // Remove from current state
        final currentDocs = state.value ?? [];
        state = AsyncValue.data(
          currentDocs.where((doc) => doc.id != documentId).toList(),
        );
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }

  // Search documents
  Future<void> searchDocuments(String query) async {
    if (query.isEmpty) {
      loadDocuments();
      return;
    }
    
    state = const AsyncValue.loading();
    
    try {
      final documents = await _repository.searchDocuments(query);
      state = AsyncValue.data(documents);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Bin Documents Notifier
class BinDocumentsNotifier extends StateNotifier<AsyncValue<List<DocumentModel>>> {
  final DocumentRepository _repository;

  BinDocumentsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadBinDocuments();
  }

  // Load documents in bin
  Future<void> loadBinDocuments() async {
    state = const AsyncValue.loading();
    
    try {
      final documents = await _repository.getBinDocuments();
      state = AsyncValue.data(documents);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Restore document from bin
  Future<bool> restoreDocument(String documentId) async {
    try {
      final success = await _repository.restoreDocument(documentId);
      
      if (success) {
        // Remove from bin state
        final currentDocs = state.value ?? [];
        state = AsyncValue.data(
          currentDocs.where((doc) => doc.id != documentId).toList(),
        );
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }

  // Permanently delete document
  Future<bool> permanentlyDelete(String documentId) async {
    try {
      final success = await _repository.permanentlyDelete(documentId);
      
      if (success) {
        // Remove from bin state
        final currentDocs = state.value ?? [];
        state = AsyncValue.data(
          currentDocs.where((doc) => doc.id != documentId).toList(),
        );
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }

  // Empty entire bin
  Future<bool> emptyBin() async {
    try {
      final success = await _repository.emptyBin();
      
      if (success) {
        state = const AsyncValue.data([]);
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }
}