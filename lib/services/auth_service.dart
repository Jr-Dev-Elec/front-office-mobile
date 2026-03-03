import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/models.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  // ── Connexion Chef de Ménage (NOM + CNI) ─────────────────────────────────
  Future<ChefLoginResponse> loginChef({
    required String nomComplet,
    required String cni,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}${AppConfig.loginChef}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nomComplet': nomComplet, 'cni': cni}),
    );

    if (response.statusCode == 200) {
      final data = ChefLoginResponse.fromJson(jsonDecode(response.body));
      // Stocker le token de façon sécurisée
      await _storage.write(key: 'jwt_token', value: data.token);
      await _storage.write(key: 'chef_id',   value: data.chefId);
      await _storage.write(key: 'menage_id', value: data.menageId);
      await _storage.write(key: 'nom',        value: data.nomComplet);
      return data;
    } else if (response.statusCode == 401) {
      throw Exception('NOM ou CNI incorrect. Vérifiez vos informations.');
    } else if (response.statusCode == 404) {
      throw Exception('Aucun chef de ménage trouvé avec ces informations.');
    } else {
      throw Exception('Erreur de connexion. Réessayez plus tard.');
    }
  }

  // ── Récupérer le token stocké ─────────────────────────────────────────────
  Future<String?> getToken() => _storage.read(key: 'jwt_token');
  Future<String?> getNom()   => _storage.read(key: 'nom');
  Future<String?> getMenageId() => _storage.read(key: 'menage_id');

  // ── Vérifier si connecté ──────────────────────────────────────────────────
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Déconnexion ───────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
