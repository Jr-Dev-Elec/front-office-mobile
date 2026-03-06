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

  Future<Menage> getMonMenage() async {
    final menageId = await _auth.getMenageId();
    if (menageId == null || menageId.isEmpty) {
      throw Exception('Ménage non associé au compte.');
    }
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}${AppConfig.monMenage(menageId)}'),
      headers: await _headers(),
    );
    _checkResponse(response);
    return Menage.fromJson(jsonDecode(response.body));
  }

  Future<List<Resident>> getMesResidents() async {
    final menageId = await _auth.getMenageId();
    if (menageId == null || menageId.isEmpty) {
      throw Exception('Ménage non associé au compte.');
    }
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}${AppConfig.mesResidents(menageId)}'),
      headers: await _headers(),
    );
    _checkResponse(response);
    return (jsonDecode(response.body) as List)
        .map((e) => Resident.fromJson(e))
        .toList();
  }

  void _checkResponse(http.Response r) {
    if (r.statusCode == 401) throw Exception('Session expirée. Reconnectez-vous.');
    if (r.statusCode == 403) throw Exception('Accès non autorisé.');
    if (r.statusCode == 404) throw Exception('Données introuvables.');
    if (r.statusCode >= 400) throw Exception('Erreur serveur (${r.statusCode}).');
  }
}
