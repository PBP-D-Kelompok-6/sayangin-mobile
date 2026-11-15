// Papan peringkat (/dampak/api/peringkat/); tamu boleh membuka, nama disamarkan server
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../impact_api.dart';
import '../models.dart';
import '../widgets.dart';

class LeaderboardPage extends StatefulWidget {
  final String initialPeriod;

  const LeaderboardPage({super.key, this.initialPeriod = 'bulan'});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  late String _period = widget.initialPeriod;
  late Future<Leaderboard> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ImpactApi(context.read<CookieRequest>()).leaderboard(_period);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Papan Peringkat')),
      body: FutureBuilder<Leaderboard>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorView(error: snapshot.error!, onRetry: () => setState(_load));
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(_load);
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: PeriodToggle(
                    period: _period,
                    onChanged: (period) => setState(() {
                      _period = period;
                      _load();
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Poin didapat dari: ${data.pointsInfo.map((e) => '${e.key} +${e.value}').join(' · ')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ImpactColors.inkMuted),
                ),
                const SizedBox(height: 16),
                if (data.rows.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text('Belum ada yang mengumpulkan poin di periode ini.')),
                  ),
                for (final row in data.rows) LeaderTile(row),
                // posisi sendiri ditampilkan terpisah kalau di luar 10 besar
                if (data.myRank != null && data.myRank!.rank > data.rows.length) ...[
                  const Divider(height: 32),
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
