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

// Pre-compute total count per denomination
final Map<int, int> kTotalCounts = () {
  final map = <int, int>{};
  for (final v in kItems) {
    map[v] = (map[v] ?? 0) + 1;
  }
  return map;
}();

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
  LegendEntry(denom: 1,   color: Color(0xFFF9A825)),
  LegendEntry(denom: 5,   color: Color(0xFF1E88E5)),
  LegendEntry(denom: 10,  color: Color(0xFF43A047)),
  LegendEntry(denom: 20,  color: Color(0xFFE91E63)),
  LegendEntry(denom: 50,  color: Color(0xFF7E57C2)),
  LegendEntry(denom: 100, color: Color(0xFF00ACC1)),
  LegendEntry(denom: 500, color: Color(0xFFFF6F00)),
];

class LegendEntry {
  final int denom;
  final Color color;
  const LegendEntry({required this.denom, required this.color});
}

// ─── Log entry ────────────────────────────────────────────────────────────────

class LogEntry {
  final int amount;
  final DateTime time;
  final bool isAdd; // true = put in, false = removed

  LogEntry({required this.amount, required this.time, required this.isAdd});

  String serialize() =>
      '${isAdd ? 1 : 0}|$amount|${time.millisecondsSinceEpoch}';

  static LogEntry? deserialize(String s) {
    final parts = s.split('|');
    if (parts.length != 3) return null;
    final ms = int.tryParse(parts[2]);
    final amt = int.tryParse(parts[1]);
    if (ms == null || amt == null) return null;
    return LogEntry(
      isAdd: parts[0] == '1',
      amount: amt,
      time: DateTime.fromMillisecondsSinceEpoch(ms),
    );
  }
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
      home: const IponHomePage(),
    );
  }
}

// ─── Home page ────────────────────────────────────────────────────────────────

class IponHomePage extends StatefulWidget {
  const IponHomePage({super.key});

  @override
  State<IponHomePage> createState() => _IponHomePageState();
}

class _IponHomePageState extends State<IponHomePage> {
  late List<bool> _shaded;
  bool _loaded = false;
  bool _winShown = false;
  List<LogEntry> _log = [];

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

    // Load shaded state
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

    // Load log (never cleared by reset)
    final logRaw = prefs.getString('ipon_log') ?? '';
    if (logRaw.isNotEmpty) {
      _log = logRaw
          .split('\n')
          .where((s) => s.isNotEmpty)
          .map(LogEntry.deserialize)
          .whereType<LogEntry>()
          .toList();
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

  Future<void> _saveLog() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _log.map((e) => e.serialize()).join('\n');
    await prefs.setString('ipon_log', raw);
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
    final wasShaded = _shaded[index];
    setState(() {
      _shaded[index] = !_shaded[index];
    });
    _log.add(LogEntry(
      amount: kItems[index],
      time: DateTime.now(),
      isAdd: !wasShaded,
    ));
    _saveState();
    _saveLog();
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
          'This will clear all your shaded boxes. Your Log Book will be kept.',
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

          // ── Log Book button (top-right) ───────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 16),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 4,
                  shadowColor: Colors.black26,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LogBookPage(log: _log),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFFFF6B6B),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
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
    // Compute how many of each denomination have already been checked
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
        final checked = checkedCounts[e.denom] ?? 0;
        final total = kTotalCounts[e.denom] ?? 0;
        final remaining = total - checked;
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
                  color: remaining == 0 ? Colors.grey[300] : e.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$remaining × ₱${e.denom}/$total',
                style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: remaining == 0 ? Colors.grey[400] : null),
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

// ─── Log Book page ────────────────────────────────────────────────────────────────

class LogBookPage extends StatelessWidget {
  final List<LogEntry> log;

  const LogBookPage({super.key, required this.log});

  String _formatDate(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    final month = months[dt.month - 1];
    final day = dt.day.toString().padLeft(2, '0');
    final year = dt.year;
    final weekday = weekdays[dt.weekday - 1];
    int hour = dt.hour;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$month $day, $year  •  $weekday  •  $hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...log]..sort((a, b) => b.time.compareTo(a.time));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        title: Text(
          '📒 Log Book',
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: const Color(0xFF333333),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFF6B6B)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: sorted.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📭', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    'No transactions yet.',
                    style: GoogleFonts.nunito(
                        fontSize: 16, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = sorted[index];
                final isAdd = entry.isAdd;
                final denomStyle = kDenomStyles[entry.amount];
                final accentColor = isAdd
                    ? (denomStyle?.shadedBg ?? const Color(0xFFFF6B6B))
                    : Colors.grey[500]!;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          isAdd
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: accentColor,
                          size: 22,
                        ),
                      ),
                    ),
                    title: Text(
                      isAdd
                          ? 'You Put ₱${entry.amount}'
                          : 'You Removed ₱${entry.amount}',
                      style: GoogleFonts.baloo2(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _formatDate(entry.time),
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '₱${entry.amount}',
                        style: GoogleFonts.baloo2(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                        ),
                      ),
                    ),
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
