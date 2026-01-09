import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:ieadao/core/services/auth_service.dart';

// State para o formulário de login
class LoginFormState {
  final String email;
  final String password;
  final bool isLoading;
  final String? errorMessage;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.errorMessage,
  });

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Provider para o estado do formulário
final loginFormProvider = StateNotifierProvider<LoginFormNotifier, LoginFormState>((ref) {
  return LoginFormNotifier();
});

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  LoginFormNotifier() : super(const LoginFormState());

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  Future<void> submit() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // TODO: Implementar login real quando o AuthService estiver pronto
    await Future.delayed(const Duration(seconds: 1));

    state = state.copyWith(
      isLoading: false,
      errorMessage: 'Funcionalidade em desenvolvimento',
    );
  }
}