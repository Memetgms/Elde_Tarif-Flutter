import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:elde_tarif/Providers/home_provider.dart';
import 'package:elde_tarif/apiservice.dart';
import 'package:elde_tarif/models/tarifonizleme.dart';
import 'package:elde_tarif/screens/TarifDetayPage.dart';
import 'homepage.dart';

class AppTheme {
  static const primary = Color(0xFF6366F1); // indigo-500
  static const primaryDark = Color(0xFF4F46E5); // indigo-600
  static const primaryLight = Color(0xFF818CF8); // indigo-400
  static const surfaceSoft = Color(0xFFF8FAFC); // slate-50
  static const border = Color(0xFFE2E8F0); // slate-200
  static const textMuted = Color(0xFF64748B); // slate-500
  static const accent = Color(0xFFEC4899); // pink-500
  static const success = Color(0xFF10B981); // emerald-500
}
// Sıralama seçenekleri
enum TarifSortOption {
  nameAsc,
  nameDesc,
}

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    this.initialKategoriId,
    this.initialSefId,
  });

  final int? initialKategoriId;
  final int? initialSefId;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchText = '';
  int? _selectedKategoriId;
  int? _selectedSefId;
  TarifSortOption _sortOption = TarifSortOption.nameAsc;
  bool _showFilters = false; // To toggle filter visibility

  final TextEditingController _searchController = TextEditingController();
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    // Ana sayfadan gelen ilk değerleri burada set ediyoruz
    _selectedKategoriId = widget.initialKategoriId;
    _selectedSefId = widget.initialSefId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TarifOnizleme> _applyFilters(HomeProvider provider) {
    // Tüm tarifler
    List<TarifOnizleme> sonuc = List.of(provider.tarifler);

    // 1) Arama metni
    final query = _searchText.trim().toLowerCase();
    if (query.isNotEmpty) {
      sonuc = sonuc
          .where((t) => t.baslik.toLowerCase().contains(query))
          .toList();
    }

    // 2) Kategori filtresi
    if (_selectedKategoriId != null) {
      sonuc = sonuc
          .where((t) => t.kategoriId == _selectedKategoriId)
          .toList();
    }

    // 3) Şef filtresi
    if (_selectedSefId != null) {
      sonuc = sonuc.where((t) => t.sefId == _selectedSefId).toList();
    }

    // 4) Sıralama
    switch (_sortOption) {
      case TarifSortOption.nameAsc:
        sonuc.sort((a, b) =>
            a.baslik.toLowerCase().compareTo(b.baslik.toLowerCase()));
        break;
      case TarifSortOption.nameDesc:
        sonuc.sort((a, b) =>
            b.baslik.toLowerCase().compareTo(a.baslik.toLowerCase()));
        break;
    }

    return sonuc;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        final filteredTarifler = _applyFilters(provider);

        return Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: false,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFFAFBFF),
                  Colors.white,
                  AppTheme.surfaceSoft,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
            child: Column(
              children: [
                // Modern AppBar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceSoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                              color: Colors.black87,
                              onPressed: () => Navigator.of(context).pop(),
                              padding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceSoft,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Tarif ara...',
                                  hintStyle: TextStyle(
                                    color: AppTheme.textMuted.withOpacity(0.7),
                                    fontSize: 16,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: AppTheme.primary,
                                    size: 24,
                                  ),
                                  suffixIcon: _searchText.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.clear_rounded,
                                            color: AppTheme.textMuted,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {
                                              _searchText = '';
                                            });
                                          },
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchText = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Body Content
                Expanded(
                  child: provider.yukleniyor && !provider.verilerYuklendi
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Tarifler yükleniyor...',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : provider.hata != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.error_outline_rounded,
                                        size: 64,
                                        color: Colors.red.shade400,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Bir Hata Oluştu',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      provider.hata ?? 'Bilinmeyen hata',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ===== Compact Filtre & Sıralama Alanı =====
                                Container(
                                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary.withOpacity(0.06),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Üst satır: sonuç sayısı + sıralama + filter toggle
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      AppTheme.primary,
                                                      AppTheme.primaryLight,
                                                    ],
                                                  ),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.restaurant_menu_rounded,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${filteredTarifler.length}',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.primary,
                                                    ),
                                                  ),
                                                  Text(
                                                    'tarif',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: AppTheme.textMuted,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: AppTheme.surfaceSoft,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: AppTheme.border,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                  child: DropdownButton<TarifSortOption>(
                                                    value: _sortOption,
                                                    icon: Icon(
                                                      Icons.sort_rounded,
                                                      color: AppTheme.primary,
                                                      size: 18,
                                                    ),
                                                    isDense: true,
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    onChanged: (v) {
                                                      if (v == null) return;
                                                      setState(() => _sortOption = v);
                                                    },
                                                    items: [
                                                      DropdownMenuItem(
                                                        value: TarifSortOption.nameAsc,
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.arrow_upward_rounded,
                                                              size: 16,
                                                              color: AppTheme.textMuted,
                                                            ),
                                                            const SizedBox(width: 6),
                                                            const Text(
                                                              'A-Z',
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: TarifSortOption.nameDesc,
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.arrow_downward_rounded,
                                                              size: 16,
                                                              color: AppTheme.textMuted,
                                                            ),
                                                            const SizedBox(width: 6),
                                                            const Text(
                                                              'Z-A',
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                icon: Icon(
                                                  _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                                                  color: AppTheme.primary,
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _showFilters = !_showFilters;
                                                  });
                                                },
                                                padding: const EdgeInsets.all(8),
                                                constraints: const BoxConstraints(),
                                                style: IconButton.styleFrom(
                                                  backgroundColor: AppTheme.surfaceSoft,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Collapsible filter section
                                      if (_showFilters) ...[
                                        // Kategori filtresi
                                        if (provider.kategoriler.isNotEmpty) ...[
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.category_rounded,
                                                size: 16,
                                                color: AppTheme.primary,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'KATEGORİ',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.textMuted,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            height: 36,
                                            child: ListView(
                                              scrollDirection: Axis.horizontal,
                                              children: [
                                                _buildCompactChip(
                                                  label: 'Tümü',
                                                  selected: _selectedKategoriId == null,
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedKategoriId = null;
                                                    });
                                                  },
                                                ),
                                                const SizedBox(width: 8),
                                                ...provider.kategoriler.map((k) {
                                                  final selected = _selectedKategoriId == k.id;
                                                  return Padding(
                                                    padding: const EdgeInsets.only(right: 8),
                                                    child: _buildCompactChip(
                                                      label: k.ad,
                                                      selected: selected,
                                                      onTap: () {
                                                        setState(() {
                                                          _selectedKategoriId = selected ? null : k.id;
                                                        });
                                                      },
                                                    ),
                                                  );
                                                }).toList(),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                        ],

                                        // Şef filtresi
                                        if (provider.sefler.isNotEmpty) ...[
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person_rounded,
                                                size: 16,
                                                color: AppTheme.primary,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'ŞEF',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.textMuted,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            height: 36,
                                            child: ListView(
                                              scrollDirection: Axis.horizontal,
                                              children: [
                                                _buildCompactChip(
                                                  label: 'Tümü',
                                                  selected: _selectedSefId == null,
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedSefId = null;
                                                    });
                                                  },
                                                ),
                                                const SizedBox(width: 8),
                                                ...provider.sefler.map((s) {
                                                  final selected = _selectedSefId == s.id;
                                                  return Padding(
                                                    padding: const EdgeInsets.only(right: 8),
                                                    child: _buildCompactChip(
                                                      label: s.ad,
                                                      selected: selected,
                                                      onTap: () {
                                                        setState(() {
                                                          _selectedSefId = selected ? null : s.id;
                                                        });
                                                      },
                                                    ),
                                                  );
                                                }).toList(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // ===== Tarif listesi =====
                                Expanded(
                                  child: filteredTarifler.isEmpty
                                      ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(32),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(24),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.surfaceSoft,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.search_off_rounded,
                                                    size: 64,
                                                    color: AppTheme.textMuted.withOpacity(0.5),
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                Text(
                                                  'Tarif Bulunamadı',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'Arama kriterlerinize uygun tarif bulunamadı.\nFarklı filtrelerle tekrar deneyin.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: AppTheme.textMuted,
                                                    fontSize: 15,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : GridView.builder(
                                          physics: const BouncingScrollPhysics(),
                                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 16,
                                            crossAxisSpacing: 16,
                                            childAspectRatio: 0.72,
                                          ),
                                          itemCount: filteredTarifler.length,
                                          itemBuilder: (context, index) {
                                            final tarif = filteredTarifler[index];
                                            return _buildTarifCard(context, tarif, _api);
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
      },
    );
  }
}

  // Modern chip builder metodu
  Widget _buildModernChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : AppTheme.surfaceSoft,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: selected ? Colors.transparent : AppTheme.border,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Compact chip builder for filters
  Widget _buildCompactChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : AppTheme.surfaceSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : AppTheme.border,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Modern tarif kartı builder metodu
  Widget _buildTarifCard(BuildContext context, TarifOnizleme tarif, ApiService api) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TarifDetayPage(tarifId: tarif.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      api.getImageUrl(tarif.kapakFotoUrl),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppTheme.surfaceSoft,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.surfaceSoft, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          Icons.restaurant_menu_rounded,
                          size: 50,
                          color: AppTheme.textMuted.withOpacity(0.5),
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tarif.baslik,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

