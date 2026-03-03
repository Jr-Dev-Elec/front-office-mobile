class AppConfig {
  static const String baseUrl = 'http://10.0.2.2:9000';
  static const String loginChef = '/api/auth/chef/login';
  static String monMenage(String id) => '/api/main/api/v1/menages/$id';
  static String mesResidents(String id) => '/api/main/api/v1/menages/$id/residents';
  static const Map<String, String> categorieLabels = {
    'TRES_VULNERABLE': 'Tres vulnerable',
    'VULNERABLE': 'Vulnerable',
    'A_RISQUE': 'A risque',
    'NON_VULNERABLE': 'Non vulnerable',
    'RICHE': 'Riche',
    'TRES_RICHE': 'Tres riche',
  };
  static const Map<String, int> categorieColors = {
    'TRES_VULNERABLE': 0xFFD32F2F,
    'VULNERABLE': 0xFFF44336,
    'A_RISQUE': 0xFFFF9800,
    'NON_VULNERABLE': 0xFF4CAF50,
    'RICHE': 0xFF2196F3,
    'TRES_RICHE': 0xFF9C27B0,
  };
}
