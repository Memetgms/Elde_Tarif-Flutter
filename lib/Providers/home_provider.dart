import 'package:elde_tarif/apiservice/chef_api.dart';
import 'package:elde_tarif/apiservice/tarif_api.dart';
import 'package:elde_tarif/apiservice/malzeme_api.dart';
import 'package:elde_tarif/models/kategori.dart';
import 'package:elde_tarif/models/sef.dart';
import 'package:elde_tarif/models/tarifonizleme.dart';
import 'package:flutter/foundation.dart';

class HomeProvider extends ChangeNotifier {
  final ChefApi _chefApi;
  final TarifApi _tarifApi;
  final MalzemeApi _malzemeApi;

  HomeProvider() 
      : _chefApi = ChefApi(),
        _tarifApi = TarifApi(),
        _malzemeApi = MalzemeApi();

  bool _yukleniyor = false;
  String? _hata;
  
  List<Sef> _sefler = [];
  List<Kategori> _kategoriler = [];
  List<TarifOnizleme> _tarifler = [];
  List<TarifOnizleme> _sanaOzelOneriler = [];

  bool get yukleniyor => _yukleniyor;
  String? get hata => _hata;
  List<Sef> get sefler => _sefler;
  List<Kategori> get kategoriler => _kategoriler;
  List<TarifOnizleme> get tarifler => _tarifler;
  List<TarifOnizleme> get sanaOzelOneriler => _sanaOzelOneriler;

  // Veriler yüklenmiş mi?
  bool get verilerYuklendi => _sefler.isNotEmpty || _kategoriler.isNotEmpty || _tarifler.isNotEmpty;

  Future<void> verileriYukle() async {
    // Eğer veriler zaten yüklendiyse tekrar yükleme
    if (verilerYuklendi && !yukleniyor) {
      return;
    }

    try {
      _yukleniyor = true;
      _hata = null;
      notifyListeners();

      final results = await Future.wait([
        _chefApi.fetchSefler(),
        _malzemeApi.fetchKategoriler(),
        _tarifApi.fetchTarifOnizleme(),
        _tarifApi.fetchHomeRecommendations(count: 5),
      ]);

      _sefler = results[0] as List<Sef>;
      _kategoriler = results[1] as List<Kategori>;
      _tarifler = results[2] as List<TarifOnizleme>;
      _sanaOzelOneriler = results[3] as List<TarifOnizleme>;
      _yukleniyor = false;
      _hata = null;
      notifyListeners();
    } catch (e) {
      _hata = e.toString();
      _yukleniyor = false;
      notifyListeners();
    }
  }

  // Yenile butonu için - zorunlu yenileme
  Future<void> yenile() async {
    _yukleniyor = true;
    _hata = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _chefApi.fetchSefler(),
        _malzemeApi.fetchKategoriler(),
        _tarifApi.fetchTarifOnizleme(),
        _tarifApi.fetchHomeRecommendations(count: 5),
      ]);

      _sefler = results[0] as List<Sef>;
      _kategoriler = results[1] as List<Kategori>;
      _tarifler = results[2] as List<TarifOnizleme>;
      _sanaOzelOneriler = results[3] as List<TarifOnizleme>;
      _yukleniyor = false;
      _hata = null;
      notifyListeners();
    } catch (e) {
      _hata = e.toString();
      _yukleniyor = false;
      notifyListeners();
    }
  }

  void temizle() {
    _sefler = [];
    _kategoriler = [];
    _tarifler = [];
    _sanaOzelOneriler = [];
    _hata = null;
    _yukleniyor = false;
    notifyListeners();
  }
}
