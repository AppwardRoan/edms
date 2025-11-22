import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth State Notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null));

  // Login
  Future<bool> login(String usernameOrEmail, String password) async {
    state = const AsyncValue.loading();
    
    try {
      final user = await _repository.login(usernameOrEmail, password);
      
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

  // Register
  Future<bool> register({
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
      final user = await _repository.register(
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
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});