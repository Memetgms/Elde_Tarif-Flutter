import 'package:elde_tarif/apiservice.dart';
import 'package:elde_tarif/models/tarif_detay.dart';
import 'package:flutter/foundation.dart';

class TarifDetayProvider extends ChangeNotifier {
  final ApiService api;
  TarifDetayProvider(this.api);

  bool yukleniyor = false;
  String? hata;
  TarifDetay? detay;

  Future<void> yukle(int id) async {
    try {
      yukleniyor = true;
      hata = null;
      notifyListeners();

      detay = await api.getTarifDetay(id);

    } catch (e) {
      hata = e.toString();
    } finally {
      yukleniyor = false;
      notifyListeners();
    }
  }
  void temizle() {
    detay = null;
    hata = null;
    yukleniyor = false;
    notifyListeners();
  }


}