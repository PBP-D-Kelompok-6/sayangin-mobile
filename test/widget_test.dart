import 'package:flutter_test/flutter_test.dart';
import 'package:sayangin_mobile/impact/models.dart';

// Memastikan JSON dari /dampak/api/tantangan/ bisa dibaca model Challenge
void main() {
  test('Challenge.fromJson', () {
    final challenge = Challenge.fromJson({
      'id': 1, 'title': 'Donasi 3 barang', 'kind': 'donasi', 'kind_label': 'Donasi diterima lembaga',
      'target': 3, 'start_date': '2026-11-16', 'end_date': '2026-11-23', 'is_running': true,
      'done': 2, 'percent': 67, 'remaining': 1,
    });
    expect(challenge.remaining, 1);
    expect(challenge.endDate, DateTime(2026, 11, 23));
  });
}
