class Menage {
  final String id;
  final String code;
  final String nomChef;
  final bool hasTv;
  final bool hasRadio;
  final bool hasMotorcycle;
  final bool hasCar;
  final bool isOwner;
  final int nombreResidents;
  final String? categorie;
  final int? score;

  Menage({
    required this.id,
    required this.code,
    required this.nomChef,
    required this.hasTv,
    required this.hasRadio,
    required this.hasMotorcycle,
    required this.hasCar,
    required this.isOwner,
    required this.nombreResidents,
    this.categorie,
    this.score,
  });

  factory Menage.fromJson(Map<String, dynamic> j) => Menage(
    id: j['id'] ?? '',
    code: j['code'] ?? '',
    nomChef: j['nomChef'] ?? '',
    hasTv: j['aTelevision'] ?? false,
    hasRadio: j['aRadio'] ?? false,
    hasMotorcycle: j['aMoto'] ?? false,
    hasCar: j['aVoiture'] ?? false,
    isOwner: j['statutHabitation'] == 'PROPRIETAIRE',
    nombreResidents: j['nombreResidents'] ?? 0,
    categorie: j['categorie'],
    score: j['score'],
  );
}

class Resident {
  final String id;
  final String nom;
  final String prenom;
  final String cni;
  final String nationalite;
  final String dateNaissance;
  final String trancheSalariale;
  final String diplome;
  final bool estChef;

  Resident({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.cni,
    required this.nationalite,
    required this.dateNaissance,
    required this.trancheSalariale,
    required this.diplome,
    required this.estChef,
  });

  String get nomComplet => '$prenom $nom';

  factory Resident.fromJson(Map<String, dynamic> j) => Resident(
    id: j['id'] ?? '',
    nom: j['nom'] ?? '',
    prenom: j['prenom'] ?? '',
    cni: j['numeroCni'] ?? '',
    nationalite: j['nationalite'] ?? '',
    dateNaissance: j['dateNaissance'] ?? '',
    trancheSalariale: j['trancheSalariale'] ?? '',
    diplome: j['diplome'] ?? '',
    estChef: j['chef'] ?? false,
  );
}

class ChefLoginResponse {
  final String token;
  final String refreshToken;
  final String chefId;
  final String menageId;
  final String nomComplet;
  final String role;

  ChefLoginResponse({
    required this.token,
    required this.refreshToken,
    required this.chefId,
    required this.menageId,
    required this.nomComplet,
    required this.role,
  });

  factory ChefLoginResponse.fromJson(Map<String, dynamic> j) => ChefLoginResponse(
    token: j['token'] ?? '',
    refreshToken: j['refreshToken'] ?? '',
    chefId: j['chefId'] ?? '',
    menageId: j['menageId'] ?? '',
    nomComplet: j['nomComplet'] ?? '',
    role: j['role'] ?? 'CHEF_MENAGE',
  );
}

// ========== NOUVEAU MODÈLE AJOUTÉ ==========
class ScoringInfo {
  final int score;
  final int rank;
  final int total;
  final String categorie;
  final String description;

  ScoringInfo({
    required this.score,
    required this.rank,
    required this.total,
    required this.categorie,
    required this.description,
  });

  factory ScoringInfo.fromJson(Map<String, dynamic> json) {
    return ScoringInfo(
      score: json['score'] ?? 0,
      rank: json['rank'] ?? 0,
      total: json['total'] ?? 0,
      categorie: json['categorie'] ?? 'Non classé',
      description: json['description'] ?? '',
    );
  }
}