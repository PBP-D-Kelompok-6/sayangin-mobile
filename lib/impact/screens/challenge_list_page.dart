// Daftar tantangan milik user (/dampak/api/tantangan/), dengan filter, ubah, dan hapus
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../impact_api.dart';
import '../models.dart';
import '../widgets.dart';
import 'challenge_form_page.dart';

class ChallengeListPage extends StatefulWidget {
  const ChallengeListPage({super.key});

  @override
  State<ChallengeListPage> createState() => _ChallengeListPageState();
}

class _ChallengeListPageState extends State<ChallengeListPage> {
  String _kind = ''; // "" = semua jenis
  String _status = ''; // "" | "berjalan" | "berakhir"
  late Future<List<Challenge>> _future;

  ImpactApi get _api => ImpactApi(context.read<CookieRequest>());

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _api.challenges(kind: _kind, status: _status);
  }

  void _reload() => setState(_load);

  Future<void> _openForm([Challenge? challenge]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ChallengeFormPage(challenge: challenge)),
    );
    if (changed == true) _reload();
  }

  Future<void> _delete(Challenge challenge) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus tantangan?'),
        content: Text('"${challenge.title}" akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: ImpactColors.maroon),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _api.deleteChallenge(challenge.id);
      messenger.showSnackBar(const SnackBar(content: Text('Tantangan dihapus.')));
      _reload();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter = _kind.isNotEmpty || _status.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Tantangan Saya')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: ImpactColors.ink,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _kind,
                  decoration: const InputDecoration(labelText: 'Jenis', isDense: true),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('Semua jenis')),
                    for (final entry in challengeKinds.entries)
                      DropdownMenuItem(value: entry.key, child: Text(entry.value)),
                  ],
                  onChanged: (value) {
                    _kind = value!;
                    _reload();
                  },
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final option in const {'': 'Semua', 'berjalan': 'Berjalan', 'berakhir': 'Berakhir'}.entries)
                      ChoiceChip(
                        label: Text(option.value),
                        selected: _status == option.key,
                        onSelected: (_) {
                          _status = option.key;
                          _reload();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Challenge>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.hasError) return ErrorView(error: snapshot.error!, onRetry: _reload);
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final rows = snapshot.data!;
                if (rows.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        hasFilter ? 'Tidak ada tantangan yang cocok dengan filter ini.' : 'Belum ada tantangan. Yuk buat yang pertama!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    _reload();
                    await _future;
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    children: [
                      for (final challenge in rows)
                        ChallengeCard(
                          challenge: challenge,
                          onTap: () => _openForm(challenge),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 20),
                            onSelected: (action) => action == 'ubah' ? _openForm(challenge) : _delete(challenge),
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'ubah', child: Text('Ubah')),
                              PopupMenuItem(value: 'hapus', child: Text('Hapus')),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
