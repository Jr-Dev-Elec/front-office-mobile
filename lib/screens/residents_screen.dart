import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class ResidentsScreen extends StatefulWidget {
  const ResidentsScreen({super.key});

  @override
  State<ResidentsScreen> createState() => _ResidentsScreenState();
}

class _ResidentsScreenState extends State<ResidentsScreen> {
  final _api = ApiService();
  List<Resident> _residents = [];
  bool   _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _api.getMesResidents();
      setState(() { _residents = data; });
    } catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        title: Text('Mes Résidents', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)))
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: const Color(0xFF1B5E20),
                  child: Column(
                    children: [
                      // Header résumé
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        color: const Color(0xFF1B5E20),
                        child: Row(
                          children: [
                            const Icon(Icons.people_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text('${_residents.length} résident(s) dans le ménage',
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                      // Liste
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _residents.length,
                          itemBuilder: (ctx, i) => _buildCard(_residents[i]),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCard(Resident r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
        border: r.estChef
            ? Border.all(color: const Color(0xFF1B5E20), width: 1.5)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: r.estChef ? const Color(0xFFE8F5E9) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    r.estChef ? Icons.star_rounded : Icons.person_outline_rounded,
                    color: r.estChef ? const Color(0xFF1B5E20) : Colors.grey[500],
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(r.nomComplet,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                          if (r.estChef)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B5E20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('Chef', style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                      Text('CNI: ${r.cni}', style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _chip(Icons.flag_outlined,       r.nationalite),
                _chip(Icons.cake_outlined,        r.dateNaissance),
                _chip(Icons.school_outlined,      r.diplome),
                _chip(Icons.payments_outlined,    r.trancheSalariale),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
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
