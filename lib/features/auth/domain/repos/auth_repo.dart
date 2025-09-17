/* 

Auth Repository

*/
import 'dart:async';

import '../entities/app_user.dart';

abstract class AuthRepo {
  // sign in with email and password
  Future<AppUser?> loginWithEmailAndPassword(String email, String password);
  // sign up with email and password
  Future<AppUser?> registerWithEmailAndPassword(String email, String password, String name);
  // sign out
  Future<void> logout();
  // get current user
  Future<AppUser?> getCurrentUser();
  // send password reset email
  Future<String> sendPasswordResetEmail(String email);
  // delete user
  Future<void> deleteAccount(); 
  // SignInGoogle
  Future<AppUser?> signInWithGoogle();

}