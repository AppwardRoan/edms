import '../models/user_model.dart';
import '../models/document_model.dart';
import '../models/folder_model.dart';

class AppConstants {
  // App Info
  static const String appName = 'EDMS Pro';
  static const String appVersion = '1.0.0';
  
  // Mock Users for Testing
  static final List<UserModel> mockUsers = [
    UserModel(
      id: '1',
      firstName: 'John',
      lastName: 'Anderson',
      middleName: 'Michael',
      suffix: Suffix.sr,
      email: 'admin@test.com',
      username: 'admin',
      contactMobile: '+1234567890',
      password: 'admin123',
      role: UserRole.admin,
    ),
    UserModel(
      id: '2',
      firstName: 'Sarah',
      lastName: 'Johnson',
      middleName: 'Marie',
      suffix: Suffix.none,
      email: 'manager@test.com',
      username: 'manager',
      contactMobile: '+1234567891',
      password: 'manager123',
      role: UserRole.manager,
    ),
    UserModel(
      id: '3',
      firstName: 'Mike',
      lastName: 'Davis',
      middleName: null,
      suffix: Suffix.jr,
      email: 'user@test.com',
      username: 'user',
      contactMobile: '+1234567892',
      password: 'user123',
      role: UserRole.user,
    ),
    UserModel(
      id: '4',
      firstName: 'Emily',
      lastName: 'Wilson',
      middleName: 'Rose',
      suffix: Suffix.none,
      email: 'emily.wilson@test.com',
      username: 'ewilson',
      contactMobile: '+1234567893',
      password: 'user123',
      role: UserRole.user,
    ),
    UserModel(
      id: '5',
      firstName: 'Robert',
      lastName: 'Brown',
      middleName: 'James',
      suffix: Suffix.iii,
      email: 'robert.brown@test.com',
      username: 'rbrown',
      contactMobile: '+1234567894',
      password: 'user123',
      role: UserRole.manager,
    ),
  ];
  
  // Sidebar Items
  static const List<SidebarItem> sidebarItems = [
    SidebarItem(
      icon: '📊',
      label: 'Dashboard',
      route: '/home',
      requiredRole: null,
    ),
    SidebarItem(
      icon: '📄',
      label: 'Documents',
      route: '/documents',
      requiredRole: null,
    ),
    SidebarItem(
      icon: '📁',
      label: 'Folders',
      route: '/folders',
      requiredRole: null,
    ),
    SidebarItem(
      icon: '🗑️',
      label: 'Bin',
      route: '/bin',
      requiredRole: null,
    ),
    SidebarItem(
      icon: '👥',
      label: 'Users',
      route: '/users',
      requiredRole: UserRole.admin,
    ),
    SidebarItem(
      icon: '⚙️',
      label: 'Settings',
      route: '/settings',
      requiredRole: null,
    ),
  ];
  
  // Suffix options for dropdown
  static const List<Suffix> suffixOptions = [
    Suffix.none,
    Suffix.jr,
    Suffix.sr,
    Suffix.ii,
    Suffix.iii,
    Suffix.iv,
  ];
  
  // Mock Recent Files (for dashboard)
  static final List<MockFile> mockRecentFiles = [
    MockFile(
      id: '1',
      name: 'Sample PDF 010120',
      type: 'pdf',
      date: DateTime.now(),
      size: '2.5 MB',
    ),
    MockFile(
      id: '2',
      name: 'Sample WORD 0101',
      type: 'docx',
      date: DateTime.now(),
      size: '1.2 MB',
    ),
    MockFile(
      id: '3',
      name: 'Sample EXCEL 0101',
      type: 'xlsx',
      date: DateTime.now(),
      size: '890 KB',
    ),
    MockFile(
      id: '4',
      name: 'Q4 Report 2024',
      type: 'pdf',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      size: '3.1 MB',
    ),
    MockFile(
      id: '5',
      name: 'Meeting Notes',
      type: 'docx',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      size: '450 KB',
    ),
  ];
  
  // Mock Folders (for dashboard)
  static final List<MockFolder> mockFolders = [
    MockFolder(
      id: '1',
      name: 'Corporate Docs',
      date: DateTime(2024, 1, 1, 12, 0),
      fileCount: 3,
    ),
    MockFolder(
      id: '2',
      name: 'BIR',
      date: DateTime(2024, 1, 1, 12, 0),
      fileCount: 4,
    ),
    MockFolder(
      id: '3',
      name: 'Purchase Orders',
      date: DateTime(2024, 1, 1, 12, 0),
      fileCount: 5,
    ),
    MockFolder(
      id: '4',
      name: 'HR',
      date: DateTime(2024, 1, 1, 12, 0),
      fileCount: 96,
    ),
    MockFolder(
      id: '5',
      name: 'LCR',
      date: DateTime(2024, 1, 1, 12, 0),
      fileCount: 8,
    ),
    MockFolder(
      id: '6',
      name: 'Projects',
      date: DateTime(2024, 1, 1, 12, 0),
      fileCount: 9,
    ),
  ];
  
  // Mock Documents (Active)
  static final List<DocumentModel> mockDocuments = [
    DocumentModel(
      id: '1',
      name: 'Q4 Financial Report',
      fileName: 'Q4_Financial_Report.pdf',
      type: DocumentType.pdf,
      size: '2.5 MB',
      sizeInBytes: 2621440,
      uploadedBy: '1', // admin
      uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
      tags: ['finance', 'report', 'Q4'],
      description: '2024 Q4 Financial Report',
    ),
    DocumentModel(
      id: '2',
      name: 'Employee Handbook',
      fileName: 'Employee_Handbook.docx',
      type: DocumentType.docx,
      size: '1.2 MB',
      sizeInBytes: 1258291,
      uploadedBy: '2', // manager
      uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
      tags: ['HR', 'handbook'],
    ),
    DocumentModel(
      id: '3',
      name: 'Sales Data 2024',
      fileName: 'Sales_Data_2024.xlsx',
      type: DocumentType.xlsx,
      size: '890 KB',
      sizeInBytes: 911769,
      uploadedBy: '1',
      uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
      tags: ['sales', 'data'],
    ),
    DocumentModel(
      id: '4',
      name: 'Project Proposal',
      fileName: 'Project_Proposal.pptx',
      type: DocumentType.pptx,
      size: '5.3 MB',
      sizeInBytes: 5557452,
      uploadedBy: '3', // user
      uploadedAt: DateTime.now().subtract(const Duration(hours: 3)),
      tags: ['project', 'proposal'],
    ),
    DocumentModel(
      id: '5',
      name: 'Company Logo',
      fileName: 'Company_Logo.png',
      type: DocumentType.png,
      size: '245 KB',
      sizeInBytes: 250880,
      uploadedBy: '1',
      uploadedAt: DateTime.now().subtract(const Duration(days: 10)),
      tags: ['logo', 'branding'],
    ),
    DocumentModel(
      id: '6',
      name: 'Meeting Minutes',
      fileName: 'Meeting_Minutes_Jan_2025.docx',
      type: DocumentType.docx,
      size: '450 KB',
      sizeInBytes: 460800,
      uploadedBy: '2',
      uploadedAt: DateTime.now().subtract(const Duration(hours: 12)),
      tags: ['meeting', 'minutes'],
    ),
    DocumentModel(
      id: '7',
      name: 'Budget Plan',
      fileName: 'Budget_Plan_2025.xlsx',
      type: DocumentType.xlsx,
      size: '1.1 MB',
      sizeInBytes: 1153433,
      uploadedBy: '1',
      uploadedAt: DateTime.now().subtract(const Duration(days: 7)),
      tags: ['budget', 'finance'],
    ),
    DocumentModel(
      id: '8',
      name: 'Contract Agreement',
      fileName: 'Contract_Agreement.pdf',
      type: DocumentType.pdf,
      size: '3.2 MB',
      sizeInBytes: 3355443,
      uploadedBy: '2',
      uploadedAt: DateTime.now().subtract(const Duration(days: 15)),
      tags: ['contract', 'legal'],
    ),
  ];
  
  // Mock Documents in Bin (Deleted)
  static final List<DocumentModel> mockBinDocuments = [
    DocumentModel(
      id: '9',
      name: 'Old Report',
      fileName: 'Old_Report_2023.pdf',
      type: DocumentType.pdf,
      size: '1.8 MB',
      sizeInBytes: 1887436,
      uploadedBy: '1',
      uploadedAt: DateTime.now().subtract(const Duration(days: 30)),
      status: DocumentStatus.deleted,
      deletedAt: DateTime.now().subtract(const Duration(days: 5)),
      tags: ['old', 'report'],
    ),
    DocumentModel(
      id: '10',
      name: 'Draft Document',
      fileName: 'Draft_Document.docx',
      type: DocumentType.docx,
      size: '680 KB',
      sizeInBytes: 696320,
      uploadedBy: '3',
      uploadedAt: DateTime.now().subtract(const Duration(days: 20)),
      status: DocumentStatus.deleted,
      deletedAt: DateTime.now().subtract(const Duration(days: 2)),
      tags: ['draft'],
    ),
    DocumentModel(
      id: '11',
      name: 'Unused Spreadsheet',
      fileName: 'Unused_Spreadsheet.xlsx',
      type: DocumentType.xlsx,
      size: '520 KB',
      sizeInBytes: 532480,
      uploadedBy: '2',
      uploadedAt: DateTime.now().subtract(const Duration(days: 45)),
      status: DocumentStatus.deleted,
      deletedAt: DateTime.now().subtract(const Duration(days: 10)),
      tags: ['unused'],
    ),
  ];
  
  // Mock Folders (Active)
  static final List<FolderModel> mockFoldersData = [
    FolderModel(
      id: '1',
      name: 'Corporate Docs',
      createdBy: '1',
      createdAt: DateTime(2024, 1, 1, 12, 0),
      documentCount: 3,
    ),
    FolderModel(
      id: '2',
      name: 'BIR',
      createdBy: '1',
      createdAt: DateTime(2024, 1, 1, 12, 0),
      documentCount: 4,
    ),
    FolderModel(
      id: '3',
      name: 'Purchase Orders',
      createdBy: '2',
      createdAt: DateTime(2024, 1, 1, 12, 0),
      documentCount: 5,
    ),
    FolderModel(
      id: '4',
      name: 'HR',
      createdBy: '2',
      createdAt: DateTime(2024, 1, 1, 12, 0),
      documentCount: 96,
    ),
    FolderModel(
      id: '5',
      name: 'LCR',
      createdBy: '1',
      createdAt: DateTime(2024, 1, 1, 12, 0),
      documentCount: 8,
    ),
    FolderModel(
      id: '6',
      name: 'Projects',
      createdBy: '3',
      createdAt: DateTime(2024, 1, 1, 12, 0),
      documentCount: 9,
    ),
  ];
  
  // Mock Folders in Bin (Deleted)
  static final List<FolderModel> mockBinFolders = [
    FolderModel(
      id: '7',
      name: 'Archive 2023',
      createdBy: '1',
      createdAt: DateTime(2023, 12, 1, 10, 0),
      status: FolderStatus.deleted,
      deletedAt: DateTime.now().subtract(const Duration(days: 3)),
      documentCount: 12,
    ),
  ];
}

// Mock File Model (temporary until we create proper document model)
class MockFile {
  final String id;
  final String name;
  final String type;
  final DateTime date;
  final String size;

  const MockFile({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.size,
  });
}

// Mock Folder Model (temporary until we create proper folder model)
class MockFolder {
  final String id;
  final String name;
  final DateTime date;
  final int fileCount;

  const MockFolder({
    required this.id,
    required this.name,
    required this.date,
    required this.fileCount,
  });
}

class SidebarItem {
  final String icon;
  final String label;
  final String route;
  final UserRole? requiredRole;

  const SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    this.requiredRole,
  });
}