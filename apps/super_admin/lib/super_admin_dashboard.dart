import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import 'config.dart';
import 'session/auth_session.dart';
import 'theme/app_theme.dart';
import 'utils/formatters.dart';
import 'widgets/dashboard_card.dart';
import 'widgets/metric_tile.dart';

/// The Director / Super Admin control room.
///
/// Everything on this screen is backed by real endpoints on the Marbiks ERP
/// backend (`GET /reports/revenue`, `GET /reports/leakage`) via the shared
/// [ApiClient] from `packages/api_client` - there is no simulated or
/// fabricated data anywhere on this screen. Two things are deliberately
/// scoped out rather than faked:
///
///  - Franchise royalty settlement: the backend has no Franchise entity or
///    royalty calculation yet, so that panel is an honest "not built" state,
///    not a placeholder with made-up numbers.
///  - "Live" means polling (see [dashboardRefreshInterval] in config.dart),
///    not a push/WebSocket feed - the UI says so rather than implying a
///    lower latency than it actually has.
class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  ApiClient get _apiClient => context.read<AuthSession>().apiClient;

  RevenueSummary? _revenue;
  LeakageReport? _leakage;
  DateTime? _lastSyncedAt;

  late DateTime _from;
  late DateTime _to;
  int _unpaidDays = 3;

  bool _isFirstLoad = true;
  bool _isRefreshing = false;
  String? _error;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _from = DateTime(now.year, now.month, 1);
    _to = now;
    _loadAll();
    _refreshTimer = Timer.periodic(dashboardRefreshInterval, (_) => _loadAll(silent: true));
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAll({bool silent = false}) async {
    if (!silent) {
      setState(() => _isRefreshing = true);
    }
    try {
      final results = await Future.wait([
        _apiClient.getRevenueSummary(from: _from, to: _to),
        _apiClient.getLeakageReport(unpaidDays: _unpaidDays),
      ]);
      if (!mounted) return;
      setState(() {
        _revenue = results[0] as RevenueSummary;
        _leakage = results[1] as LeakageReport;
        _lastSyncedAt = DateTime.now();
        _error = null;
        _isFirstLoad = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 730)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _from, end: _to),
      builder: (context, child) => Theme(data: Theme.of(context), child: child!),
    );
    if (picked != null) {
      setState(() {
        _from = picked.start;
        _to = picked.end;
      });
      _loadAll();
    }
  }

  void _changeUnpaidDays(int days) {
    setState(() => _unpaidDays = days);
    _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marbiks Control Room'),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : () => _loadAll(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => session.logout(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isFirstLoad
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSyncBar(context),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorBanner(_error!),
                    ],
                    const SizedBox(height: 20),
                    _responsiveGrid(context, [
                      _buildRevenuePanel(context),
                      _buildGstPanel(context),
                      _buildLeakagePanel(context),
                      _buildFranchisePanel(context),
                    ]),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSyncBar(BuildContext context) {
    final user = context.read<AuthSession>().user;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back${user != null ? ', ${user.fullName}' : ''}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 2),
              Text(
                _lastSyncedAt == null
                    ? 'Syncing…'
                    : 'Last synced ${formatDateTimeReadable(_lastSyncedAt!)} · '
                        'polling every ${dashboardRefreshInterval.inSeconds}s',
                style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
            ],
          ),
        ),
        const StatusBadge(label: 'POLLING · NOT PUSH', color: AppColors.info),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: AppColors.textPrimary))),
        ],
      ),
    );
  }

  Widget _responsiveGrid(BuildContext context, List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns = 1;
        if (width >= 1200) {
          columns = 3;
        } else if (width >= 760) {
          columns = 2;
        }
        const spacing = 16.0;
        final itemWidth = columns == 1
            ? width
            : (width - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(growable: false),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // Panel 1: Revenue Ticker
  // ---------------------------------------------------------------------
  Widget _buildRevenuePanel(BuildContext context) {
    final revenue = _revenue;
    return DashboardCard(
      title: 'Revenue Ticker',
      icon: Icons.trending_up,
      accentColor: AppColors.gold,
      trailing: TextButton.icon(
        onPressed: _pickDateRange,
        icon: const Icon(Icons.date_range, size: 16, color: AppColors.gold),
        label: Text(
          '${formatDateShort(_from)} - ${formatDateShort(_to)}',
          style: const TextStyle(color: AppColors.gold, fontSize: 12),
        ),
      ),
      child: revenue == null
          ? const _EmptyState(message: 'No revenue data for this range yet.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MetricTile(
                  label: 'TOTAL BILLED',
                  value: formatRupees(revenue.totalBilled),
                  caption: '${revenue.branchCount} branch'
                      '${revenue.branchCount == 1 ? '' : 'es'} reporting',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MetricTile(
                        label: 'COLLECTED',
                        value: formatRupees(revenue.totalCollected),
                        valueColor: AppColors.positive,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MetricTile(
                        label: 'OUTSTANDING',
                        value: formatRupees(revenue.totalOutstanding),
                        valueColor: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text('By branch', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: revenue.branches.isEmpty
                      ? const _EmptyState(message: 'No branches found.')
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: revenue.branches.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final branch = revenue.branches[index];
                            final total = double.tryParse(revenue.totalBilled) ?? 0;
                            final share = total > 0
                                ? (double.tryParse(branch.totalBilled) ?? 0) / total
                                : 0.0;
                            return _BranchRow(
                              name: branch.branchName,
                              amount: formatRupees(branch.totalBilled),
                              invoiceCount: branch.invoiceCount,
                              share: share.clamp(0, 1).toDouble(),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------
  // Panel 2: GST Liability
  // ---------------------------------------------------------------------
  Widget _buildGstPanel(BuildContext context) {
    final revenue = _revenue;
    return DashboardCard(
      title: 'GST Tax Liability',
      icon: Icons.receipt_long_outlined,
      accentColor: AppColors.info,
      child: revenue == null
          ? const _EmptyState(message: 'No tax data for this range yet.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MetricTile(
                  label: 'TOTAL GST COLLECTED',
                  value: formatRupees(revenue.totalTax),
                  valueColor: AppColors.info,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MetricTile(
                        label: 'CGST (9%)',
                        value: formatRupees(revenue.cgst),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MetricTile(
                        label: 'SGST (9%)',
                        value: formatRupees(revenue.sgst),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Computed from real invoice tax totals. Assumes intra-state sales '
                  '(CGST = SGST = half of total GST). The backend does not yet '
                  'distinguish inter-state (IGST) invoices, so treat this split as '
                  'directional, not filing-ready.',
                  style: const TextStyle(color: AppColors.textTertiary, fontSize: 11, height: 1.4),
                ),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------
  // Panel 3: Leakage & anomaly detection
  // ---------------------------------------------------------------------
  Widget _buildLeakagePanel(BuildContext context) {
    final leakage = _leakage;
    return DashboardCard(
      title: 'Revenue Leakage Signals',
      icon: Icons.warning_amber_rounded,
      accentColor: AppColors.warning,
      trailing: const StatusBadge(label: 'REAL DATA · NOT AI', color: AppColors.textSecondary),
      child: leakage == null
          ? const _EmptyState(message: 'No leakage data yet.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MetricTile(
                        label: 'UNBILLED COMPLETED VISITS',
                        value: '${leakage.unbilledCompleted.length}',
                        valueColor: leakage.unbilledCompleted.isEmpty
                            ? AppColors.positive
                            : AppColors.danger,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MetricTile(
                        label: 'OVERDUE INVOICES',
                        value: '${leakage.overdueInvoices.length}',
                        caption: formatRupees(leakage.overdueTotalAmount),
                        valueColor: leakage.overdueInvoices.isEmpty
                            ? AppColors.positive
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Unpaid threshold', style: Theme.of(context).textTheme.bodyMedium),
                    const Spacer(),
                    ...[3, 7, 14, 30].map(
                      (days) => Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: ChoiceChip(
                          label: Text('${days}d'),
                          selected: _unpaidDays == days,
                          onSelected: (_) => _changeUnpaidDays(days),
                          selectedColor: AppColors.gold.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: _unpaidDays == days ? AppColors.gold : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          backgroundColor: AppColors.surfaceRaised,
                          side: BorderSide(
                            color: _unpaidDays == days ? AppColors.gold : AppColors.border,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                if (leakage.unbilledCompleted.isEmpty && leakage.overdueInvoices.isEmpty)
                  const _EmptyState(message: 'Nothing flagged - everything is billed and paid.')
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        if (leakage.unbilledCompleted.isNotEmpty) ...[
                          Text(
                            'Completed but never invoiced',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          ...leakage.unbilledCompleted.map(
                            (item) => _LeakageRow(
                              title: item.serviceName,
                              subtitle: '${item.branchName} · ${formatDateShort(item.startTime)}',
                              trailing: null,
                              color: AppColors.danger,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (leakage.overdueInvoices.isNotEmpty) ...[
                          Text('Unpaid past threshold', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          ...leakage.overdueInvoices.map(
                            (invoice) => _LeakageRow(
                              title: invoice.invoiceNumber,
                              subtitle: '${invoice.branchName} · ${invoice.daysOverdue}d overdue',
                              trailing: formatRupees(invoice.total),
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------
  // Panel 4: Franchise royalty - explicitly deferred, no fabricated data
  // ---------------------------------------------------------------------
  Widget _buildFranchisePanel(BuildContext context) {
    return DashboardCard(
      title: 'Franchise Royalty Settlement',
      icon: Icons.storefront_outlined,
      accentColor: AppColors.textSecondary,
      trailing: const StatusBadge(label: 'NOT YET AVAILABLE', color: AppColors.textSecondary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.construction_outlined, color: AppColors.textTertiary, size: 28),
          const SizedBox(height: 12),
          Text(
            'This panel is deliberately empty.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'There is no Franchise entity, franchise-owner data, or royalty '
            'calculation in the backend yet, so there is nothing real to show '
            'here. Rather than display invented numbers, this panel will start '
            'reporting once that module is built - a real "which branches are '
            'franchises" model plus a 5% royalty calculation off actual branch '
            'revenue (see docs/PHASE_5.md).',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _BranchRow extends StatelessWidget {
  final String name;
  final String amount;
  final int invoiceCount;
  final double share;

  const _BranchRow({
    required this.name,
    required this.amount,
    required this.invoiceCount,
    required this.share,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$invoiceCount inv',
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
            ),
            const SizedBox(width: 10),
            Text(
              amount,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: share == 0 ? 0.001 : share,
            minHeight: 4,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
          ),
        ),
      ],
    );
  }
}

class _LeakageRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;
  final Color color;

  const _LeakageRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                Text(subtitle, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(message, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
    );
  }
}
