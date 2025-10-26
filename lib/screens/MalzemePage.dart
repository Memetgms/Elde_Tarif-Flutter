// lib/screens/malzemeler_page.dart
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:elde_tarif/providers/malzeme_provider.dart';
import 'package:elde_tarif/models/malzeme.dart';

class MalzemelerPage extends StatefulWidget {
  const MalzemelerPage({super.key});

  @override
  State<MalzemelerPage> createState() => _MalzemelerPageState();
}

class _MalzemelerPageState extends State<MalzemelerPage> {
  final Map<String, GlobalKey> _sectionKeys = {};
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Provider'dan malzemeleri yükle
    Future.microtask(() => context.read<MalzemeProvider>().load());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureSectionKeys(List<String> headers) {
    for (final h in headers) {
      _sectionKeys.putIfAbsent(h, () => GlobalKey());
    }
  }

  Future<void> _scrollTo(String header) async {
    final key = _sectionKeys[header];
    if (key == null) return;
    final ctx = key.currentContext;
    if (ctx == null) return; // ağaçta değilse vazgeç
    await Scrollable.ensureVisible(
      ctx,
      alignment: 0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MalzemeProvider>();

    if (prov.loading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }
    if (prov.error != null) {
      return SafeArea(child: Center(child: Text('Hata: ${prov.error}')));
    }

    // Baş harfe göre gruplama
    final grouped = groupBy<Malzeme, String>(prov.filtered, (m) {
      final c = (m.ad.isNotEmpty ? m.ad[0] : '#').toUpperCase();
      final isAlpha = RegExp(r'[A-ZÇĞİÖŞÜ]').hasMatch(c);
      return isAlpha ? c : '#';
    });

    // Dinamik header listesi
    final headers = grouped.keys.toList()..sort();

      // ARTIK OLMAYAN harflerin key'lerini temizle → stale key hatalarını önler
    _sectionKeys.removeWhere((letter, _) => !headers.contains(letter));

    // Eksik key'leri oluştur
    _ensureSectionKeys(headers);

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  title: const Text('Malzemeler', style: TextStyle(fontWeight: FontWeight.w600)),
                ),

                // Arama çubuğu
                SliverToBoxAdapter(
                  child: _SearchBar(
                    value: prov.search,
                    onChanged: prov.setSearch,
                  ),
                ),

                // Tür filtre çipleri
                SliverToBoxAdapter(
                  child: _TypeChips(
                    allTypes: prov.allTypes,
                    selected: prov.selectedTypes,
                    onToggle: prov.toggleType,
                  ),
                ),

                // Gruplar
                ...headers.map((h) {
                  final items = (grouped[h]!..sort((a, b) => a.ad.compareTo(b.ad)))!;
                  return SliverToBoxAdapter(
                    child: KeyedSubtree(
                      key: _sectionKeys[h],
                      child: _Section(header: h, items: items),
                    ),
                  );
                }),

                const SliverToBoxAdapter(child: SizedBox(height: 48)),
              ],
            ),

            // Sağ alfabe rayı
            if (headers.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: _AlphabetRail(
                  letters: headers,
                  onTap: _scrollTo,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// — UI parçaları —
class _SearchBar extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Malzeme ara (örn: soğan, makarna...)',
          prefixIcon: const Icon(Icons.search),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _TypeChips extends StatelessWidget {
  final List<String> allTypes;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  const _TypeChips({required this.allTypes, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    if (allTypes.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final t = allTypes[i];
          final isSel = selected.contains(t);
          return FilterChip(
            label: Text(t),
            selected: isSel,
            onSelected: (_) => onToggle(t),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: allTypes.length,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String header;
  final List<Malzeme> items;
  const _Section({required this.header, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grup başlığı
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Text(
            header,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),

        // Grup listesi
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final m = items[i];
            return ListTile(
              title: Text(m.ad),
              subtitle: Text(m.malzemeTur),
              leading: const Icon(Icons.restaurant_outlined),
              onTap: () {
                // ileride: detaya git / seçim yap vs.
              },
            );
          },
        ),
      ],
    );
  }
}

class _AlphabetRail extends StatelessWidget {
  final List<String> letters;
  final ValueChanged<String> onTap;
  const _AlphabetRail({required this.letters, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: SizedBox(
        width: 28,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: letters.map((l) {
            return InkWell(
              onTap: () => onTap(l),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(l, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
