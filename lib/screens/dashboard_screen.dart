import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/run_state.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RunState>(builder: (context, runState, _) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: CustomScrollView(
          slivers: [
            // ── APP BAR ───────────────────────────────────────────
            SliverAppBar(
              backgroundColor: AppTheme.bg,
              pinned: true,
              expandedHeight: 110,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('DASHBOARD',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3)),
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.accent.withValues(alpha: 0.15), AppTheme.bg],
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.local_fire_department, color: AppTheme.accent, size: 14),
                      const SizedBox(width: 4),
                      Text('3 day streak',
                          style: TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── HERO STATS ──────────────────────────────────
                  _SectionLabel('YOUR TERRITORY'),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _HeroStatCard(
                      icon: Icons.grid_4x4,
                      label: 'TILES OWNED',
                      value: '${runState.totalTilesOwned}',
                      color: AppTheme.accent,
                      subtitle: '+12 this week',
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _HeroStatCard(
                      icon: Icons.emoji_events,
                      label: 'GLOBAL RANK',
                      value: '#3',
                      color: Color(0xFFFFD700),
                      subtitle: 'Top 5%',
                    )),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _HeroStatCard(
                      icon: Icons.route,
                      label: 'TOTAL KM',
                      value: runState.totalKm.toStringAsFixed(1),
                      color: AppTheme.accentBlue,
                      subtitle: '${runState.totalRuns} runs',
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _HeroStatCard(
                      icon: Icons.speed,
                      label: 'AVG PACE',
                      value: '5:32',
                      color: AppTheme.accentGreen,
                      subtitle: 'min/km',
                    )),
                  ]),

                  const SizedBox(height: 28),

                  // ── WEEKLY ACTIVITY ──────────────────────────────
                  _SectionLabel('WEEKLY ACTIVITY'),
                  const SizedBox(height: 14),
                  _WeeklyBarChart(runHistory: runState.runHistory),

                  const SizedBox(height: 28),

                  // ── TERRITORY PROGRESS ───────────────────────────
                  _SectionLabel('TERRITORY CONTROL'),
                  const SizedBox(height: 14),
                  _TerritoryProgress(tiles: runState.totalTilesOwned),

                  const SizedBox(height: 28),

                  // ── RUN HISTORY ──────────────────────────────────
                  _SectionLabel('RECENT RUNS'),
                  const SizedBox(height: 14),
                  ...runState.runHistory.take(5).map((r) => _RunHistoryCard(record: r)).toList(),
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Section label ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 3, height: 16, color: AppTheme.accent,
        margin: const EdgeInsets.only(right: 10)),
    Text(text, style: const TextStyle(
        color: AppTheme.textSecondary, fontSize: 11,
        fontWeight: FontWeight.w700, letterSpacing: 2)),
  ]);
}

// ── Hero stat card ────────────────────────────────────────────────────────

class _HeroStatCard extends StatelessWidget {
  final IconData icon;
  final String label, value, subtitle;
  final Color color;
  const _HeroStatCard({
    required this.icon, required this.label,
    required this.value, required this.subtitle, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const Spacer(),
          Icon(Icons.trending_up, color: AppTheme.accentGreen, size: 14),
        ]),
        const SizedBox(height: 14),
        Text(value, style: TextStyle(
            color: AppTheme.textPrimary, fontSize: 28,
            fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(
            color: AppTheme.textSecondary, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 6),
        Text(subtitle, style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ── Weekly bar chart ──────────────────────────────────────────────────────

class _WeeklyBarChart extends StatelessWidget {
  final List<RunRecord> runHistory;
  const _WeeklyBarChart({required this.runHistory});

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final values = [3.2, 0.0, 5.1, 2.8, 0.0, 6.4, 4.0];
    final maxVal = values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('km per day', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          Text('This week: ${values.fold(0.0, (a, b) => a + b).toStringAsFixed(1)} km',
              style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 20),
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final isToday = i == 6;
              final heightFrac = maxVal == 0 ? 0.0 : values[i] / maxVal;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (values[i] > 0)
                        Text('${values[i].toStringAsFixed(1)}',
                            style: TextStyle(
                                color: isToday ? AppTheme.accent : AppTheme.textSecondary,
                                fontSize: 9)),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300 + i * 60),
                        height: 80 * heightFrac,
                        decoration: BoxDecoration(
                          color: values[i] == 0
                              ? AppTheme.border
                              : isToday
                              ? AppTheme.accent
                              : AppTheme.accentBlue.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(days[i],
                          style: TextStyle(
                              color: isToday ? AppTheme.accent : AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: isToday ? FontWeight.w800 : FontWeight.w400)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ]),
    );
  }
}

// ── Territory progress ────────────────────────────────────────────────────

class _TerritoryProgress extends StatelessWidget {
  final int tiles;
  const _TerritoryProgress({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: [
        Row(children: [
          Expanded(child: _ProgressItem(label: 'Neighbourhood', current: tiles, total: 500, color: AppTheme.accent)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _ProgressItem(label: 'District', current: tiles, total: 2000, color: AppTheme.accentBlue)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _ProgressItem(label: 'City Champion', current: tiles, total: 5000, color: Color(0xFFFFD700))),
        ]),
      ]),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String label;
  final int current, total;
  final Color color;
  const _ProgressItem({required this.label, required this.current, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = (current / total).clamp(0.0, 1.0);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        Text('$current / $total tiles', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: pct,
          backgroundColor: AppTheme.border,
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 8,
        ),
      ),
    ]);
  }
}

// ── Run history card ──────────────────────────────────────────────────────

class _RunHistoryCard extends StatelessWidget {
  final RunRecord record;
  const _RunHistoryCard({required this.record});

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.directions_run, color: AppTheme.accent, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_formatDate(record.date),
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Row(children: [
            Text('${record.distanceKm.toStringAsFixed(2)} km',
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('+${record.tilesVisited} tiles',
                  style: const TextStyle(color: AppTheme.accentGreen, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            '${record.duration.inMinutes}:${(record.duration.inSeconds % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '${(record.distanceKm / (record.duration.inMinutes / 60)).toStringAsFixed(1)} km/h',
            style: const TextStyle(color: AppTheme.accentBlue, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ]),
      ]),
    );
  }
}
