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
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool isInitialize = false;

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
        appUser.accessToken =
            (userCredential.credential as OAuthCredential).accessToken!;

        return appUser;
      } else {
        return mobileSignInWithGoogle();
      }
    } catch (e) {
      print('Error en Google Sign-In: $e');
      return null;
    }
  }

  Future<AppUser?> mobileSignInWithGoogle() async {
    try {
      initSignIn();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      print('1. Google authentication completed: ${googleUser != null}');


      final idToken = googleUser.authentication.idToken;
      if (idToken!= null)
        print('2. ID Token obtained: ${idToken}');

      final authorizationClient = googleUser.authorizationClient;
      print('3. Authorization client obtained: ${authorizationClient != null}');
      print('3. Authorization client obtained: ${authorizationClient.toString()}');
      
      GoogleSignInClientAuthorization? authorization = await authorizationClient
          .authorizationForScopes(['https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/calendar.events',]);

      if (authorization?.accessToken != null)
        print('4. First authorization attempt - Access Token: ${authorization?.accessToken}' );

      final accessToken = authorization?.accessToken;
      if (accessToken == null) {
        print('5. First authorization failed, trying again...');
        final authorization2 = await authorizationClient.authorizationForScopes(
          ['calendar', 'calendar.events'],
        );
        print(
          '6. Second authorization attempt - Access Token: ${authorization2?.accessToken != null}',
        );

        if (authorization2?.accessToken == null) {
          print('7. Both authorization attempts failed');
          throw FirebaseAuthException(code: "error", message: "error");
        }
        authorization = authorization2;
      }

      print('8. Final Access Token: ${authorization?.accessToken != null}');

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken ?? authorization?.accessToken,
        idToken: idToken,
      );
      print('9. Google credential created');

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      print('10. Firebase sign-in completed: ${userCredential != null}');

      // firebase user
      final firebaseUser = userCredential.user;
      print('11. Firebase user obtained: ${firebaseUser != null}');
      print('12. User UID: ${firebaseUser?.uid}');
      print('13. User email: ${firebaseUser?.email}');

      // user cancelled sign-in process
      if (firebaseUser == null) return null;

      AppUser appUser = AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? '',
      );
      appUser.accessToken = credential.accessToken!;

      return appUser;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  static Future<void> initSignIn() async {
    if (!isInitialize) {
      await _googleSignIn.initialize(
        serverClientId:
            '722020952500-fol3lqcavu2m27a9s14rs45f3ef4jc6q.apps.googleusercontent.com',
      );
    }
    isInitialize = true;
  }
}
