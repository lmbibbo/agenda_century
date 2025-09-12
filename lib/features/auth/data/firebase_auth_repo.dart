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

  @override
  Future<AppUser?> signInGoogle() async {
    try {
      // 1. Obtener la instancia de GoogleSignIn e inicializarla
      final GoogleSignIn signIn = GoogleSignIn.instance;

      // Inicializar con los client IDs necesarios (opcional pero recomendado para funcionalidad completa)
      await signIn.initialize(
        // clientId: 'TU_CLIENT_ID_ANDROID', // Opcional para Android, a menudo no necesario si usas google-services.json
        serverClientId:
            'TU_SERVER_CLIENT_ID', // Necesario para obtener el idToken que Firebase Auth requiere
      );

      // 2. Iniciar el proceso de autenticación interactiva
      final GoogleSignInAccount gUser = await signIn.authenticate();

      // 3. Obtener los detalles de autenticación
      final GoogleSignInAuthentication gAuth = gUser.authentication;

      // 4. Crear una credencial para el usuario utilizando SOLAMENTE el idToken
      final credential = GoogleAuthProvider.credential(
        idToken: gAuth
            .idToken, // ✅ En google_sign_in 7.x, se usa principalmente idToken
        // accessToken: gAuth.accessToken, // ⚠️ Normalmente no es necesario para Firebase Auth en este flujo
      );

      // 5. Iniciar sesión en Firebase Auth con la credencial
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // 6. Obtener el usuario de Firebase
      if (userCredential.user == null) return null;
   
      final firebaseUser = userCredential.user;
      
      // 7. Crear y retornar el AppUser
      AppUser appUser = AppUser(
        email: firebaseUser!.email ?? '',
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? ''
      );

      return appUser;
    } catch (e) {
      throw ('Error durante el inicio de sesión con Google: $e');
    }
  }
}
