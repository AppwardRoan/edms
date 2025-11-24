import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/document_model.dart';
import '../repositories/document_repository.dart';

// Document Repository Provider
final documentRepositoryProvider = Provider<DocumentRepository>((ref) { // Repository instance
  return DocumentRepository();
});

// Documents List Provider (Active Documents)
final documentsProvider = StateNotifierProvider<DocumentsNotifier, AsyncValue<List<DocumentModel>>>((ref) { // Active documents state
  final repository = ref.watch(documentRepositoryProvider);
  return DocumentsNotifier(repository);
});

// Bin Documents Provider (Deleted Documents)
final binDocumentsProvider = StateNotifierProvider<BinDocumentsNotifier, AsyncValue<List<DocumentModel>>>((ref) { // Bin documents state
  final repository = ref.watch(documentRepositoryProvider); 
  return BinDocumentsNotifier(repository);
});

// Documents Notifier
class DocumentsNotifier extends StateNotifier<AsyncValue<List<DocumentModel>>> { // Manages active documents
  final DocumentRepository _repository;

  DocumentsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadDocuments();
  }

  // Load all active documents
  Future<void> loadDocuments({String? folderId}) async {
    state = const AsyncValue.loading();
    
    try {
      final documents = await _repository.getDocuments(folderId: folderId); // Optionally filter by folderId
      state = AsyncValue.data(documents); // Set state to loaded documents
    } catch (e, stack) {
      state = AsyncValue.error(e, stack); // Set state to error
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
      );
      
      // Add to current state
      final currentDocs = state.value ?? []; // Get current documents
      state = AsyncValue.data([...currentDocs, newDoc]); // Add new document
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Move document to bin
  Future<bool> moveTobin(String documentId) async {
    try {
      final success = await _repository.moveTobin(documentId); // Move to bin
      
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
class BinDocumentsNotifier extends StateNotifier<AsyncValue<List<DocumentModel>>> { // Manages bin documents
  final DocumentRepository _repository;

  BinDocumentsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadBinDocuments();
  }

  // Load documents in bin
  Future<void> loadBinDocuments() async {
    state = const AsyncValue.loading();
    
    try {
      final documents = await _repository.getBinDocuments(); // Get bin documents
      state = AsyncValue.data(documents);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Restore document from bin
  Future<bool> restoreDocument(String documentId) async {
    try {
      final success = await _repository.restoreDocument(documentId); // Restore from bin status from deleted to active
      
      if (success) {
        // Remove from bin state
        final currentDocs = state.value ?? []; // Current bin documents
        state = AsyncValue.data(
          currentDocs.where((doc) => doc.id != documentId).toList() // Remove restored document. Update UI
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
      final success = await _repository.permanentlyDelete(documentId); // Permanently delete from bin
      
      if (success) {
        // Remove from bin state
        final currentDocs = state.value ?? []; // Current bin documents
        state = AsyncValue.data(
          currentDocs.where((doc) => doc.id != documentId).toList(), // Remove restored document. Update UI
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