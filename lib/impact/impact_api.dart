// Pemanggilan API Modul Dampak (impact/api.py di repo web)
// Login memakai session cookie dari CookieRequest (pbp_django_auth), sama untuk semua modul
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'models.dart';

// Alamat situs Django; bisa diganti saat run, mis.
// flutter run --dart-define=BASE_URL=http://10.0.2.2:8000
const String baseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'https://muhammad-ghazi51-sayang-in.pws.cs.ui.ac.id',
);

// Error dari API, mis. belum login (403) atau validasi form (400)
class ImpactApiException implements Exception {
  final String message;
  final Map<String, dynamic> fieldErrors; // {"target": ["Target minimal 1."]}

  ImpactApiException(this.message, [this.fieldErrors = const {}]);

  @override
  String toString() => message;
}

class ImpactApi {
  final CookieRequest request;

  ImpactApi(this.request);

  Future<Dashboard> dashboard(String period) async {
    final json = await request.get('$baseUrl/dampak/api/dashboard/?periode=$period');
    _throwIfError(json);
    return Dashboard.fromJson(json);
  }

  // tamu boleh membuka; nama pengguna lain disamarkan oleh server
  Future<Leaderboard> leaderboard(String period) async {
    final json = await request.get('$baseUrl/dampak/api/peringkat/?periode=$period');
    _throwIfError(json);
    return Leaderboard.fromJson(json);
  }

  // jenis & status: "" = semua (sama dengan filter di web)
  Future<List<Challenge>> challenges({String kind = '', String status = ''}) async {
    final json = await request.get('$baseUrl/dampak/api/tantangan/?jenis=$kind&status=$status');
    _throwIfError(json);
    return [for (final row in json) Challenge.fromJson(row)];
  }

  Future<Challenge> createChallenge(Map<String, dynamic> data) async {
    return Challenge.fromJson(await _send('POST', '$baseUrl/dampak/api/tantangan/', data));
  }

  Future<Challenge> updateChallenge(int id, Map<String, dynamic> data) async {
    return Challenge.fromJson(await _send('PATCH', '$baseUrl/dampak/api/tantangan/$id/', data));
  }

  Future<void> deleteChallenge(int id) async {
    await _send('DELETE', '$baseUrl/dampak/api/tantangan/$id/');
  }

  // CookieRequest hanya punya get/post, jadi PATCH & DELETE dikirim lewat http
  // dengan header cookie yang sama (session login ikut terkirim)
  Future<dynamic> _send(String method, String url, [Map<String, dynamic>? data]) async {
    final req = http.Request(method, Uri.parse(url))
      ..headers.addAll(request.headers)
      ..headers['Content-Type'] = 'application/json; charset=UTF-8';
    if (data != null) req.body = jsonEncode(data);
    final response = await http.Response.fromStream(await req.send());
    final json = response.body.isEmpty ? null : jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode >= 400) {
      if (json is Map<String, dynamic> && !json.containsKey('detail')) {
        throw ImpactApiException('Periksa kembali isian tantangan.', json);
      }
      _throwIfError(json);
      throw ImpactApiException('Terjadi kesalahan (${response.statusCode}).');
    }
    return json;
  }

  // DRF mengirim {"detail": "..."} untuk 403/404
  void _throwIfError(dynamic json) {
    if (json is Map && json.containsKey('detail')) {
      throw ImpactApiException(json['detail'].toString());
    }
  }
}
