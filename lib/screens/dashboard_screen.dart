import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_config.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'residents_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _api  = ApiService();
  final _auth = AuthService();

  Menage?      _menage;
  ScoringInfo? _scoring;
  String?      _nom;
  bool         _loading = true;
  String?      _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _api.getMonMenage(),
        _api.getMonScore(),
        _auth.getNom(),
      ]);
      setState(() {
        _menage  = results[0] as Menage;
        _scoring = results[1] as ScoringInfo;
        _nom     = results[2] as String?;
      });
    } catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        title: Text('Mon Espace', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _load,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)))
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: const Color(0xFF1B5E20),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildScoringCard(),
                        _buildInfoCard(),
                        _buildEquipementsCard(),
                        _buildActions(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF1B5E20),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bonjour,', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                Text(
                  _nom ?? _menage?.nomChef ?? '',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Code: ${_menage?.code ?? ''}',
                  style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Carte Score + Catégorie ───────────────────────────────────────────────
  Widget _buildScoringCard() {
    if (_scoring == null) return const SizedBox.shrink();

    final cat   = _scoring!.categorie;
    final color = Color(AppConfig.categorieColors[cat] ?? 0xFF4CAF50);
    final label = AppConfig.categorieLabels[cat] ?? cat;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.75)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Catégorie Sociale', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                const Icon(Icons.verified_rounded, color: Colors.white, size: 22),
              ],
            ),
            const SizedBox(height: 12),
            Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Barre de progression du score
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_scoring!.score / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                Text('${_scoring!.score} / 100 pts', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Text(_scoring!.description, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ── Informations du Ménage ────────────────────────────────────────────────
  Widget _buildInfoCard() {
    if (_menage == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mon Ménage', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF1B5E20))),
            const SizedBox(height: 12),
            _infoRow(Icons.home_outlined, 'Code ménage', _menage!.code),
            _infoRow(Icons.person_outline, 'Chef', _menage!.nomChef),
            _infoRow(Icons.people_outline, 'Résidents', '${_menage!.nombreResidents} personne(s)'),
            _infoRow(
              _menage!.isOwner ? Icons.house_rounded : Icons.apartment_rounded,
              'Logement',
              _menage!.isOwner ? 'Propriétaire' : 'Locataire',
            ),
          ],
        ),
      ),
    );
  }

  // ── Équipements ───────────────────────────────────────────────────────────
  Widget _buildEquipementsCard() {
    if (_menage == null) return const SizedBox.shrink();
    final equips = [
      {'icon': Icons.tv_rounded,         'label': 'TV',      'val': _menage!.hasTv},
      {'icon': Icons.radio_rounded,      'label': 'Radio',   'val': _menage!.hasRadio},
      {'icon': Icons.two_wheeler_rounded,'label': 'Moto',    'val': _menage!.hasMotorcycle},
      {'icon': Icons.directions_car,     'label': 'Voiture', 'val': _menage!.hasCar},
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Équipements', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF1B5E20))),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: equips.map((e) => _equipBadge(e['icon'] as IconData, e['label'] as String, e['val'] as bool)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions rapides ───────────────────────────────────────────────────────
  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResidentsScreen())),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1B5E20).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.people_rounded, color: Color(0xFF1B5E20), size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mes Résidents', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20), fontSize: 15)),
                    Text('Voir les membres de mon ménage', style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFF1B5E20), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 10),
          Text('$label: ', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
          Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _equipBadge(IconData icon, String label, bool hasIt) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasIt ? const Color(0xFFE8F5E9) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: hasIt ? const Color(0xFF1B5E20) : Colors.grey[400], size: 24),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: hasIt ? const Color(0xFF1B5E20) : Colors.grey[400])),
        Icon(hasIt ? Icons.check_circle : Icons.cancel, size: 14, color: hasIt ? Colors.green : Colors.grey[400]),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, style: GoogleFonts.poppins(color: Colors.grey[700]), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
