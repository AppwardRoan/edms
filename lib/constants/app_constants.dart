import '../models/user_model.dart';

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
      lastName: 'David',
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