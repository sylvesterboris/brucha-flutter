import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class KitchenDisplayScreen extends StatefulWidget {
  const KitchenDisplayScreen({super.key});
  @override State<KitchenDisplayScreen> createState() => _KitchenDisplayScreenState();
}

class _KitchenDisplayScreenState extends State<KitchenDisplayScreen> with TickerProviderStateMixin {
  late Timer _ticker;
  // Local status overrides for this KDS session: orderId -> status
  final Map<String, String> _localStatus = {};
  // Track new order flash animation
  final Set<String> _newOrders = {};

  @override
  void initState() {
    super.initState();
    // Refresh every 10s to simulate real-time
    _ticker = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() {});
    });
    // Mark all current orders as "new" for entry animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orders = context.read<AppProvider>().orderHistory;
      setState(() {
        for (final o in orders.take(6)) _newOrders.add(o.id);
      });
    });
  }

  @override void dispose() { _ticker.cancel(); super.dispose(); }

  String _statusFor(OrderRecord order) =>
      _localStatus[order.id] ?? order.status;

  void _advance(OrderRecord order) {
    HapticFeedback.mediumImpact();
    final current = _statusFor(order);
    final next = switch (current) {
      'received'  => 'preparing',
      'preparing' => 'ready',
      'ready'     => 'delivered',
      _           => 'delivered',
    };
    setState(() => _localStatus[order.id] = next);
  }

  Color _statusColor(String s) => switch (s) {
    'received'  => BruchaColors.gold,
    'preparing' => BruchaColors.rust,
    'ready'     => BruchaColors.greenVeg,
    _           => BruchaColors.ink3,
  };

  IconData _statusIcon(String s) => switch (s) {
    'received'  => Icons.receipt_long_outlined,
    'preparing' => Icons.restaurant_outlined,
    'ready'     => Icons.done_all_rounded,
    _           => Icons.check_circle_outline,
  };

  String _statusLabel(String s) => switch (s) {
    'received'  => 'NEW ORDER',
    'preparing' => 'PREPARING',
    'ready'     => 'READY ✓',
    _           => 'DELIVERED',
  };

  String _nextLabel(String s) => switch (s) {
    'received'  => 'Start Preparing →',
    'preparing' => 'Mark Ready →',
    'ready'     => 'Mark Delivered →',
    _           => 'Done',
  };

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final orders = app.orderHistory
        .where((o) => _statusFor(o) != 'delivered')
        .toList();
    final delivered = app.orderHistory
        .where((o) => _statusFor(o) == 'delivered')
        .length;

    // Sort: new first, then preparing, then ready
    orders.sort((a, b) {
      const rank = {'received': 0, 'preparing': 1, 'ready': 2};
      return (rank[_statusFor(a)] ?? 3).compareTo(rank[_statusFor(b)] ?? 3);
    });

    return Scaffold(
      backgroundColor: BruchaColors.ink,
      appBar: AppBar(
        backgroundColor: BruchaColors.ink,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: BruchaColors.gold2, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Kitchen Display', style: GoogleFonts.cormorantGaramond(
              fontSize: 22, fontWeight: FontWeight.w300, color: BruchaColors.gold2, letterSpacing: 2)),
          Text('Live order queue', style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink3, letterSpacing: 1)),
        ]),
        actions: [
          // Stats row
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(children: [
              _StatPill(icon: Icons.pending_outlined, color: BruchaColors.gold,
                  label: '${orders.where((o) => _statusFor(o) == 'received').length} New'),
              const SizedBox(width: 8),
              _StatPill(icon: Icons.restaurant_outlined, color: BruchaColors.rust,
                  label: '${orders.where((o) => _statusFor(o) == 'preparing').length} Cooking'),
              const SizedBox(width: 8),
              _StatPill(icon: Icons.done_all_rounded, color: BruchaColors.greenVeg,
                  label: '$delivered Done'),
            ]),
          ),
        ],
      ),
      body: orders.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('🍽️', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              Text('No active orders', style: GoogleFonts.cormorantGaramond(
                  fontSize: 22, color: BruchaColors.ink3)),
              const SizedBox(height: 4),
              Text('New orders will appear here automatically',
                  style: GoogleFonts.jost(fontSize: 12, color: BruchaColors.ink3)),
            ]))
          : GridView.builder(
              padding: const EdgeInsets.all(14),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemCount: orders.length,
              itemBuilder: (_, i) {
                final order = orders[i];
                final status = _statusFor(order);
                return _KDSCard(
                  order: order,
                  status: status,
                  statusColor: _statusColor(status),
                  statusIcon: _statusIcon(status),
                  statusLabel: _statusLabel(status),
                  nextLabel: _nextLabel(status),
                  timeAgo: _timeAgo(order.createdAt),
                  onAdvance: status == 'delivered' ? null : () => _advance(order),
                  isNew: _newOrders.contains(order.id) && status == 'received',
                );
              },
            ),
    );
  }
}

class _KDSCard extends StatefulWidget {
  final OrderRecord order;
  final String status, statusLabel, nextLabel, timeAgo;
  final Color statusColor;
  final IconData statusIcon;
  final VoidCallback? onAdvance;
  final bool isNew;

  const _KDSCard({
    required this.order, required this.status, required this.statusLabel,
    required this.nextLabel, required this.timeAgo, required this.statusColor,
    required this.statusIcon, this.onAdvance, this.isNew = false,
  });

  @override State<_KDSCard> createState() => _KDSCardState();
}

class _KDSCardState extends State<_KDSCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulse = Tween(begin: 1.0, end: 1.03)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.status == 'received';
    return ScaleTransition(
      scale: isNew ? _pulse : const AlwaysStoppedAnimation(1.0),
      child: Container(
        decoration: BoxDecoration(
          color: BruchaColors.dkSurface,
          border: Border.all(color: widget.statusColor.withOpacity(0.5), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          // Status header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: widget.statusColor.withOpacity(0.12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(children: [
              Icon(widget.statusIcon, color: widget.statusColor, size: 14),
              const SizedBox(width: 6),
              Text(widget.statusLabel, style: GoogleFonts.jost(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: widget.statusColor, letterSpacing: 1)),
              const Spacer(),
              Text(widget.timeAgo, style: GoogleFonts.jost(fontSize: 9, color: BruchaColors.ink3)),
            ]),
          ),

          // Order details
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(widget.order.orderNumber, style: GoogleFonts.cormorantGaramond(
                    fontSize: 20, fontWeight: FontWeight.w600, color: BruchaColors.gold2)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: BruchaColors.ink2, borderRadius: BorderRadius.circular(6)),
                  child: Text('Table ${widget.order.tableNumber}',
                      style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink3)),
                ),
              ]),
              const SizedBox(height: 8),
              // Items
              ...widget.order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('×${item.quantity}  ${item.name}',
                        style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w500,
                            color: BruchaColors.cream), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (item.customSummary.isNotEmpty)
                      Text(item.customSummary,
                          style: GoogleFonts.jost(fontSize: 9, color: BruchaColors.ink3),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                  ])),
                ]),
              )),
            ]),
          ),

          const Spacer(),

          // Action button
          if (widget.onAdvance != null)
            GestureDetector(
              onTap: widget.onAdvance,
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: widget.statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text(widget.nextLabel,
                    style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w700,
                        color: widget.status == 'ready' ? Colors.white : BruchaColors.ink))),
              ),
            ),
        ]),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon; final Color color; final String label;
  const _StatPill({required this.icon, required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      border: Border.all(color: color.withOpacity(0.3)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 12),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.jost(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    ]),
  );
}
