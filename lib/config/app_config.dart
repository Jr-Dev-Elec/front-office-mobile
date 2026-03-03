class AppConfig {
  // 10.0.2.2 = localhost depuis l'émulateur Android
  // Remplacez par l'IP de votre machine si test sur vrai téléphone
  static const String baseUrl = 'http://10.0.2.2:9000';

  // Endpoints auth
  static const String loginChef = '/api/auth/chef/login';

  // Endpoints main-service (via gateway)
  static const String monMenage    = '/api/main/chef/menage';
  static const String mesResidents = '/api/main/chef/residents';
  static const String monScore     = '/api/main/chef/scoring';

  // Catégories sociales
  static const Map<String, String> categorieLabels = {
    'TRES_VULNERABLE': 'Très vulnérable',
    'VULNERABLE':      'Vulnérable',
    'A_RISQUE':        'À risque',
    'NON_VULNERABLE':  'Non vulnérable',
    'RICHE':           'Riche',
    'TRES_RICHE':      'Très riche',
  };

  static const Map<String, int> categorieColors = {
    'TRES_VULNERABLE': 0xFFD32F2F,  // Rouge foncé
    'VULNERABLE':      0xFFF44336,  // Rouge
    'A_RISQUE':        0xFFFF9800,  // Orange
    'NON_VULNERABLE':  0xFF4CAF50,  // Vert
    'RICHE':           0xFF2196F3,  // Bleu
    'TRES_RICHE':      0xFF9C27B0,  // Violet
  };
}
