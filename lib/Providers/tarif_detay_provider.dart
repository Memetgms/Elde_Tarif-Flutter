import 'package:elde_tarif/apiservice/tarif_api.dart';
import 'package:elde_tarif/apiservice/yorum_api.dart';
import 'package:elde_tarif/models/tarif_detay.dart';
import 'package:elde_tarif/models/yorum.dart';
import 'package:flutter/foundation.dart';

class TarifDetayProvider extends ChangeNotifier {
  final TarifApi _tarifApi;
  final YorumApi _yorumApi;

  TarifDetayProvider() 
      : _tarifApi = TarifApi(),
        _yorumApi = YorumApi();

  bool yukleniyor = false;
  String? hata;
  TarifDetay? detay;

  // Yorumlar için state
  List<YorumListItem> yorumlar = [];
  bool yorumlarYukleniyor = false;
  String? yorumlarHata;
  int _currentTarifId = 0;

  Future<void> yukle(int id) async {
    try {
      yukleniyor = true;
      hata = null;
      _currentTarifId = id;
      notifyListeners();

      // 1) Detayı getir
      detay = await _tarifApi.getTarifDetay(id);

      // 2) View kaydı (sessiz) - başarısız olursa UI bozmasın
      try {
        await _tarifApi.addView(id);
      } catch (_) {
        // ignore
      }

      // 3) Yorumları yükle
      await yorumlariYukle();

    } catch (e) {
      hata = e.toString();
    } finally {
      yukleniyor = false;
      notifyListeners();
    }
  }

  /// Yorumları yükle
  Future<void> yorumlariYukle({int skip = 0, int take = 20}) async {
    if (_currentTarifId == 0) return;

    try {
      yorumlarYukleniyor = true;
      yorumlarHata = null;
      notifyListeners();

      final yeniYorumlar = await _yorumApi.getYorumlarByTarif(
        _currentTarifId,
        skip: skip,
        take: take,
      );

      if (skip == 0) {
        yorumlar = yeniYorumlar;
      } else {
        yorumlar.addAll(yeniYorumlar);
      }
    } catch (e) {
      yorumlarHata = e.toString();
    } finally {
      yorumlarYukleniyor = false;
      notifyListeners();
    }
  }

  /// Yorum ekle
  Future<bool> yorumEkle(String? icerik, int? puan) async {
    if (_currentTarifId == 0) return false;

    try {
      final dto = YorumCreateDto(
        tarifId: _currentTarifId,
        icerik: icerik?.trim().isEmpty == true ? null : icerik?.trim(),
        puan: puan,
      );

      await _yorumApi.createYorum(dto);
      
      // Yorumları baştan yükle
      await yorumlariYukle(skip: 0, take: 20);
      
      // Detayı yeniden yükle (yorum sayısı güncellensin)
      await yukle(_currentTarifId);
      
      return true;
    } catch (e) {
      yorumlarHata = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Yorum güncelle
  Future<bool> yorumGuncelle(int yorumId, String? icerik, int? puan) async {
    try {
      final dto = YorumUpdateDto(
        icerik: icerik?.trim().isEmpty == true ? null : icerik?.trim(),
        puan: puan,
      );

      await _yorumApi.updateYorum(yorumId, dto);
      
      // Yorumları baştan yükle
      await yorumlariYukle(skip: 0, take: 20);
      
      // Detayı yeniden yükle
      await yukle(_currentTarifId);
      
      return true;
    } catch (e) {
      yorumlarHata = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Yorum sil
  Future<bool> yorumSil(int yorumId) async {
    try {
      await _yorumApi.deleteYorum(yorumId);
      
      // Yorumları listeden kaldır
      yorumlar.removeWhere((y) => y.id == yorumId);
      
      // Detayı yeniden yükle
      await yukle(_currentTarifId);
      
      notifyListeners();
      return true;
    } catch (e) {
      yorumlarHata = e.toString();
      notifyListeners();
      return false;
    }
  }

  void temizle() {
    detay = null;
    hata = null;
    yukleniyor = false;
    yorumlar = [];
    yorumlarYukleniyor = false;
    yorumlarHata = null;
    _currentTarifId = 0;
    notifyListeners();
  }
}
