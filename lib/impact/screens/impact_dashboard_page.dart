// Halaman utama Modul Dampak (/dampak/api/dashboard/): poin, angka, langkah berikutnya,
// tantangan, lencana, dan 5 besar peringkat. Halaman ini yang disambungkan ke navigasi aplikasi.
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../impact_api.dart';
import '../models.dart';
import '../widgets.dart';
import 'challenge_form_page.dart';
import 'challenge_list_page.dart';
import 'leaderboard_page.dart';

class ImpactDashboardPage extends StatefulWidget {
  const ImpactDashboardPage({super.key});

  @override
  State<ImpactDashboardPage> createState() => _ImpactDashboardPageState();
}

class _ImpactDashboardPageState extends State<ImpactDashboardPage> {
  String _period = 'bulan';
  late Future<Dashboard> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ImpactApi(context.read<CookieRequest>()).dashboard(_period);
  }

  void _reload() => setState(_load);

  // buka halaman lain, lalu muat ulang dashboard saat kembali (tantangan mungkin berubah)
  Future<void> _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dampak')),
      body: FutureBuilder<Dashboard>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // tamu & akun lembaga tidak punya dashboard; arahkan ke papan peringkat publik (sama seperti web)
            return ErrorView(
              error: context.read<CookieRequest>().loggedIn
                  ? snapshot.error!
                  : 'Masuk dengan akun personal untuk melihat dampakmu.',
              onRetry: _reload,
              action: TextButton(
                onPressed: () => _open(const LeaderboardPage()),
                child: const Text('Lihat papan peringkat'),
              ),
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Center(
                  child: PeriodToggle(
                    period: _period,
                    onChanged: (period) {
                      _period = period;
                      _reload();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _PointsCard(data),
                const SizedBox(height: 12),
                _StatsGrid(data.stats),
                SectionTitle('Langkah berikutnya'),
                if (data.nextStep != null)
                  ChallengeCard(challenge: data.nextStep!, onTap: () => _open(const ChallengeListPage()))
                else
                  _EmptyCard(
                    text: 'Belum ada tantangan berjalan. Buat tantangan untuk mulai mengumpulkan dampak.',
                    buttonText: 'Buat tantangan',
                    onPressed: () => _open(const ChallengeFormPage()),
                  ),
                SectionTitle(
                  'Tantangan kamu',
                  trailing: TextButton(
                    onPressed: () => _open(const ChallengeListPage()),
                    child: Text('Lihat semua (${data.challengeTotal})'),
                  ),
                ),
                if (data.challenges.isEmpty) const Text('Tidak ada tantangan yang sedang berjalan.'),
                for (final challenge in data.challenges)
                  ChallengeCard(challenge: challenge, onTap: () => _open(const ChallengeListPage())),
                SectionTitle('Lencana (${data.earnedCount}/${data.badges.length})'),
                _BadgeList(data.badges),
                SectionTitle(
                  'Papan peringkat',
                  trailing: TextButton(
                    onPressed: () => _open(LeaderboardPage(initialPeriod: _period)),
                    child: const Text('Lihat semua'),
                  ),
                ),
                if (data.leaderboard.isEmpty) const Text('Belum ada yang mengumpulkan poin di periode ini.'),
                for (final row in data.leaderboard) LeaderTile(row),
                if (data.myRank != null && data.myRank!.rank > data.leaderboard.length) ...[
                  const Divider(height: 24),
                  LeaderTile(LeaderRow(
                      rank: data.myRank!.rank, username: data.myRank!.username, points: data.myRank!.points, isMe: true)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  final Dashboard data;

  const _PointsCard(this.data);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const RadialGradient(
          center: Alignment(0.7, -0.8),
          radius: 1.2,
          colors: [Color(0x997A1E2A), ImpactColors.night],
        ),
        color: ImpactColors.night,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.period == 'semua' ? 'TOTAL POIN' : 'POIN BULAN INI',
              style: text.labelSmall?.copyWith(color: const Color(0xFFCFC3BE), letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text('${data.points}',
              style: text.displayMedium?.copyWith(color: const Color(0xFFF4EEEB), fontWeight: FontWeight.w700)),
          if (data.myRank != null)
            Text('Peringkat #${data.myRank!.rank}', style: text.bodyMedium?.copyWith(color: const Color(0xFFCFC3BE))),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final List<Stat> stats;

  const _StatsGrid(this.stats);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        for (final stat in stats)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ImpactColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(stat.label, style: text.bodySmall?.copyWith(color: ImpactColors.inkMuted)),
                Text('${stat.value}', style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                Text('+${stat.points} poin/aksi', style: text.labelSmall?.copyWith(color: ImpactColors.maroon)),
              ],
            ),
          ),
      ],
    );
  }
}

// Lencana digeser ke samping; yang belum diraih dibuat abu-abu dengan progresnya
class _BadgeList extends StatelessWidget {
  final List<ImpactBadge> badges;

  const _BadgeList(this.badges);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final badge = badges[i];
          return SizedBox(
            width: 110,
            child: Column(
              children: [
                Opacity(
                  opacity: badge.earned ? 1 : 0.35,
                  child: ClipOval(
                    child: Image.network(
                      badge.image,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 72,
                        height: 72,
                        color: ImpactColors.grey100,
                        child: const Icon(Icons.emoji_events_outlined, color: ImpactColors.inkMuted),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(badge.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                Text(badge.rule,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelSmall?.copyWith(color: ImpactColors.inkMuted)),
                if (!badge.earned)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: LinearProgressIndicator(
                      value: badge.percent / 100,
                      color: ImpactColors.maroon,
                      backgroundColor: ImpactColors.grey100,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;
  final String buttonText;
  final VoidCallback onPressed;

  const _EmptyCard({required this.text, required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: ImpactColors.grey100, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(backgroundColor: ImpactColors.ink),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
