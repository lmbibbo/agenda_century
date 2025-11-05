// token_manager.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class TokenManager {
  String? _accessToken;
  DateTime? _expiryTime;
  final Future<String?> Function() _refreshTokenCallback;

  TokenManager({required Future<String?> Function() refreshTokenCallback})
      : _refreshTokenCallback = refreshTokenCallback;

  Future<String?> get accessToken async {
    if (_isTokenExpired || _accessToken == null) {
      print('🔄 Token expirado o nulo, refrescando...');
      await _refreshToken();
    }
    return _accessToken;
  }

  bool get _isTokenExpired {
    if (_expiryTime == null) return true;
    return DateTime.now().isAfter(_expiryTime!.subtract(Duration(minutes: 5)));
  }

  Future<void> _refreshToken() async {
    try {
      final newToken = await _refreshTokenCallback();
      if (newToken != null) {
        _accessToken = newToken;
        _expiryTime = DateTime.now().add(Duration(hours: 1));
        print('✅ Token refrescado exitosamente');
      } else {
        print('❌ Error: No se pudo refrescar el token');
        throw Exception('No se pudo refrescar el token');
      }
    } catch (e) {
      print('❌ Error refrescando token: $e');
      rethrow;
    }
  }

  void setInitialToken(String accessToken) {
    _accessToken = accessToken;
    _expiryTime = DateTime.now().add(Duration(hours: 1));
    print('🗝️ Token inicial configurado - Expira: $_expiryTime');
  }

  void clearTokens() {
    _accessToken = null;
    _expiryTime = null;
    print('🗑️ Tokens eliminados');
  }
}