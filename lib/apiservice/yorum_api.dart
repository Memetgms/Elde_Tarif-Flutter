import 'dart:convert';
import 'package:elde_tarif/apiservice/api_client.dart';
import 'package:elde_tarif/models/yorum.dart';

/// Yorum ile ilgili API işlemleri
class YorumApi {
  final ApiClient _client;

  YorumApi(this._client);

  /// Tarifin yorumlarını listele
  /// GET: /api/yorum/tarif/{tarifId}?skip=0&take=20
  Future<List<YorumListItem>> getYorumlarByTarif(
    int tarifId, {
    int skip = 0,
    int take = 20,
  }) async {
    final response = await _client.get(
      '/api/yorum/tarif/$tarifId?skip=$skip&take=$take',
    );
    final List data = jsonDecode(response.body) as List;
    return data
        .map((e) => YorumListItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Yorum ekle (giriş zorunlu)
  /// POST: /api/yorum
  Future<YorumListItem> createYorum(YorumCreateDto dto) async {
    final response = await _client.post(
      '/api/yorum',
      body: dto.toJson(),
      requireAuth: true,
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return YorumListItem.fromJson(data);
  }

  /// Yorum güncelle (giriş zorunlu)
  /// PUT: /api/yorum/{id}
  Future<YorumListItem> updateYorum(int id, YorumUpdateDto dto) async {
    final response = await _client.put(
      '/api/yorum/$id',
      body: dto.toJson(),
      requireAuth: true,
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return YorumListItem.fromJson(data);
  }

  /// Yorum sil (giriş zorunlu)
  /// DELETE: /api/yorum/{id}
  Future<void> deleteYorum(int id) async {
    await _client.delete(
      '/api/yorum/$id',
      requireAuth: true,
    );
  }
}


