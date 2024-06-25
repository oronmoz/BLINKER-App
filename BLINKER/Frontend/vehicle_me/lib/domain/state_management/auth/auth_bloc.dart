import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vehicle_me/composition_root.dart';

part 'auth_event.dart';

part 'auth_state.dart';

/// Manages the authentication state of the application.
///
/// This class is responsible for handling user authentication-related events and states.
/// It uses the `FlutterSecureStorage` to securely store and retrieve the authentication token.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  AuthBloc() : super(AuthUnauthenticated()) {
    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthLoggedOut>(_onAuthLoggedOut);
  }

  /// Saves the authentication token to the secure storage.
  ///
  /// [token] - The authentication token to be saved.
  void _saveToken(String token) async {
    await _secureStorage.write(key: 'authToken', value: token);
  }

  /// Deletes the authentication token from the secure storage.
  void _deleteToken() async {
    if (await _secureStorage.containsKey(key: 'authToken')) {
      await _secureStorage.delete(key: 'authToken');
    }
  }

  /// Retrieves the authentication token from the secure storage.
  ///
  /// Returns the authentication token if it exists, otherwise an empty string.
  Future<String> getToken() async {
    var token = await _checkToken();
    if (token == null) {
      return ('');
    }
    return token;
  }

  /// Checks if the authentication token exists in the secure storage.
  ///
  /// Returns the token if it exists, otherwise `null`.
  Future<String?>? _checkToken() async {
    return await _secureStorage.read(key: 'authToken');
  }

  /// Handles the [AuthLoggedIn] event.
  ///
  /// Saves the authentication token and emits the [AuthAuthenticated] state.
  FutureOr<void> _onAuthLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) {
    _saveToken(event.token);
    emit(AuthAuthenticated(event.token));
  }

  /// Handles the [AuthLoggedOut] event.
  ///
  /// Deletes the authentication token and emits the [AuthUnauthenticated] state.
  FutureOr<void> _onAuthLoggedOut(
      AuthLoggedOut event, Emitter<AuthState> emit) {
    _deleteToken();
    emit(AuthUnauthenticated());
  }
}
