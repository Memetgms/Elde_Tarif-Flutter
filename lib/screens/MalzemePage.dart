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
  // Seçili malzemeler (id seti)
  final Set<int> _seciliMalzemeIdleri = {};

  // Arama alanı için controller
  final _aramaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sayfa açılınca veriyi yükle
    Future.microtask(() => context.read<MalzemeProvider>().veriyiYukle());
  }

  @override
  void dispose() {
    _aramaCtrl.dispose();
    super.dispose();
  }

  // Palette E
  static const _primary      = Color(0xFF3B82F6); // blue-500
  static const _primaryDark  = Color(0xFF2563EB); // blue-600
  static const _surfaceSoft  = Color(0xFFF1F5F9); // slate-50
  Color get _border    => const Color(0xFFE2E8F0); // slate-200
  Color get _textMuted => const Color(0xFF64748B); // slate-500

  // Bir malzemeyi seç/çıkar (toggle)
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

    // Yükleniyor / hata durumları
    if (p.yukleniyor) {
      return const SafeArea(
        child: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    if (p.hata != null) {
      return SafeArea(
        child: Scaffold(body: Center(child: Text('Hata: ${p.hata}'))),
      );
    }

    // Tek seçimli tür için mevcut değer (yoksa null)
    final String? seciliTur = p.seciliTurler.isEmpty ? null : p.seciliTurler.first;

    // Filtrelenmiş liste
    final List<Malzeme> liste = p.filtreliListe;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // --- ARAMA BÖLÜMÜ ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _aramaCtrl,
                      onChanged: p.aramaMetniniAyarla,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Malzeme ara (örn: soğan, makarna...)',
                        hintStyle: TextStyle(color: _textMuted),
                        prefixIcon: Icon(Icons.search, color: _textMuted),
                        suffixIcon: (_aramaCtrl.text.isNotEmpty || p.aramaMetni.isNotEmpty)
                            ? IconButton(
                          icon: Icon(Icons.close, color: _textMuted),
                          tooltip: 'Temizle',
                          onPressed: () {
                            _aramaCtrl.clear();
                            p.aramaMetniniAyarla('');
                          },
                        )
                            : null,
                        filled: true,
                        fillColor: _surfaceSoft,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: _primary, width: 1.2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Mikrofon butonu (şimdilik işlevsiz)
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: Material(
                      color: _surfaceSoft,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // TODO: Sesli arama tetikle (şimdilik boş)
                        },
                        child: Icon(Icons.mic_none, color: _textMuted),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- TÜR ÇİPLERİ (TEK SEÇİMLİ) ---
            if (p.tumTurler.isNotEmpty)
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: p.tumTurler.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final tur = p.tumTurler[i];
                    final aktif = (seciliTur == tur);
                    return ChoiceChip(
                      label: Text(
                        tur,
                        style: TextStyle(
                          fontWeight: aktif ? FontWeight.w600 : FontWeight.w500,
                          color: aktif ? _primaryDark : Colors.black87,
                        ),
                      ),
                      selected: aktif,
                      backgroundColor: _surfaceSoft,
                      selectedColor: _primary.withOpacity(0.15),
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: aktif ? _primary : _border,
                          width: 1.2,
                        ),
                      ),
                      onSelected: (_) => p.turTekSec(aktif ? null : tur),
                    );
                  },
                ),
              ),

            // --- LİSTE ---
            const SizedBox(height: 8),
            Expanded(
              child: liste.isEmpty
                  ? const Center(child: Text('Sonuç bulunamadı'))
                  : ListView.separated(
                padding: const EdgeInsets.only(bottom: 88, left: 12, right: 12),
                itemCount: liste.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final m = liste[i];
                  final seciliMi = _seciliMalzemeIdleri.contains(m.id);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: seciliMi ? _primary.withOpacity(0.08) : Colors.white,
                      border: Border.all(
                        color: seciliMi ? _primary : _border,
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _malzemeSeciminiDegistir(m),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Row(
                            children: [
                              // Sol ikon
                              Icon(
                                Icons.restaurant_outlined,
                                color: seciliMi ? _primaryDark : _textMuted,
                              ),
                              const SizedBox(width: 12),

                              // İsim + tür (esnek alan)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.ad,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      m.malzemeTur,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Sağda seçim durumu (tik / boş)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 160),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: seciliMi
                                    ? const Icon(
                                  Icons.check_circle,
                                  key: ValueKey('check'),
                                  color: _primary,
                                )
                                    : Icon(
                                  Icons.circle_outlined,
                                  key: const ValueKey('uncheck'),
                                  color: _textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        // --- ALT SABİT ÇUBUK: "X seçili" + (isteğe göre çöp kutusu) + "Tarif ara" ---
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Seçili sayısı (her zaman görünsün)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _primary.withOpacity(0.25)),
                  ),
                  child: Text(
                    '${_seciliMalzemeIdleri.length} seçili',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _primaryDark,
                    ),
                  ),
                ),

                // Sadece seçim varsa kırmızı çöp kutusu gelsin
                if (_seciliMalzemeIdleri.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: "Seçilenleri temizle",
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 26,
                    ),
                    onPressed: () {
                      setState(() => _seciliMalzemeIdleri.clear());
                    },
                  ),
                ],

                const SizedBox(width: 8),

                // Tarif ara butonu (her durumda aynı boy)
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: seçilen malzemelere göre arama işlemi
                      },
                      icon: const Icon(Icons.search, size: 22),
                      label: const Text('Tarif ara'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
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
