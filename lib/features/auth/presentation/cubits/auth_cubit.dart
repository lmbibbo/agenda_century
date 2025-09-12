/*

Cubit that manages authentication state using FirebaseAuthRepo.

*/
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_states.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/repos/auth_repo.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());
  //get current user
  AppUser? get currentUser => _currentUser;

  //Check if user is authenticated
  void checkAuth() async {
    emit(AuthLoading());

    final AppUser? user = await authRepo.getCurrentUser();
    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  //Login with email and password
  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      final AppUser? user = await authRepo.loginWithEmailAndPassword(
        email,
        password,
      );
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  //Register with email and password
  Future<void> register(String email, String password, String name) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailAndPassword(
        email,
        password,
        name,
      );
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  //Logout
  Future<void> logout() async {
    emit(AuthLoading());
    await authRepo.logout();
    emit(Unauthenticated());
  }

  // forgot password
  Future<String> forgotPassword(String email) async {
    try {
      emit(AuthLoading());
      final message = await authRepo.sendPasswordResetEmail(email);
      emit(Unauthenticated());
      return message;
    } catch (e) {
      return e.toString();
    }
  }

  // delete account
  Future<void> deleteAccount() async {
    try {
      emit(AuthLoading());
      await authRepo.deleteAccount();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }
}