import 'package:elde_tarif/apiservice.dart';
import 'package:elde_tarif/models/sef_detay.dart';
import 'package:flutter/foundation.dart';

class SefDetayProvider extends ChangeNotifier {
  final ApiService api;
  final int sefId;

  SefDetayProvider(this.api, this.sefId);

  bool _yukleniyor = false;
  String? _hata;
  SefDetay? _sefDetay;
  String? _seciliKategori;

  bool get yukleniyor => _yukleniyor;
  String? get hata => _hata;
  SefDetay? get sefDetay => _sefDetay;
  String? get seciliKategori => _seciliKategori;

  List<SefTarif> get filtrelenmisTarifler {
    if (_sefDetay == null) return [];
    if (_seciliKategori == null || _seciliKategori == 'Tüm Tarifler') {
      return _sefDetay!.tarifler;
    }
    return _sefDetay!.tarifler.where((t) => t.kategoriAdi == _seciliKategori).toList();
  }

  List<String> get tumKategoriler {
    if (_sefDetay == null) return [];
    final kategoriler = _sefDetay!.tarifler.map((t) => t.kategoriAdi).toSet().toList();
    kategoriler.sort();
    return ['Tüm Tarifler', ...kategoriler];
  }

  void kategoriFiltrele(String? kategori) {
    _seciliKategori = kategori;
    notifyListeners();
  }

  Future<void> veriyiYukle() async {
    if (_yukleniyor) return;

    try {
      _yukleniyor = true;
      _hata = null;
      notifyListeners();

      _sefDetay = await api.getSefDetay(sefId);
      _yukleniyor = false;
      _hata = null;
      notifyListeners();
    } catch (e) {
      _hata = e.toString();
      _yukleniyor = false;
      notifyListeners();
    }
  }

  Future<void> yenile() async {
    _yukleniyor = true;
    _hata = null;
    notifyListeners();

    try {
      _sefDetay = await api.getSefDetay(sefId);
      _yukleniyor = false;
      _hata = null;
      notifyListeners();
    } catch (e) {
      _hata = e.toString();
      _yukleniyor = false;
      notifyListeners();
    }
  }
}

