import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) { // This is User's toolbox: has login, register, logout functions
  return AuthRepository(); // creates an instance (a real usable copy) of AuthRepository
});

// Auth State Notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> login(String usernameOrEmail, String password) async { // Login
    state = const AsyncValue.loading();
    
    try {
      final user = await _repository.login(usernameOrEmail, password); // attempt login - auth repository handles the logic
      
      if (user != null) {
        state = AsyncValue.data(user); // updates state with logged-in user
        return true; // signals success to LoginPage
      } else {
        state = AsyncValue.data(null); // clears state
        return false; // signals failure
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> register({ // Register
    required String firstName,
    required String lastName,
    String? middleName,
    required Suffix suffix,
    required String email,
    required String username,
    required String contactMobile,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final user = await _repository.register( // attempt register - auth repository handles the logic
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        suffix: suffix,
        email: email,
        username: username,
        contactMobile: contactMobile,
        password: password,
      );
      
      if (user != null) {
        state = AsyncValue.data(user);
        return true;
      } else {
        state = const AsyncValue.data(null);
        return false;
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }

  // Check if user has specific role
  bool hasRole(UserRole role) {
    return state.value?.hasRole(role) ?? false;
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) { // // This is User's personal assistant: keeps track of whether he’s logged in
  final repository = ref.watch(authRepositoryProvider); //uses User's toolbox
  return AuthNotifier(repository); // creates an instance of AuthNotifier
});