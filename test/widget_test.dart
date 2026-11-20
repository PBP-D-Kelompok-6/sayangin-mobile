import 'package:flutter_test/flutter_test.dart';
import 'package:sayangin_mobile/impact/models.dart';

// Memastikan JSON dari /dampak/api/... (impact/api.py di repo web) bisa dibaca model Dampak.
// Bentuk JSON di sini disalin dari respons asli API.
const challengeJson = {
  'id': 1, 'title': 'Donasi 3 barang', 'kind': 'donasi', 'kind_label': 'Donasi diterima lembaga',
  'target': 3, 'start_date': '2026-11-16', 'end_date': '2026-11-23', 'is_running': true,
  'done': 2, 'percent': 67, 'remaining': 1,
};

const pointsInfoJson = [
  {'label': 'Barang terjual', 'points': 10},
  {'label': 'Beli preloved', 'points': 5},
  {'label': 'Donasi diterima', 'points': 20},
  {'label': 'Barang di lemari', 'points': 2},
];

void main() {
  test('Challenge.fromJson', () {
    final challenge = Challenge.fromJson(challengeJson);
    expect(challenge.remaining, 1);
    expect(challenge.endDate, DateTime(2026, 11, 23));
  });

  test('Dashboard.fromJson', () {
    final dashboard = Dashboard.fromJson({
      'period': 'bulan',
      'points': 4,
      'stats': [
        {'key': 'lemari', 'label': 'Barang di lemari', 'value': 2, 'points': 2},
      ],
      'badges': [
        {'name': 'Sayangin Starter', 'rule': 'Catat 1 barang di lemari',
         'image': 'http://localhost/static/img/lencana-lemari.jpg', 'earned': true, 'percent': 100},
      ],
      'earned_count': 1,
      'leaderboard': [
        {'rank': 1, 'user_id': 7, 'username': 'nadia.r', 'points': 4, 'is_me': true},
      ],
      'my_rank': {'rank': 1, 'user_id': 7, 'username': 'nadia.r', 'points': 4},
      'next_step': challengeJson,
      'challenges': [challengeJson],
      'challenge_total': 1,
    });
    expect(dashboard.points, 4);
    expect(dashboard.badges.single.earned, isTrue);
    expect(dashboard.leaderboard.single.isMe, isTrue);
    expect(dashboard.myRank?.rank, 1);
    expect(dashboard.nextStep?.title, 'Donasi 3 barang');
    expect(dashboard.challenges, hasLength(1));
  });

  test('Dashboard.fromJson tanpa tantangan', () {
    final dashboard = Dashboard.fromJson({
      'period': 'semua', 'points': 0, 'stats': [], 'badges': [], 'earned_count': 0,
      'leaderboard': [], 'my_rank': null, 'next_step': null, 'challenges': [], 'challenge_total': 0,
    });
    expect(dashboard.nextStep, isNull);
    expect(dashboard.myRank, isNull);
  });

  test('Leaderboard.fromJson sebagai tamu', () {
    // tamu: nama disamarkan, tanpa is_me dan my_rank
    final leaderboard = Leaderboard.fromJson({
      'period': 'bulan',
      'leaderboard': [
        {'rank': 1, 'username': 'n***r', 'points': 4},
      ],
      'my_rank': null,
      'points_info': pointsInfoJson,
    });
    expect(leaderboard.rows.single.isMe, isFalse);
    expect(leaderboard.myRank, isNull);
    expect(leaderboard.pointsInfo.first, isA<MapEntry<String, int>>());
    expect(leaderboard.pointsInfo.first.value, 10);
  });

  test('Leaderboard.fromJson setelah login', () {
    final leaderboard = Leaderboard.fromJson({
      'period': 'semua',
      'leaderboard': [
        {'rank': 1, 'user_id': 7, 'username': 'nadia.r', 'points': 4, 'is_me': true},
      ],
      'my_rank': {'rank': 1, 'user_id': 7, 'username': 'nadia.r', 'points': 4},
      'points_info': pointsInfoJson,
    });
    expect(leaderboard.rows.single.isMe, isTrue);
    expect(leaderboard.myRank?.username, 'nadia.r');
  });
}
