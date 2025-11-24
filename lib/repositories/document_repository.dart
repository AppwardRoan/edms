import '../models/document_model.dart';
import '../constants/app_constants.dart';

class DocumentRepository {
  // In-memory storage (simulating database)
  final List<DocumentModel> _documents = List.from(AppConstants.mockDocuments); // Active documents
  final List<DocumentModel> _binDocuments = List.from(AppConstants.mockBinDocuments); // Deleted documents

  // Simulate network delay
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Get all active documents
  Future<List<DocumentModel>> getDocuments({String? folderId}) async { // Optionally filter by folderId
    await _delay();
    
    if (folderId != null) {
      return _documents
          .where((doc) => doc.isActive && doc.folderId == folderId)
          .toList();
    }
    
    return _documents.where((doc) => doc.isActive).toList();
  }

  // Get documents in bin
  Future<List<DocumentModel>> getBinDocuments() async {
    await _delay();
    return _binDocuments.where((doc) => doc.isDeleted).toList(); // Only deleted documents
  }

  // Get document by ID
  Future<DocumentModel?> getDocumentById(String id) async {
    await _delay();
    
    try {
      return _documents.firstWhere((doc) => doc.id == id);
    } catch (e) {
      try {
        return _binDocuments.firstWhere((doc) => doc.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  // Upload locally document (mock) 
  Future<DocumentModel> uploadDocument({
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
    await _delay();
    
    final newDoc = DocumentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      fileName: fileName,
      type: type,
      size: size,
      sizeInBytes: sizeInBytes,
      folderId: folderId,
      uploadedBy: uploadedBy,
      uploadedAt: DateTime.now(),
      description: description,
      tags: tags,
    );
    
    _documents.add(newDoc);
    return newDoc;
  }

  // Move document to bin (soft delete)
  Future<bool> moveTobin(String documentId) async {
    await _delay();
    
    try {
      final docIndex = _documents.indexWhere((doc) => doc.id == documentId);
      if (docIndex == -1) return false; // Document not found
      
      final doc = _documents[docIndex]; // Get the document
      final deletedDoc = doc.copyWith( // Mark as deleted
        status: DocumentStatus.deleted,
        deletedAt: DateTime.now(),
      );
      
      _documents.removeAt(docIndex); // Remove from active documents
      _binDocuments.add(deletedDoc); // Add to bin documents
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Restore document from bin
  Future<bool> restoreDocument(String documentId) async {
    await _delay();
    
    try {
      final docIndex = _binDocuments.indexWhere((doc) => doc.id == documentId); // Find in bin
      if (docIndex == -1) return false; // Document not found
      
      final doc = _binDocuments[docIndex]; // Get the document
      final restoredDoc = doc.copyWith( // Mark as active
        status: DocumentStatus.active,
        deletedAt: null,
      );
      
      _binDocuments.removeAt(docIndex); // Remove from bin
      _documents.add(restoredDoc); // Add back to active documents
      
      return true; // Successfully restored
    } catch (e) {
      return false;
    }
  }

  // Permanently delete document
  Future<bool> permanentlyDelete(String documentId) async { // from bin
    await _delay();
    
    try {
      _binDocuments.removeWhere((doc) => doc.id == documentId); // Remove from bin
      return true;
    } catch (e) {
      return false;
    }
  }

  // Empty bin (delete all documents in bin)
  Future<bool> emptyBin() async { // permanently delete all
    await _delay();
    
    try {
      _binDocuments.clear(); // Clear all bin documents
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update document
  Future<DocumentModel?> updateDocument(DocumentModel document) async {
    await _delay();
    
    try {
      final docIndex = _documents.indexWhere((doc) => doc.id == document.id);
      if (docIndex == -1) return null;
      
      final updatedDoc = document.copyWith(modifiedAt: DateTime.now());
      _documents[docIndex] = updatedDoc;
      
      return updatedDoc;
    } catch (e) {
      return null;
    }
  }

  // Search documents
  Future<List<DocumentModel>> searchDocuments(String query) async {
    await _delay();
    
    final lowerQuery = query.toLowerCase();
    return _documents.where((doc) {
      return doc.isActive &&
          (doc.name.toLowerCase().contains(lowerQuery) ||
              doc.fileName.toLowerCase().contains(lowerQuery) ||
              doc.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)));
    }).toList();
  }
}