enum UserRole {
  admin,
  manager,
  user,
}

enum Suffix {
  none,
  jr,
  sr,
  ii,
  iii,
  iv,
}

extension SuffixExtension on Suffix {
  String get label {
    switch (this) {
      case Suffix.none:
        return 'None';
      case Suffix.jr:
        return 'Jr.';
      case Suffix.sr:
        return 'Sr.';
      case Suffix.ii:
        return 'II';
      case Suffix.iii:
        return 'III';
      case Suffix.iv:
        return 'IV';
    }
  }
}

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;
  final Suffix suffix;
  final String email;
  final String username;
  final String contactMobile;
  final String password;
  final UserRole role;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.suffix = Suffix.none,
    required this.email,
    required this.username,
    required this.contactMobile,
    required this.password,
    required this.role,
  });

  String get fullName {
    final middle = middleName != null && middleName!.isNotEmpty 
        ? ' ${middleName!}' 
        : '';
    final suffixStr = suffix != Suffix.none ? ' ${suffix.label}' : '';
    return '$firstName$middle $lastName$suffixStr';
  }

  String get roleLabel {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.manager:
        return 'Manager';
      case UserRole.user:
        return 'User';
    }
  }

  bool hasRole(UserRole requiredRole) {
    return role == requiredRole;
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? middleName,
    Suffix? suffix,
    String? email,
    String? username,
    String? contactMobile,
    String? password,
    UserRole? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      suffix: suffix ?? this.suffix,
      email: email ?? this.email,
      username: username ?? this.username,
      contactMobile: contactMobile ?? this.contactMobile,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }
}