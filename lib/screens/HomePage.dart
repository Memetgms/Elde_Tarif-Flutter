import 'package:elde_tarif/screens/MalzemePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:elde_tarif/apiservice.dart';
import 'package:elde_tarif/models/sef.dart';
import 'package:elde_tarif/models/kategori.dart';
import 'package:elde_tarif/models/tarifonizleme.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const _HomeTab(),
    const MalzemelerPage(),
    const _AiTab(),
    const _GunlukTab(),
    const _ProfilTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        enableFeedback: false,
        selectedItemColor: Colors.black,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen_outlined),
            label: 'Malzeme',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            label: 'Günlük',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final ApiService _api = ApiService();
  List<Sef> _sefler = [];
  List<Kategori> _kategoriler = [];
  List<TarifOnizleme> _tarifler = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _loading = true);
      
      final results = await Future.wait([
        _api.fetchSefler(),
        _api.fetchKategoriler(),
        _api.fetchTarifOnizleme(),
      ]);
      
      setState(() {
        _sefler = results[0] as List<Sef>;
        _kategoriler = results[1] as List<Kategori>;
        _tarifler = results[2] as List<TarifOnizleme>;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hata: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        color: Colors.white,
        backgroundColor: Colors.black,
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ======= ÜST HEADER: Logo + Arama Pill =======
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // LOGO
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 44,
                          maxWidth: 56,
                        ),
                        child: Image.asset(
                          'assets/images/yemek_logo.webp',
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ARAMA
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SearchPage()),
                            );
                          },
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: const [
                                Icon(Icons.search, size: 18, color: Colors.black45),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Tarif aramak için tıklayın',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.black54, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),


            // ======= ASIL İÇERİK =======
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.list(
                children: [
                  // Şefler
                  Text(
                    'Şefler',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: _sefler.isEmpty
                        ? const Text('Şef bulunamadı')
                        : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _sefler.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final sef = _sefler[index];
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(_api.getImageUrl(sef.fotoUrl)),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 32,
                              width: 100,
                              child: Text(
                                sef.ad,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Kategoriler
                  Text(
                    'Kategoriler',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: _kategoriler.isEmpty
                        ? const Text('Kategori bulunamadı')
                        : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _kategoriler.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final kategori = _kategoriler[index];
                        return Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _api.getImageUrl(kategori.kategoriUrl),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 80,
                              child: Text(
                                kategori.ad,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tarifler
                  Text(
                    'Sana Özel Tarifler',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _tarifler.isEmpty
                      ? const Text('Tarif bulunamadı')
                      : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _tarifler.length,
                    itemBuilder: (context, index) {
                      final tarif = _tarifler[index];
                      return InkWell(
                        onTap: () {
                          // Tarif detayına git
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _api.getImageUrl(tarif.kapakFotoUrl),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tarif.baslik,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Daha Fazla
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Daha Fazla Tarif'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}

class _AiTab extends StatelessWidget {
  const _AiTab();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('AI Sayfası')),
    );
  }
}

class _GunlukTab extends StatelessWidget {
  const _GunlukTab();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Günlük Sayfası')),
    );
  }
}

class _ProfilTab extends StatelessWidget {
  const _ProfilTab();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Profil Sayfası')),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarif Ara'),
      ),
      body: const Center(
        child: Text('Arama Sayfası\n(İçerik gelecek)'),
      ),
    );
  }
}
