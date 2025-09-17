/* 
Firebase Backend for Authentication
*/

import 'dart:async';

import 'package:agenda_century/features/auth/domain/repos/auth_repo.dart';
import 'package:agenda_century/features/auth/domain/entities/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthRepo implements AuthRepo {
  // Add your Firebase authentication methods here
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  @override
  Future<AppUser?> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      AppUser user = AppUser(
        email: email,
        id: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? '',
      );
      return user;
    } catch (e) {
      // Handle errors
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<AppUser?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      AppUser user = AppUser(
        email: email,
        id: userCredential.user!.uid,
        name: name,
      );
      return user;
    } catch (e) {
      // Handle errors
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      return AppUser(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
      );
    }
    return null;
  }

  @override
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return 'Password reset email sent! Check your imbox.';
    } catch (e) {
      // Handle errors
      throw Exception('Password reset email failed: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }
      // delete user account
      await user.delete();

      // sign out user
      await logout();
    } catch (e) {
      // Handle errors
      throw Exception('Account deletion failed: $e');
    }
  }

 // GOOGLE SIGN IN
  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      // begin the interactive sign-in process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      // user cancelled sign-in
      if (gUser == null) return null;

      // obtain auth details from request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // create a credential for the user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // sign in with these credentials
      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // firebase user
      final firebaseUser = userCredential.user;

      // user cancelled sign-in process
      if (firebaseUser == null) return null;

      AppUser appUser = AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? '',
      );

      return appUser;
    } catch (e) {
        print(e);
      return null;
    }
  }
}
