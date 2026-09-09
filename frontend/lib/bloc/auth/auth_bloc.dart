import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<SignupRequested>(_onSignupRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  Future<void> _onSignupRequested(SignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.signup(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      );
      // After signup, log them in automatically
      final token = await authRepository.login(email: event.email, password: event.password);
      emit(AuthAuthenticated(token: token));
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await authRepository.login(email: event.email, password: event.password);
      emit(AuthAuthenticated(token: token));
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final token = await authRepository.getStoredToken();
    if (token != null) {
      emit(AuthAuthenticated(token: token));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}