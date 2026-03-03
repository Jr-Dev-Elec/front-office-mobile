import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/models.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── Mon Ménage ────────────────────────────────────────────────────────────
  Future<Menage> getMonMenage() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}${AppConfig.monMenage}'),
      headers: await _headers(),
    );
    _checkResponse(response);
    return Menage.fromJson(jsonDecode(response.body));
  }

  // ── Mes Résidents ─────────────────────────────────────────────────────────
  Future<List<Resident>> getMesResidents() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}${AppConfig.mesResidents}'),
      headers: await _headers(),
    );
    _checkResponse(response);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Resident.fromJson(e)).toList();
  }

  // ── Mon Score / Catégorie Sociale ─────────────────────────────────────────
  Future<ScoringInfo> getMonScore() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}${AppConfig.monScore}'),
      headers: await _headers(),
    );
    _checkResponse(response);
    return ScoringInfo.fromJson(jsonDecode(response.body));
  }

  void _checkResponse(http.Response r) {
    if (r.statusCode == 401) throw Exception('Session expirée. Reconnectez-vous.');
    if (r.statusCode == 403) throw Exception('Accès non autorisé.');
    if (r.statusCode == 404) throw Exception('Données introuvables.');
    if (r.statusCode >= 400) throw Exception('Erreur serveur (${r.statusCode}).');
  }
}
