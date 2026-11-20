// Halaman utama (Beranda) & kerangka navigasi aplikasi Sayangin.
// Mengikuti palet warna & gaya visual Modul Dampak (ImpactColors) serta struktur halaman web (templates/index.html).
import 'package:flutter/material.dart';

import '../../impact/screens/impact_dashboard_page.dart';
import '../../impact/screens/leaderboard_page.dart';
import '../../impact/widgets.dart';

class MainNavigationPage extends StatefulWidget {
  final int initialIndex;

  const MainNavigationPage({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late int _currentIndex = widget.initialIndex;

  void _selectTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(onNavigateToImpact: () => _selectTab(1)),
      const ImpactDashboardPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: ImpactColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _selectTab,
          backgroundColor: ImpactColors.paper,
          indicatorColor: ImpactColors.grey100,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: ImpactColors.maroon),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome, color: ImpactColors.maroon),
              label: 'Dampak',
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback? onNavigateToImpact;

  const HomePage({super.key, this.onNavigateToImpact});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedPhase = 0;

  static const List<({String tab, String title, String description, IconData icon})> _phases = [
    (
      tab: '1 · Catat',
      title: 'Catat di Lemari Digital',
      description: 'Foto barangmu dan masukkan ke Lemari Digital. Satu menit per barang.',
      icon: Icons.checkroom_outlined,
    ),
    (
      tab: '2 · Pilih',
      title: 'Diingatkan sebelum terlupakan',
      description: 'Saat barang lama tak dipakai, kami tanya: jual, donasi, atau simpan dengan alasan?',
      icon: Icons.notifications_active_outlined,
    ),
    (
      tab: '3 · Salurkan',
      title: 'Jual atau donasikan tepat sasaran',
      description: 'Tayangkan langsung ke Marketplace atau cocokkan dengan kebutuhan spesifik lembaga mitra.',
      icon: Icons.volunteer_activism_outlined,
    ),
  ];

  void _openImpact() {
    if (widget.onNavigateToImpact != null) {
      widget.onNavigateToImpact!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ImpactDashboardPage()),
      );
    }
  }

  void _openLeaderboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LeaderboardPage()),
    );
  }

  void _showComingSoon(String moduleName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Modul $moduleName akan segera terhubung di navigasi utama.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final phase = _phases[_selectedPhase];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: ImpactColors.maroon,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.favorite, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              'sayangin',
              style: text.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: ImpactColors.ink,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Papan Peringkat',
            onPressed: _openLeaderboard,
            icon: const Icon(Icons.leaderboard_outlined),
          ),
          IconButton(
            tooltip: 'Dampak',
            onPressed: _openImpact,
            icon: const Icon(Icons.auto_awesome_outlined),
          ),
        ],
      ),
      drawer: _AppDrawer(
        onOpenImpact: _openImpact,
        onOpenLeaderboard: _openLeaderboard,
        onComingSoon: _showComingSoon,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _HeroBanner(
            onOpenImpact: _openImpact,
            onOpenLeaderboard: _openLeaderboard,
          ),
          const SizedBox(height: 20),
          const _StatementCard(),
          SectionTitle('Cara kerja (3 langkah)'),
          SegmentedButton<int>(
            segments: [
              for (var i = 0; i < _phases.length; i++)
                ButtonSegment<int>(
                  value: i,
                  label: Text(_phases[i].tab),
                ),
            ],
            selected: {_selectedPhase},
            showSelectedIcon: false,
            onSelectionChanged: (selected) => setState(() => _selectedPhase = selected.first),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ImpactColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ImpactColors.grey100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(phase.icon, color: ImpactColors.maroon, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phase.title,
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: ImpactColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phase.description,
                        style: text.bodyMedium?.copyWith(color: ImpactColors.inkSoft),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SectionTitle('Jelajahi modul'),
          _ModuleGrid(
            onOpenImpact: _openImpact,
            onOpenLeaderboard: _openLeaderboard,
            onComingSoon: _showComingSoon,
          ),
          SectionTitle('Dampak bersama'),
          _CommunityImpactCard(
            onOpenImpact: _openImpact,
            onOpenLeaderboard: _openLeaderboard,
          ),
          SectionTitle('Pertanyaan umum'),
          const _FaqSection(),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final VoidCallback onOpenImpact;
  final VoidCallback onOpenLeaderboard;

  const _HeroBanner({
    required this.onOpenImpact,
    required this.onOpenLeaderboard,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const RadialGradient(
          center: Alignment(0.75, -0.75),
          radius: 1.25,
          colors: [Color(0x997A1E2A), ImpactColors.night],
        ),
        color: ImpactColors.night,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EKONOMI SIRKULAR PRELOVED',
            style: text.labelSmall?.copyWith(
              color: const Color(0xFFCFC3BE),
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Barang lama,\ndisayang lagi.',
            style: text.headlineMedium?.copyWith(
              color: const Color(0xFFF4EEEB),
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Jual, donasikan tepat sasaran, atau simpan dengan sadar. Pantau jejak kebaikan dari setiap barang di lemarimu.',
            style: text.bodyMedium?.copyWith(
              color: const Color(0xFFCFC3BE),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onOpenImpact,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF4EEEB),
                  foregroundColor: ImpactColors.ink,
                ),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Lihat Dampak'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenLeaderboard,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF4EEEB),
                  side: const BorderSide(color: Color(0x55CFC3BE)),
                ),
                icon: const Icon(Icons.emoji_events_outlined, size: 18),
                label: const Text('Papan Peringkat'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatementCard extends StatelessWidget {
  const _StatementCard();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ImpactColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '( 01 ) TENTANG KAMI',
            style: text.labelSmall?.copyWith(
              color: ImpactColors.maroon,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Setiap barang di lemarimu punya jalan pulang',
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: ImpactColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dipakai orang lain lewat Marketplace, diteruskan ke lembaga yang membutuhkan, atau disimpan kembali dengan alasan.',
            style: text.bodyMedium?.copyWith(color: ImpactColors.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _ModuleGrid extends StatelessWidget {
  final VoidCallback onOpenImpact;
  final VoidCallback onOpenLeaderboard;
  final ValueChanged<String> onComingSoon;

  const _ModuleGrid({
    required this.onOpenImpact,
    required this.onOpenLeaderboard,
    required this.onComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    final modules = [
      (
        number: '01',
        title: 'Dampak & Sosial',
        subtitle: 'Poin dampak, tantangan pribadi, lencana, & peringkat',
        icon: Icons.auto_awesome_outlined,
        highlighted: true,
        onTap: onOpenImpact,
      ),
      (
        number: '02',
        title: 'Papan Peringkat',
        subtitle: 'Lihat kontributor dampak tertinggi bulan ini',
        icon: Icons.leaderboard_outlined,
        highlighted: false,
        onTap: onOpenLeaderboard,
      ),
      (
        number: '03',
        title: 'Marketplace',
        subtitle: 'Belanja & jual barang preloved layak pakai',
        icon: Icons.shopping_bag_outlined,
        highlighted: false,
        onTap: () => onComingSoon('Marketplace'),
      ),
      (
        number: '04',
        title: 'Lemari Digital',
        subtitle: 'Catat & rawat isi lemarimu dengan pengingat',
        icon: Icons.checkroom_outlined,
        highlighted: false,
        onTap: () => onComingSoon('Lemari Digital'),
      ),
      (
        number: '05',
        title: 'Donasi Tepat Sasaran',
        subtitle: 'Salurkan barang sesuai kebutuhan lembaga mitra',
        icon: Icons.favorite_border,
        highlighted: false,
        onTap: () => onComingSoon('Donasi'),
      ),
    ];

    return Column(
      children: [
        for (final mod in modules)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: mod.highlighted ? ImpactColors.maroon : ImpactColors.border,
                width: mod.highlighted ? 1.4 : 1,
              ),
            ),
            child: ListTile(
              onTap: mod.onTap,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: CircleAvatar(
                backgroundColor: mod.highlighted ? ImpactColors.maroon : ImpactColors.grey100,
                foregroundColor: mod.highlighted ? Colors.white : ImpactColors.ink,
                child: Icon(mod.icon, size: 20),
              ),
              title: Row(
                children: [
                  Text(
                    mod.number,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: ImpactColors.inkMuted,
                          letterSpacing: 0.8,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mod.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: ImpactColors.ink,
                          ),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  mod.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ImpactColors.inkSoft),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward, size: 18, color: ImpactColors.inkMuted),
            ),
          ),
      ],
    );
  }
}

class _CommunityImpactCard extends StatelessWidget {
  final VoidCallback onOpenImpact;
  final VoidCallback onOpenLeaderboard;

  const _CommunityImpactCard({
    required this.onOpenImpact,
    required this.onOpenLeaderboard,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ImpactColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1.240',
                      style: text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: ImpactColors.maroon,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'barang terselamatkan',
                      style: text.bodySmall?.copyWith(color: ImpactColors.inkMuted),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: ImpactColors.border),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '480',
                      style: text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: ImpactColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'donasi tersalurkan',
                      style: text.bodySmall?.copyWith(color: ImpactColors.inkMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onOpenImpact,
                  style: FilledButton.styleFrom(backgroundColor: ImpactColors.ink),
                  child: const Text('Buka Dasbor Dampak'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: onOpenLeaderboard,
                child: const Text('Peringkat'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  static const List<({String q, String a})> _items = [
    (
      q: 'Bagaimana kondisi barang dijamin?',
      a: 'Penjual wajib memilih kondisi dan menambahkan foto cacat. Kalau barang tidak sesuai, ajukan masalah dari halaman Lacak pesanan.',
    ),
    (
      q: 'Apakah donasi benar-benar sampai?',
      a: 'Lembaga mitra mengonfirmasi setiap barang yang diterima, dan statusnya bisa kamu lacak serta menambah poin Dampak.',
    ),
    (
      q: 'Bagaimana lembaga bisa bergabung?',
      a: 'Daftar sebagai lembaga mitra dan lengkapi profil serta dokumen legalitas lembaga untuk mempublikasikan kebutuhan barang.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ImpactColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            ExpansionTile(
              initiallyExpanded: i == 0,
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              title: Text(
                _items[i].q,
                style: text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ImpactColors.ink,
                ),
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _items[i].a,
                    style: text.bodySmall?.copyWith(
                      color: ImpactColors.inkSoft,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final VoidCallback onOpenImpact;
  final VoidCallback onOpenLeaderboard;
  final ValueChanged<String> onComingSoon;

  const _AppDrawer({
    required this.onOpenImpact,
    required this.onOpenLeaderboard,
    required this.onComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Drawer(
      backgroundColor: ImpactColors.paper,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'sayangin',
                    style: text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: ImpactColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Barang lama, disayang lagi.',
                    style: text.bodySmall?.copyWith(color: ImpactColors.inkMuted),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.home_outlined, color: ImpactColors.ink),
              title: const Text('Beranda'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome_outlined, color: ImpactColors.maroon),
              title: const Text('Dampak & Tantangan'),
              subtitle: const Text('Dasbor poin, tantangan, & lencana'),
              onTap: () {
                Navigator.pop(context);
                onOpenImpact();
              },
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard_outlined, color: ImpactColors.ink),
              title: const Text('Papan Peringkat'),
              subtitle: const Text('10 besar kontributor dampak'),
              onTap: () {
                Navigator.pop(context);
                onOpenLeaderboard();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined, color: ImpactColors.inkMuted),
              title: const Text('Marketplace'),
              onTap: () {
                Navigator.pop(context);
                onComingSoon('Marketplace');
              },
            ),
            ListTile(
              leading: const Icon(Icons.checkroom_outlined, color: ImpactColors.inkMuted),
              title: const Text('Lemari Digital'),
              onTap: () {
                Navigator.pop(context);
                onComingSoon('Lemari Digital');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border, color: ImpactColors.inkMuted),
              title: const Text('Donasi'),
              onTap: () {
                Navigator.pop(context);
                onComingSoon('Donasi');
              },
            ),
          ],
        ),
      ),
    );
  }
}
