import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/run_state.dart';
import '../theme/app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RunState>(builder: (context, runState, _) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              backgroundColor: AppTheme.bg,
              pinned: true,
              expandedHeight: 180,
              flexibleSpace: FlexibleSpaceBar(
                background: _LeaderboardHeader(runState: runState),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: AppTheme.bgCard,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppTheme.accent,
                    indicatorWeight: 3,
                    labelColor: AppTheme.accent,
                    unselectedLabelColor: AppTheme.textSecondary,
                    labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5),
                    tabs: const [
                      Tab(text: 'GLOBAL'),
                      Tab(text: 'WEEKLY'),
                      Tab(text: 'NEARBY'),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _LeaderboardList(entries: runState.leaderboard),
              _LeaderboardList(entries: runState.leaderboard.reversed.toList()),
              _LeaderboardList(entries: runState.leaderboard.sublist(0, 5)),
            ],
          ),
        ),
      );
    });
  }
}

// ── Header with your rank ──────────────────────────────────────────────────

class _LeaderboardHeader extends StatelessWidget {
  final RunState runState;
  const _LeaderboardHeader({required this.runState});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.15),
            AppTheme.accent.withValues(alpha: 0.1),
            AppTheme.bg,
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('LEADERBOARD', style: TextStyle(
            color: AppTheme.textPrimary, fontSize: 22,
            fontWeight: FontWeight.w800, letterSpacing: 3)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            const Text('🔥', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('YOUR POSITION', style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 10, letterSpacing: 2)),
              const SizedBox(height: 4),
              Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                const Text('#3', style: TextStyle(
                    color: Color(0xFFFFD700), fontSize: 30, fontWeight: FontWeight.w900)),
                const SizedBox(width: 8),
                const Text('Global', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ]),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${runState.totalTilesOwned}',
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
              const Text('tiles owned', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('↑ 2 spots this week',
                    style: TextStyle(color: AppTheme.accentGreen, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ── Leaderboard list ──────────────────────────────────────────────────────

class _LeaderboardList extends StatelessWidget {
  final List<Map<String, dynamic>> entries;
  const _LeaderboardList({required this.entries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: entries.length,
      itemBuilder: (_, i) => _LeaderboardEntry(data: entries[i], index: i),
    );
  }
}

class _LeaderboardEntry extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;
  const _LeaderboardEntry({required this.data, required this.index});

  Color get _rankColor {
    switch (data['rank']) {
      case 1: return const Color(0xFFFFD700);
      case 2: return const Color(0xFFB0BEC5);
      case 3: return const Color(0xFFFF8A65);
      default: return AppTheme.textSecondary;
    }
  }

  bool get _isYou => data['name'] == 'YOU';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isYou
            ? AppTheme.accent.withValues(alpha: 0.08)
            : AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isYou ? AppTheme.accent.withValues(alpha: 0.4) : AppTheme.border,
          width: _isYou ? 1.5 : 1,
        ),
      ),
      child: Row(children: [
        // Rank
        SizedBox(
          width: 36,
          child: data['rank'] <= 3
              ? Text(['🥇', '🥈', '🥉'][data['rank'] - 1], style: const TextStyle(fontSize: 22))
              : Text('#${data['rank']}',
              style: TextStyle(color: _rankColor, fontSize: 15, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        // Avatar
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: _rankColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: _rankColor.withValues(alpha: 0.4)),
          ),
          child: Center(child: Text(data['avatar'], style: const TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 12),
        // Name & km
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(data['name'],
                style: TextStyle(
                    color: _isYou ? AppTheme.accent : AppTheme.textPrimary,
                    fontSize: 15, fontWeight: FontWeight.w700)),
            if (_isYou) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('YOU', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ),
            ]
          ]),
          const SizedBox(height: 3),
          Text('${data['km']} km total',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ])),
        // Tiles
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${data['tiles']}',
              style: TextStyle(
                  color: _rankColor, fontSize: 20, fontWeight: FontWeight.w800)),
          const Text('tiles', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        ]),
      ]),
    );
  }
}
