import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(const IponChallengeApp());
}

// ─── Denomination data ────────────────────────────────────────────────────────

const List<int> kItems = [
  5,10,5,10,5,10,5,100,50,100,100,1,1,100,5,5,1,10,100,5,5,1,1,1,50,100,5,
  50,1,500,1,5,5,5,1,10,100,1,5,5,5,5,1,1,100,5,10,10,100,100,5,100,100,5,
  100,100,5,1,1,5,10,50,1,5,10,5,5,10,5,5,5,1,5,50,10,20,1,10,10,1,50,100,
  100,20,10,5,100,50,20,5,100,1,20,1,100,20,50,5,1,1,5,100,50,5,100,50,1,1,
  5,10,10,100,1,20,100,5,1,10,1,50,1,1,100,1,1,100,1,10,1,5,1,1,1,5,1,5,100,
  10,10,100,1,100,10,100,100,10,1,100,50,5,5,100,1,50,5,1,1,10,100,20,5,100,
  5,5,1,50,5,100,10,100,10,1,500,1,1,1,50,5,1,1,1,1,1,100,5,5,500,10,50,1,1,
  5,20,1,1,5,10,1,1,5,100,100,1,1,1,10,10,5,1,20,1,5,10,5,5,5,10,10,5,1,1,50,
  1,10,5,1,10,5,1,1,1,5,10,100,1,50,10,50,5,100,5,100,100,5,5,5,1,5,100,1,1,
  5,1,1,50,1,1,1,1,50,100,10,10,5,5,50,5,1,1,1,100,1,1,10,10,100,100,20,5,5,
  100,5,50,1,1,100,10,5,5,100,5,1,1,5,10,50,1,5,1,50,100,10,1,1,10,5,1,10,1,
  100,1,1,10,10,100,100,100,5,1,100,1,100,50,10,10,10,100,100,1,
];

const int kGoal = 10000;

// ─── Colors per denomination ──────────────────────────────────────────────────

class DenomStyle {
  final Color bg;
  final Color border;
  final Color text;
  final Color shadedBg;
  const DenomStyle({
    required this.bg,
    required this.border,
    required this.text,
    required this.shadedBg,
  });
}

const Map<int, DenomStyle> kDenomStyles = {
  1: DenomStyle(
    bg: Color(0xFFFFF3CD), border: Color(0xFFFFE082),
    text: Color(0xFF7A5C00), shadedBg: Color(0xFFF9A825),
  ),
  5: DenomStyle(
    bg: Color(0xFFE3F2FD), border: Color(0xFF90CAF9),
    text: Color(0xFF0D47A1), shadedBg: Color(0xFF1E88E5),
  ),
  10: DenomStyle(
    bg: Color(0xFFE8F5E9), border: Color(0xFFA5D6A7),
    text: Color(0xFF1B5E20), shadedBg: Color(0xFF43A047),
  ),
  20: DenomStyle(
    bg: Color(0xFFFCE4EC), border: Color(0xFFF48FB1),
    text: Color(0xFF880E4F), shadedBg: Color(0xFFE91E63),
  ),
  50: DenomStyle(
    bg: Color(0xFFEDE7F6), border: Color(0xFFB39DDB),
    text: Color(0xFF4527A0), shadedBg: Color(0xFF7E57C2),
  ),
  100: DenomStyle(
    bg: Color(0xFFE0F7FA), border: Color(0xFF80DEEA),
    text: Color(0xFF006064), shadedBg: Color(0xFF00ACC1),
  ),
  500: DenomStyle(
    bg: Color(0xFFFFF8E1), border: Color(0xFFFFCA28),
    text: Color(0xFFE65100), shadedBg: Color(0xFFFF6F00),
  ),
};

const List<LegendEntry> kLegend = [
  LegendEntry(denom: 1,   label: '₱1 × 100',  color: Color(0xFFF9A825)),
  LegendEntry(denom: 5,   label: '₱5 × 80',   color: Color(0xFF1E88E5)),
  LegendEntry(denom: 10,  label: '₱10 × 50',  color: Color(0xFF43A047)),
  LegendEntry(denom: 20,  label: '₱20 × 10',  color: Color(0xFFE91E63)),
  LegendEntry(denom: 50,  label: '₱50 × 26',  color: Color(0xFF7E57C2)),
  LegendEntry(denom: 100, label: '₱100 × 60', color: Color(0xFF00ACC1)),
  LegendEntry(denom: 500, label: '₱500 × 3',  color: Color(0xFFFF6F00)),
];

class LegendEntry {
  final int denom;
  final String label;
  final Color color;
  const LegendEntry({required this.denom, required this.label, required this.color});
}

// ─── App root ─────────────────────────────────────────────────────────────────

class IponChallengeApp extends StatelessWidget {
  const IponChallengeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Save!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B6B)),
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      home: const SplashPage(),
    );
  }
}

// ─── Splash / Landing page ────────────────────────────────────────────────────

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeIn = CurvedAnimation(parent: _ac, curve: Curves.easeIn);
    _slideUp = Tween<double>(begin: 40, end: 0).animate(
        CurvedAnimation(parent: _ac, curve: Curves.easeOut));
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  void _start() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context2, anim1, anim2) => const IponHomePage(),
        transitionsBuilder: (context2, anim, secAnim, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFB6C1), // baby pink
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _ac,
            builder: (context, child) => Opacity(
              opacity: _fadeIn.value,
              child: Transform.translate(
                offset: Offset(0, _slideUp.value),
                child: child,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Piggy image
                  Image.asset(
                    'assets/images/piggy.png',
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 28),

                  // Title
                  Text(
                    'Save!',
                    style: GoogleFonts.baloo2(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.pink.shade300,
                          offset: const Offset(2, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Your ₱10,000 piggy bank challenge',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Start button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF6B6B),
                        elevation: 6,
                        shadowColor: Colors.pink.shade200,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _start,
                      child: Text(
                        'Let\'s Start! 🐷',
                        style: GoogleFonts.baloo2(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class IponHomePage extends StatefulWidget {
  const IponHomePage({super.key});

  @override
  State<IponHomePage> createState() => _IponHomePageState();
}

class _IponHomePageState extends State<IponHomePage> {
  late List<bool> _shaded;
  bool _loaded = false;
  bool _winShown = false;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _shaded = List<bool>.filled(kItems.length, false);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4));
    _loadState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // ── Persistence ──────────────────────────────────────────────────────────────

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('ipon_shaded');
    if (saved != null && saved.isNotEmpty) {
      final indices = saved
          .split(',')
          .where((s) => s.isNotEmpty)
          .map(int.parse);
      for (final i in indices) {
        if (i < _shaded.length) _shaded[i] = true;
      }
    }
    setState(() => _loaded = true);
    _checkWin(silent: true);
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final indices = <int>[];
    for (int i = 0; i < _shaded.length; i++) {
      if (_shaded[i]) indices.add(i);
    }
    await prefs.setString('ipon_shaded', indices.join(','));
  }

  // ── Stats ────────────────────────────────────────────────────────────────────

  int get _savedAmount {
    int total = 0;
    for (int i = 0; i < kItems.length; i++) {
      if (_shaded[i]) total += kItems[i];
    }
    return total;
  }

  int get _shadedCount => _shaded.where((s) => s).length;

  // ── Toggle ───────────────────────────────────────────────────────────────────

  void _toggle(int index) {
    setState(() {
      _shaded[index] = !_shaded[index];
    });
    _saveState();
    _checkWin();
  }

  void _checkWin({bool silent = false}) {
    if (_savedAmount >= kGoal && !_winShown) {
      _winShown = true;
      if (!silent) {
        _confettiController.play();
        Future.delayed(const Duration(milliseconds: 200), _showWinDialog);
      }
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(32, 32, 32, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 8),
            Text(
              'Goal Reached!',
              style: GoogleFonts.baloo2(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFFF6B6B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Congrats! You saved ₱10,000! 🐷💰',
              style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Woohoo! 🎊',
                style: GoogleFonts.baloo2(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reset ────────────────────────────────────────────────────────────────────

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset Progress?',
            style: GoogleFonts.baloo2(fontWeight: FontWeight.w700)),
        content: Text(
          'This will clear all your shaded boxes. This cannot be undone.',
          style: GoogleFonts.nunito(color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _shaded = List<bool>.filled(kItems.length, false);
                _winShown = false;
              });
              _saveState();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final saved = _savedAmount;
    final remaining = kGoal - saved;
    final count = _shadedCount;
    final pct = (saved / kGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Stack(
        children: [
          // ── Background gradient blobs ───────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(painter: _BgPainter()),
          ),

          // ── Main scroll content ─────────────────────────────────────────────
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildStatsBar(saved, remaining, count),
                        const SizedBox(height: 16),
                        _buildProgressBar(pct),
                        const SizedBox(height: 8),
                        _buildProgressLabel(pct),
                        const SizedBox(height: 16),
                        _buildLegend(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    child: _buildGrid(),
                  ),
                ),
              ],
            ),
          ),

          // ── Confetti ────────────────────────────────────────────────────────
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              gravity: 0.2,
              colors: const [
                Color(0xFFFF6B6B), Color(0xFFFFD93D), Color(0xFF6BCB77),
                Color(0xFF4D96FF), Color(0xFFFF922B), Color(0xFFCC5DE8),
                Color(0xFF20C997),
              ],
            ),
          ),

          // ── Reset FAB ────────────────────────────────────────────────────────
          Positioned(
            bottom: 24,
            right: 20,
            child: FloatingActionButton.small(
              tooltip: 'Reset progress',
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFFF6B6B),
              elevation: 4,
              onPressed: _confirmReset,
              child: const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.baloo2(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF333333),
            ),
            children: const [
              TextSpan(text: '🐷 Ipon '),
              TextSpan(
                text: 'Challenge',
                style: TextStyle(color: Color(0xFFFF6B6B)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Shade each box when you drop that amount in your piggy bank!',
          style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Stats bar ─────────────────────────────────────────────────────────────────

  Widget _buildStatsBar(int saved, int remaining, int count) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: [
        _StatCard(
          value: '₱${_fmt(saved)}',
          label: 'SAVED',
          color: const Color(0xFFFF6B6B),
        ),
        _StatCard(
          value: '₱${_fmt(remaining.clamp(0, kGoal))}',
          label: 'REMAINING',
          color: const Color(0xFF4D96FF),
        ),
        _StatCard(
          value: '$count / ${kItems.length}',
          label: 'BOXES',
          color: const Color(0xFF6BCB77),
        ),
      ],
    );
  }

  // ── Progress bar ─────────────────────────────────────────────────────────────

  Widget _buildProgressBar(double pct) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Container(
          height: 22,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: pct),
              duration: const Duration(milliseconds: 400),
              builder: (context2, value, child) => LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF922B)),
                minHeight: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressLabel(double pct) {
    return Text(
      '${(pct * 100).round()}% complete',
      style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[400]),
    );
  }

  // ── Legend ───────────────────────────────────────────────────────────────────

  Widget _buildLegend() {
    // Compute how many of each denomination have been checked
    final Map<int, int> checkedCounts = {};
    for (int i = 0; i < kItems.length; i++) {
      if (_shaded[i]) {
        checkedCounts[kItems[i]] = (checkedCounts[kItems[i]] ?? 0) + 1;
      }
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: kLegend.map((e) {
        final count = checkedCounts[e.denom] ?? 0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: e.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '₱${e.denom} × $count',
                style: GoogleFonts.nunito(
                    fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Grid ─────────────────────────────────────────────────────────────────────

  Widget _buildGrid() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossCount = width < 400 ? 6 : 8;
          const spacing = 8.0;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: 1,
            ),
            itemCount: kItems.length,
            itemBuilder: (context, i) => _DenomCell(
              value: kItems[i],
              shaded: _shaded[i],
              onTap: () => _toggle(i),
            ),
          );
        },
      ),
    );
  }
}

// ─── Stat card widget ─────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      constraints: const BoxConstraints(minWidth: 110),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.baloo2(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey[400],
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Denomination cell widget ─────────────────────────────────────────────────

class _DenomCell extends StatefulWidget {
  final int value;
  final bool shaded;
  final VoidCallback onTap;

  const _DenomCell({
    required this.value,
    required this.shaded,
    required this.onTap,
  });

  @override
  State<_DenomCell> createState() => _DenomCellState();
}

class _DenomCellState extends State<_DenomCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(
        CurvedAnimation(parent: _ac, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = kDenomStyles[widget.value]!;
    final bg = widget.shaded ? style.shadedBg : style.bg;
    final border = widget.shaded ? style.shadedBg : style.border;

    return GestureDetector(
      onTapDown: (_) => _ac.forward(),
      onTapUp: (_) {
        _ac.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ac.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellSize = constraints.maxWidth;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: border, width: 1.5),
                boxShadow: widget.shaded
                    ? [
                        BoxShadow(
                          color: style.shadedBg.withValues(alpha: 0.45),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: widget.shaded
                    ? Icon(
                        Icons.check_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: cellSize * 0.45,
                      )
                    : Text(
                        '₱${widget.value}',
                        style: GoogleFonts.baloo2(
                          fontSize: cellSize * 0.26,
                          fontWeight: FontWeight.w600,
                          color: style.text,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Background blob painter ──────────────────────────────────────────────────

class _BgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()
      ..color = const Color(0xFFFFE8D6).withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(
        Offset(size.width * 0.15, size.height * 0.12), size.width * 0.45, p1);

    final p2 = Paint()
      ..color = const Color(0xFFFFD6E0).withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.88), size.width * 0.45, p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _fmt(int n) {
  if (n >= 1000) {
    final s = n.toString();
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }
  return n.toString();
}
