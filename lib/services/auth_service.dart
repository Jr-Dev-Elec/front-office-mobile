import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/models.dart';
class AuthService {
  final _storage = const FlutterSecureStorage();
  Future<ChefLoginResponse> loginChef({required String nomComplet, required String cni}) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}${AppConfig.loginChef}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nomComplet': nomComplet, 'numeroCni': cni}),
    );
    if (response.statusCode == 200) {
      final data = ChefLoginResponse.fromJson(jsonDecode(response.body));
      await _storage.write(key: 'jwt_token', value: data.token);
      await _storage.write(key: 'refresh_token', value: data.refreshToken);
      await _storage.write(key: 'chef_id', value: data.chefId);
      await _storage.write(key: 'menage_id', value: data.menageId);
      await _storage.write(key: 'nom', value: data.nomComplet);
      return data;
    } else if (response.statusCode == 401) {
      throw Exception('NOM ou CNI incorrect.');
    } else if (response.statusCode == 423) {
      throw Exception('Compte bloque. Contactez un agent.');
    } else {
      throw Exception('Erreur de connexion (${response.statusCode}).');
    }
  }
  Future<String?> getToken() => _storage.read(key: 'jwt_token');
  Future<String?> getMenageId() => _storage.read(key: 'menage_id');
  Future<String?> getNom() => _storage.read(key: 'nom');
  Future<bool> isLoggedIn() async { final t = await getToken(); return t != null && t.isNotEmpty; }
  Future<void> logout() async { await _storage.deleteAll(); }
}
