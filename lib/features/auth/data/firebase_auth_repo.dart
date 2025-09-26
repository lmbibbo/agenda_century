/* 
Firebase Backend for Authentication
*/

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:agenda_century/features/auth/domain/repos/auth_repo.dart';
import 'package:agenda_century/features/auth/domain/entities/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';

class FirebaseAuthRepo implements AuthRepo {
  // Add your Firebase authentication methods here
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

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
    // Solo hacer signOut de Google SignIn si NO es web
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
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
      // Para Flutter Web, usa signInWithPopup
      if (kIsWeb) {
        UserCredential userCredential;

        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        // ✅ ESTO ES CLAVE: Forzar selección de cuenta siempre
        googleProvider.setCustomParameters({
          'prompt': 'select_account',
          //'client_id': '722020952500-vhmb4h17660ksbt18mksb6iqusuqko75.apps.googleusercontent.com'
        });

        googleProvider.addScope(CalendarApi.calendarScope);
        googleProvider.addScope(CalendarApi.calendarReadonlyScope);
        googleProvider.addScope(CalendarApi.calendarEventsScope);
        
        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
        final firebaseUser = userCredential.user;
        if (firebaseUser == null) return null;

        AppUser appUser = AppUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? '',
        );

        final String? accessToken = (userCredential.credential as OAuthCredential).accessToken;      
        appUser.accessToken=accessToken!;
        
        return appUser;
      } else {
        // begin the interactive sign-in process
        final GoogleSignInAccount? gUser = await _googleSignIn.signIn();

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
        UserCredential userCredential = await _firebaseAuth
            .signInWithCredential(credential);

        // firebase user
        final firebaseUser = userCredential.user;

        // user cancelled sign-in process
        if (firebaseUser == null) return null;

        AppUser appUser = AppUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? '',
        );
        appUser.accessToken=credential.accessToken!;

        return appUser;
      }
    } catch (e) {
        print('Error en Google Sign-In: $e');
      return null;
    }
  }
}
