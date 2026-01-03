import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:elde_tarif/apiservice/malzeme_api.dart';
import 'package:elde_tarif/models/malzeme.dart';

/// Malzeme verilerini yöneten sınıf.
/// Tüm listeyi API'den çeker, arama ve tür filtrelerini uygular.
class MalzemeProvider extends ChangeNotifier {
  final MalzemeApi _malzemeApi;

  MalzemeProvider() : _malzemeApi = MalzemeApi();

  // --- DURUM (STATE) ALANLARI ---
  bool yukleniyor = false; // veriler yükleniyor mu?
  String? hata;            // hata mesajı (varsa)
  List<Malzeme> _tumMalzemeler = []; // API'den gelen ham veri

  String _aramaMetni = '';          // arama kutusu değeri
  final Set<String> _seciliTurler = {}; // seçilen tür(ler)

  // Veriler yüklenmiş mi?
  bool get verilerYuklendi => _tumMalzemeler.isNotEmpty;

  // --- DIŞARIYA OKUNABİLEN ALANLAR ---
  String get aramaMetni => _aramaMetni;
  Set<String> get seciliTurler => _seciliTurler;

  /// Tüm türleri (örneğin "Et", "Sebze", "Bakliyat") alfabetik döndürür
  List<String> get tumTurler {
    final set = _tumMalzemeler.map((m) => m.malzemeTur.trim()).toSet();
    final liste = set.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return liste;
  }

  /// Filtreli malzeme listesi
  /// - Arama metnine ve tür seçimine göre filtrelenir
  /// - İsme göre sıralanır
  List<Malzeme> get filtreliListe {
    Iterable<Malzeme> q = _tumMalzemeler;

    // Tür filtresi
    if (_seciliTurler.isNotEmpty) {
      q = q.where((m) => _seciliTurler.contains(m.malzemeTur));
    }

    // Arama filtresi
    if (_aramaMetni.trim().isNotEmpty) {
      final aranacak = _normalizeEt(_aramaMetni);
      q = q.where((m) => _normalizeEt(m.ad).contains(aranacak));
    }

    final liste = q.toList()
      ..sort((a, b) => a.ad.toLowerCase().compareTo(b.ad.toLowerCase()));
    return liste;
  }

  /// Filtrelenmiş listeyi ilk harfe göre gruplar (örnek: "A", "B", "Ç"...)
  Map<String, List<Malzeme>> get harfeGoreGruplar {
    final gruplar = groupBy<Malzeme, String>(filtreliListe, (m) {
      final ilk = (m.ad.isNotEmpty ? m.ad[0] : '#').toUpperCase();
      final harfMi = RegExp(r'[A-ZÇĞİÖŞÜ]').hasMatch(ilk);
      return harfMi ? ilk : '#';
    });
    return gruplar;
  }

  // --- EYLEMLER (METODLAR) ---

  /// API'den malzeme listesini çeker
  Future<void> veriyiYukle() async {
    // Eğer veriler zaten yüklendiyse tekrar yükleme
    if (verilerYuklendi && !yukleniyor) {
      return;
    }

    yukleniyor = true;
    hata = null;
    notifyListeners();

    try {
      _tumMalzemeler = await _malzemeApi.fetchMalzemeler();
    } catch (e) {
      hata = e.toString();
    } finally {
      yukleniyor = false;
      notifyListeners();
    }
  }

  /// Yenile butonu için - zorunlu yenileme
  Future<void> yenile() async {
    yukleniyor = true;
    hata = null;
    notifyListeners();

    try {
      _tumMalzemeler = await _malzemeApi.fetchMalzemeler();
    } catch (e) {
      hata = e.toString();
    } finally {
      yukleniyor = false;
      notifyListeners();
    }
  }

  /// Arama metnini değiştirir
  void aramaMetniniAyarla(String yeniMetin) {
    _aramaMetni = yeniMetin;
    notifyListeners();
  }

  /// Çoklu seçim yerine TEK seçimli tür ayarı
  /// - Gönderilen tür zaten seçiliyse seçim kaldırılır
  /// - Farklı bir tür gönderilirse önce temizlik, sonra o tür seçilir
  void turTekSec(String? tur) {
    _seciliTurler.clear();
    if (tur != null && tur.isNotEmpty) {
      _seciliTurler.add(tur);
    }
    notifyListeners();
  }

  /// Eski çoklu seçim tarzı istersen bu da kullanılabilir (şu an gerek yok)
  void turSeciminiDegistir(String tur) {
    _seciliTurler.contains(tur)
        ? _seciliTurler.remove(tur)
        : _seciliTurler.add(tur);
    notifyListeners();
  }

  // --- YARDIMCI METODLAR ---

  /// Türkçe-insensitif string normalize edici (ş→s, ı→i vb.)
  static String _normalizeEt(String s) => s
      .toLowerCase()
      .replaceAll('ı', 'i')
      .replaceAll('İ', 'i')
      .replaceAll('ş', 's')
      .replaceAll('Ş', 's')
      .replaceAll('ğ', 'g')
      .replaceAll('Ğ', 'g')
      .replaceAll('ç', 'c')
      .replaceAll('Ç', 'c')
      .replaceAll('ö', 'o')
      .replaceAll('Ö', 'o')
      .replaceAll('ü', 'u')
      .replaceAll('Ü', 'u')
      .trim();
}
