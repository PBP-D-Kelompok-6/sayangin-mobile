// Widget kecil yang dipakai bersama oleh halaman-halaman Modul Dampak
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models.dart';

// Warna mengikuti static/css/tokens.css di web, supaya tampilan web & aplikasi selaras
class ImpactColors {
  static const ink = Color(0xFF1A1210); // teks utama, tombol gelap
  static const inkSoft = Color(0xFF4A3F3B);
  static const inkMuted = Color(0xFF6E625E);
  static const maroon = Color(0xFF6B1420); // aksen
  static const night = Color(0xFF120B09); // kartu gelap
  static const paper = Color(0xFFFAFAF8); // latar halaman
  static const grey100 = Color(0xFFF1F1EF);
  static const border = Color(0x1F1A1210);
}

final _dateFormat = DateFormat('d MMM yyyy');

String formatDate(DateTime date) => _dateFormat.format(date);

// Pilihan periode "Bulan ini" / "Semua"; dipakai dashboard & peringkat
class PeriodToggle extends StatelessWidget {
  final String period;
  final ValueChanged<String> onChanged;

  const PeriodToggle({super.key, required this.period, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'bulan', label: Text('Bulan ini')),
        ButtonSegment(value: 'semua', label: Text('Semua')),
      ],
      selected: {period},
      showSelectedIcon: false,
      onSelectionChanged: (selected) => onChanged(selected.first),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
          ?trailing,
        ],
      ),
    );
  }
}

// Kartu tantangan: judul, jenis, progres, dan tanggal
class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback? onTap;
  final Widget? trailing; // mis. menu ubah/hapus di halaman daftar

  const ChallengeCard({super.key, required this.challenge, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final finished = challenge.remaining == 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(challenge.kindLabel.toUpperCase(),
                        style: text.labelSmall?.copyWith(color: ImpactColors.inkMuted, letterSpacing: 0.8)),
                  ),
                  if (!challenge.isRunning) const _Tag('Berakhir'),
                  if (challenge.isRunning && finished) const _Tag('Selesai'),
                  ?trailing,
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(challenge.title, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: challenge.percent / 100,
                    minHeight: 6,
                    color: ImpactColors.maroon,
                    backgroundColor: ImpactColors.grey100,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    Text('${challenge.done}/${challenge.target}', style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('${formatDate(challenge.startDate)} – ${formatDate(challenge.endDate)}',
                        style: text.bodySmall?.copyWith(color: ImpactColors.inkMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: ImpactColors.grey100, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

// Baris papan peringkat; baris milik sendiri diberi latar & tulisan "(kamu)"
class LeaderTile extends StatelessWidget {
  final LeaderRow row;

  const LeaderTile(this.row, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: row.isMe ? ImpactColors.grey100 : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: row.rank <= 3 ? ImpactColors.maroon : ImpactColors.grey100,
          foregroundColor: row.rank <= 3 ? Colors.white : ImpactColors.ink,
          child: Text('${row.rank}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        title: Text(row.isMe ? '${row.username} (kamu)' : row.username,
            style: TextStyle(fontWeight: row.isMe ? FontWeight.w700 : FontWeight.w500)),
        trailing: Text('${row.points} poin', style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// Tampilan saat gagal memuat data, dengan tombol coba lagi
class ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  final Widget? action;

  const ErrorView({super.key, required this.error, required this.onRetry, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: ImpactColors.inkMuted),
            const SizedBox(height: 12),
            Text('$error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Coba lagi')),
            if (action != null) ...[const SizedBox(height: 8), action!],
          ],
        ),
      ),
    );
  }
}
