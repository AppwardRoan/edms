import '../models/user_model.dart';
import '../constants/app_constants.dart';

class AuthRepository {
  // Simulate network delay
  Future<void> _delay() async { // fake network delay so login/register feels realistic.
    await Future.delayed(const Duration(milliseconds: 800));
  }

  Future<UserModel?> login(String usernameOrEmail, String password) async { // Login with username/email and password
    await _delay();
    
    try {
      // First, check if user exists by username or email
      final userExists = AppConstants.mockUsers.firstWhere(
        (user) => user.username == usernameOrEmail || user.email == usernameOrEmail,
        orElse: () => throw Exception('User not found'),
      );
      
      // If user exists, check password
      if (userExists.password != password) {
        print('❌ Password incorrect for user: $usernameOrEmail');
        return null;
      }
      
      // If both username/email and password match, return the user
      print('✅ Login successful for user: $usernameOrEmail');
      return userExists;
      
    } catch (e) {
      // Account not found
      print('❌ Account not found: $usernameOrEmail');
      return null;
    }
  }

  Future<UserModel?> register({ // Register new user
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
    
    final newUser = UserModel( // Create new user (in real app, this would save to database)
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

  Future<void> logout() async { // Logout
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