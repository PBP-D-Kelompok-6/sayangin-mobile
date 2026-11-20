// Model data Modul Dampak, dibuat dari JSON API /dampak/api/... (impact/api.py di repo web)

// Jenis aksi tantangan; kodenya sama dengan Challenge.KIND_CHOICES di models.py web
const Map<String, String> challengeKinds = {
  'terjual': 'Barang preloved terjual',
  'dibeli': 'Membeli barang preloved',
  'donasi': 'Donasi diterima lembaga',
  'lemari': 'Barang dicatat di lemari',
};

class Challenge {
  final int id;
  final String title;
  final String kind;
  final String kindLabel;
  final int target;
  final DateTime startDate;
  final DateTime endDate;
  final bool isRunning;
  final int done;
  final int percent;
  final int remaining;

  Challenge({
    required this.id,
    required this.title,
    required this.kind,
    required this.kindLabel,
    required this.target,
    required this.startDate,
    required this.endDate,
    required this.isRunning,
    required this.done,
    required this.percent,
    required this.remaining,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
        id: json['id'],
        title: json['title'],
        kind: json['kind'],
        kindLabel: json['kind_label'],
        target: json['target'],
        startDate: DateTime.parse(json['start_date']),
        endDate: DateTime.parse(json['end_date']),
        isRunning: json['is_running'],
        done: json['done'],
        percent: json['percent'],
        remaining: json['remaining'],
      );
}

// Kartu angka di dashboard, mis. "Donasi diterima: 3 (+20 poin/aksi)"
class Stat {
  final String key;
  final String label;
  final int value;
  final int points;

  Stat({required this.key, required this.label, required this.value, required this.points});

  factory Stat.fromJson(Map<String, dynamic> json) =>
      Stat(key: json['key'], label: json['label'], value: json['value'], points: json['points']);
}

class ImpactBadge {
  final String name;
  final String rule;
  final String image; // URL lengkap, langsung dipakai Image.network
  final bool earned;
  final int percent;

  ImpactBadge({required this.name, required this.rule, required this.image, required this.earned, required this.percent});

  factory ImpactBadge.fromJson(Map<String, dynamic> json) => ImpactBadge(
        name: json['name'],
        rule: json['rule'],
        image: json['image'],
        earned: json['earned'],
        percent: json['percent'],
      );
}

// Satu baris papan peringkat; userId & isMe kosong kalau dibuka sebagai tamu
class LeaderRow {
  final int rank;
  final String username;
  final int points;
  final bool isMe;

  LeaderRow({required this.rank, required this.username, required this.points, this.isMe = false});

  factory LeaderRow.fromJson(Map<String, dynamic> json) => LeaderRow(
        rank: json['rank'],
        username: json['username'],
        points: json['points'],
        isMe: json['is_me'] ?? false,
      );
}

class Leaderboard {
  final String period;
  final List<LeaderRow> rows;
  final LeaderRow? myRank;
  final List<MapEntry<String, int>> pointsInfo; // cara dapat poin, mis. ("Donasi diterima", 20)

  Leaderboard({required this.period, required this.rows, this.myRank, required this.pointsInfo});

  factory Leaderboard.fromJson(Map<String, dynamic> json) => Leaderboard(
        period: json['period'],
        rows: [for (final row in json['leaderboard']) LeaderRow.fromJson(row)],
        myRank: json['my_rank'] == null ? null : LeaderRow.fromJson(json['my_rank']),
        pointsInfo: [for (final info in json['points_info']) MapEntry(info['label'] as String, info['points'] as int)],
      );
}

class Dashboard {
  final String period;
  final int points;
  final List<Stat> stats;
  final List<ImpactBadge> badges;
  final int earnedCount;
  final List<LeaderRow> leaderboard; // 5 teratas
  final LeaderRow? myRank;
  final Challenge? nextStep;
  final List<Challenge> challenges; // maksimal 4
  final int challengeTotal;

  Dashboard({
    required this.period,
    required this.points,
    required this.stats,
    required this.badges,
    required this.earnedCount,
    required this.leaderboard,
    this.myRank,
    this.nextStep,
    required this.challenges,
    required this.challengeTotal,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) => Dashboard(
        period: json['period'],
        points: json['points'],
        stats: [for (final stat in json['stats']) Stat.fromJson(stat)],
        badges: [for (final badge in json['badges']) ImpactBadge.fromJson(badge)],
        earnedCount: json['earned_count'],
        leaderboard: [for (final row in json['leaderboard']) LeaderRow.fromJson(row)],
        myRank: json['my_rank'] == null ? null : LeaderRow.fromJson(json['my_rank']),
        nextStep: json['next_step'] == null ? null : Challenge.fromJson(json['next_step']),
        challenges: [for (final c in json['challenges']) Challenge.fromJson(c)],
        challengeTotal: json['challenge_total'],
      );
}
