import 'package:elde_tarif/apiservice.dart';
import 'package:elde_tarif/screens/tarif_oneri_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elde_tarif/Providers/malzeme_provider.dart';
import 'package:elde_tarif/models/malzeme.dart';

class MalzemelerPage extends StatefulWidget {
  const MalzemelerPage({super.key});

  @override
  State<MalzemelerPage> createState() => _MalzemelerPageState();
}

class _MalzemelerPageState extends State<MalzemelerPage> {
  final Set<int> _seciliMalzemeIdleri = {};
  final TextEditingController _aramaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MalzemeProvider>().veriyiYukle());
  }

  @override
  void dispose() {
    _aramaCtrl.dispose();
    super.dispose();
  }

  // UI renkleri
  static const _primary = Color(0xFF3B82F6);
  static const _primaryDark = Color(0xFF2563EB);
  static const _surfaceSoft = Color(0xFFF1F5F9);

  Color get _border => const Color(0xFFE2E8F0);
  Color get _textMuted => const Color(0xFF64748B);

  void _malzemeSeciminiDegistir(Malzeme m) {
    setState(() {
      if (_seciliMalzemeIdleri.contains(m.id)) {
        _seciliMalzemeIdleri.remove(m.id);
      } else {
        _seciliMalzemeIdleri.add(m.id);
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final p = context.watch<MalzemeProvider>();

    if (p.yukleniyor) {
      return const SafeArea(
        child: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (p.hata != null) {
      return SafeArea(
        child: Scaffold(
          body: Center(child: Text("Hata: ${p.hata}")),
        ),
      );
    }

    final String? seciliTur =
    p.seciliTurler.isEmpty ? null : p.seciliTurler.first;
    final List<Malzeme> liste = p.filtreliListe;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // ARAMA ALANI
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _aramaCtrl,
                      onChanged: p.aramaMetniniAyarla,
                      decoration: InputDecoration(
                        hintText: "Malzeme ara...",
                        prefixIcon: Icon(Icons.search, color: _textMuted),
                        suffixIcon: (_aramaCtrl.text.isNotEmpty ||
                            p.aramaMetni.isNotEmpty)
                            ? IconButton(
                          icon: Icon(Icons.close, color: _textMuted),
                          onPressed: () {
                            _aramaCtrl.clear();
                            p.aramaMetniniAyarla("");
                          },
                        )
                            : null,
                        filled: true,
                        fillColor: _surfaceSoft,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // TÜRLER - CHIPS
            if (p.tumTurler.isNotEmpty)
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: p.tumTurler.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final tur = p.tumTurler[i];
                    final aktif = (seciliTur == tur);

                    return ChoiceChip(
                      label: Text(
                        tur,
                        style: TextStyle(
                          fontWeight:
                          aktif ? FontWeight.bold : FontWeight.w500,
                          color: aktif ? _primaryDark : Colors.black87,
                        ),
                      ),
                      selected: aktif,
                      selectedColor: _primary.withOpacity(0.2),
                      onSelected: (_) => p.turTekSec(aktif ? null : tur),
                    );
                  },
                ),
              ),

            const SizedBox(height: 8),

            // MALZEME LİSTESİ
            Expanded(
              child: liste.isEmpty
                  ? Center(child: Text("Sonuç bulunamadı"))
                  : ListView.separated(
                padding: const EdgeInsets.only(
                    bottom: 88, left: 12, right: 12),
                itemCount: liste.length,
                separatorBuilder: (_, __) => SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final m = liste[i];
                  final seciliMi = _seciliMalzemeIdleri.contains(m.id);

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: seciliMi
                          ? _primary.withOpacity(0.08)
                          : Colors.white,
                      border: Border.all(
                        color: seciliMi ? _primary : _border,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      onTap: () => _malzemeSeciminiDegistir(m),
                      leading: Icon(
                        Icons.restaurant,
                        color: seciliMi ? _primaryDark : _textMuted,
                      ),
                      title: Text(m.ad),
                      subtitle: Text(
                        m.malzemeTur,
                        style: TextStyle(color: _textMuted),
                      ),
                      trailing: Icon(
                        seciliMi
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: seciliMi ? _primary : _textMuted,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        // ALT BUTON — TARİF ARAMA
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black12,
                  offset: Offset(0, -3),
                )
              ],
            ),
            child: Row(
              children: [
                // Seçili sayacı
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${_seciliMalzemeIdleri.length} seçili",
                    style: TextStyle(
                      color: _primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(width: 10),

                //  Tarif Ara Butonu
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _seciliMalzemeIdleri.isEmpty
                          ? null
                          : () {
                        // Eğer hiç malzeme seçili değilse zaten buton disabled olacak.
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TarifOneriPage(
                              seciliMalzemeIdleri:
                              _seciliMalzemeIdleri.toList(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search),
                      label: const Text("Tarif ara"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        disabledBackgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}