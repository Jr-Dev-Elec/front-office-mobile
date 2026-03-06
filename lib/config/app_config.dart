class AppConfig {
  // Même origine = pas de CORS
  static const String baseUrl = '';  // ← vide = même origine
  static const String loginChef = '/api/v1/auth/login';
  static String monMenage(String id) => '/api/v1/menages/$id';
  static String mesResidents(String id) => '/api/v1/menages/$id/residents';

  static const Map<String, String> categorieLabels = {
    'TRES_VULNERABLE': 'Très vulnérable',
    'VULNERABLE':      'Vulnérable',
    'A_RISQUE':        'À risque',
    'NON_VULNERABLE':  'Non vulnérable',
    'RICHE':           'Riche',
    'TRES_RICHE':      'Très riche',
  };

  static const Map<String, int> categorieColors = {
    'TRES_VULNERABLE': 0xFFD32F2F,
    'VULNERABLE':      0xFFF44336,
    'A_RISQUE':        0xFFFF9800,
    'NON_VULNERABLE':  0xFF4CAF50,
    'RICHE':           0xFF2196F3,
    'TRES_RICHE':      0xFF9C27B0,
  };
}
