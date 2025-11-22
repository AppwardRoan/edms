import '../models/user_model.dart';
import '../constants/app_constants.dart';

class AuthRepository {
  // Simulate network delay
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // Login with username/email and password
  Future<UserModel?> login(String usernameOrEmail, String password) async {
    await _delay();
    
    try {
      final user = AppConstants.mockUsers.firstWhere(
        (user) => (user.username == usernameOrEmail || user.email == usernameOrEmail) 
            && user.password == password,
      );
      return user;
    } catch (e) {
      return null;
    }
  }

  // Register new user
  Future<UserModel?> register({
    required String firstName,
    required String lastName,
    String? middleName,
    required Suffix suffix,
    required String email,
    required String username,
    required String contactMobile,
    required String password,
  }) async {
    await _delay();
    
    // Check if email or username already exists
    final emailExists = AppConstants.mockUsers.any((user) => user.email == email);
    final usernameExists = AppConstants.mockUsers.any((user) => user.username == username);
    
    if (emailExists || usernameExists) {
      return null;
    }
    
    // Create new user (in real app, this would save to database)
    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: firstName,
      lastName: lastName,
      middleName: middleName,
      suffix: suffix,
      email: email,
      username: username,
      contactMobile: contactMobile,
      password: password,
      role: UserRole.user, // Default role
    );
    
    return newUser;
  }

  // Logout
  Future<void> logout() async {
    await _delay();
    // Clear session, tokens, etc.
  }

  // Get current user (simulate checking stored session)
  Future<UserModel?> getCurrentUser() async {
    await _delay();
    // In real app, check stored token/session
    return null;
  }
}