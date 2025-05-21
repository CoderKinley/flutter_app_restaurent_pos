import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

class LogoutRequested extends AuthEvent {}

class UpdateCredentials extends AuthEvent {
  final String username;
  final String password;

  const UpdateCredentials({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String username;

  const Authenticated(this.username);

  @override
  List<Object> get props => [username];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SharedPreferences prefs;

  AuthBloc({required this.prefs}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<UpdateCredentials>(_onUpdateCredentials);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final savedUsername = prefs.getString('username');
      final savedPassword = prefs.getString('password');

      if (event.username == savedUsername && event.password == savedPassword) {
        await prefs.setBool('isLoggedIn', true);
        emit(Authenticated(event.username));
      } else {
        emit(const AuthError('Invalid credentials'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await prefs.setBool('isLoggedIn', false);
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onUpdateCredentials(
    UpdateCredentials event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await prefs.setString('username', event.username);
      await prefs.setString('password', event.password);
      emit(Authenticated(event.username));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
