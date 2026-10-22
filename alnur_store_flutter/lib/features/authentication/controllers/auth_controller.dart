import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final UserProfile? user;
  final bool rememberMe;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.user,
    this.rememberMe = true,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserProfile? user,
    bool? rememberMe,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  void toggleRememberMe(bool? value) {
    state = state.copyWith(rememberMe: value ?? !state.rememberMe);
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Simulate network request
      await Future.delayed(const Duration(milliseconds: 1000));

      if (email.trim().isEmpty || password.trim().isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Please enter both email and password.',
        );
        return false;
      }

      state = state.copyWith(
        isLoading: false,
        user: UserProfile(
          id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
          name: email.split('@').first,
          email: email.trim(),
        ),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Login failed. Please check your credentials.',
      );
      return false;
    }
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      if (fullName.trim().isEmpty ||
          email.trim().isEmpty ||
          password.trim().isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Please fill in all required fields.',
        );
        return false;
      }

      state = state.copyWith(
        isLoading: false,
        user: UserProfile(
          id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
          name: fullName.trim(),
          email: email.trim(),
          phone: phone.trim(),
        ),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Registration failed. Please try again.',
      );
      return false;
    }
  }

  void continueAsGuest() {
    state = state.copyWith(
      isLoading: false,
      user: UserProfile.guest(),
      errorMessage: null,
    );
  }

  void logout() {
    state = const AuthState();
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
