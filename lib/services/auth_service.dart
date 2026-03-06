import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/models.dart';

class AuthService {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  String? _extractMenageIdFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      String payload = parts[1];
      // Ajouter padding base64
      while (payload.length % 4 != 0) payload += '=';
      final decoded = utf8.decode(base64Url.decode(payload));
      final claims = jsonDecode(decoded);
      return claims['menageId']?.toString();
    } catch (e) {
      return null;
    }
  }

  Future<ChefLoginResponse> loginChef({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}${AppConfig.loginChef}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['role'] != 'CHEF_MENAGE') {
        throw Exception('Ce compte n\'est pas un Chef de ménage.');
      }

      final accessToken = json['accessToken'] ?? '';
      // Extraire menageId depuis le JWT
      final menageId = json['menageId'] ?? _extractMenageIdFromJwt(accessToken) ?? '';

      final prefs = await _prefs;
      await prefs.setString('jwt_token',     accessToken);
      await prefs.setString('refresh_token', json['refreshToken'] ?? '');
      await prefs.setString('chef_id',       json['userId'] ?? '');
      await prefs.setString('menage_id',     menageId);
      await prefs.setString('nom',           json['fullName'] ?? '');

      return ChefLoginResponse.fromJson({...json, 'menageId': menageId});
    } else if (response.statusCode == 401) {
      throw Exception('Email ou mot de passe incorrect.');
    } else if (response.statusCode == 423) {
      throw Exception('Compte bloqué. Contactez un agent.');
    } else {
      throw Exception('Erreur de connexion (${response.statusCode}).');
    }
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString('jwt_token');
  }

  Future<String?> getMenageId() async {
    final prefs = await _prefs;
    return prefs.getString('menage_id');
  }

  Future<String?> getNom() async {
    final prefs = await _prefs;
    return prefs.getString('nom');
  }

  Future<bool> isLoggedIn() async {
    final t = await getToken();
    return t != null && t.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
