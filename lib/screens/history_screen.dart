import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../providers/app_provider.dart';
import '../models/menu_item.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final cart = context.read<CartProvider>();
    final history = app.orderHistory;
    final points = cart.loyaltyPoints;

    return Scaffold(
      backgroundColor: BruchaColors.parch,
      appBar: AppBar(
        backgroundColor: BruchaColors.ink,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: BruchaColors.gold2, size: 18), onPressed: () => Navigator.pop(context)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Order History', style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.w300, color: BruchaColors.gold2, letterSpacing: 2)),
          Text('Table ${cart.tableNumber}', style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink3, letterSpacing: 1.5)),
        ]),
      ),
      body: Column(children: [
        // Loyalty card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: BruchaColors.ink,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            const Text('⭐', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Loyalty Points', style: GoogleFonts.jost(fontSize: 11, color: BruchaColors.ink3, letterSpacing: 1)),
              Text('$points pts', style: GoogleFonts.cormorantGaramond(fontSize: 28, fontWeight: FontWeight.w600, color: BruchaColors.gold2)),
              Text('Worth ₹${(points/10).floor()} · Earn 1 pt per ₹10 spent',
                style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink3)),
            ])),
            // Punch card visual
            Column(children: List.generate(2, (row) => Row(
              children: List.generate(5, (col) {
                final idx = row*5+col;
                final filled = idx < (points / 50).floor().clamp(0, 10);
                return Container(margin: const EdgeInsets.all(2), width: 14, height: 14,
                  decoration: BoxDecoration(color: filled ? BruchaColors.gold : BruchaColors.ink2, shape: BoxShape.circle,
                    border: Border.all(color: BruchaColors.ink3.withOpacity(0.4))));
              }),
            ))),
          ]),
        ),

        // History list
        if (history.isEmpty)
          Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('☕', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            Text('No orders yet', style: GoogleFonts.cormorantGaramond(fontSize: 20, color: BruchaColors.ink3)),
            const SizedBox(height: 4),
            Text('Your order history will appear here.', style: GoogleFonts.jost(fontSize: 12, color: BruchaColors.ink3)),
          ])))
        else
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: history.length,
            itemBuilder: (_, i) => _OrderCard(order: history[i], onReorder: () {
              // Re-add all items to cart
              for (final oi in history[i].items) {
                final item = kMenu.firstWhere((m) => m.id == oi.itemId, orElse: () => kMenu.first);
                for (int q = 0; q < oi.quantity; q++) {
                  cart.add(item);
                }
              }
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Items from ${history[i].orderNumber} added to your cart!', style: GoogleFonts.jost(color: Colors.white)),
                backgroundColor: BruchaColors.ink2,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ));
            }),
          )),
      ]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderRecord order;
  final VoidCallback onReorder;
  const _OrderCard({required this.order, required this.onReorder});

  @override
  Widget build(BuildContext context) {
    final timeAgo = _timeAgo(order.createdAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: BruchaColors.cream, border: Border.all(color: BruchaColors.parch3), borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(order.orderNumber, style: GoogleFonts.cormorantGaramond(fontSize: 18, fontWeight: FontWeight.w600, color: BruchaColors.ink)),
            Text('$timeAgo · Table ${order.tableNumber}', style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink3)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₹ ${order.total.toInt()}', style: GoogleFonts.cormorantGaramond(fontSize: 18, fontWeight: FontWeight.w600, color: BruchaColors.gold)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: BruchaColors.greenVegBg, borderRadius: BorderRadius.circular(4)),
              child: Text(order.status.toUpperCase(), style: GoogleFonts.jost(fontSize: 8, fontWeight: FontWeight.w600, color: BruchaColors.greenVeg, letterSpacing: 1))),
          ]),
        ])),

        Divider(color: BruchaColors.parch2, height: 1),

        // Items
        Padding(padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: Column(children: order.items.map((oi) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              Text(oi.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(oi.name, style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w500, color: BruchaColors.ink)),
                if (oi.customSummary.isNotEmpty) Text(oi.customSummary, style: GoogleFonts.jost(fontSize: 9, color: BruchaColors.ink3)),
              ])),
              Text('×${oi.quantity}', style: GoogleFonts.jost(fontSize: 11, color: BruchaColors.ink3)),
              const SizedBox(width: 10),
              Text('₹${(oi.price * oi.quantity).toInt()}', style: GoogleFonts.jost(fontSize: 12, color: BruchaColors.ink3)),
            ]),
          )).toList()),
        ),

        // Reorder button
        Padding(padding: const EdgeInsets.all(14), child: GestureDetector(
          onTap: onReorder,
          child: Container(
            width: double.infinity, height: 40,
            decoration: BoxDecoration(border: Border.all(color: BruchaColors.ink), borderRadius: BorderRadius.circular(6)),
            child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.refresh_rounded, size: 15, color: BruchaColors.ink),
              const SizedBox(width: 6),
              Text('Reorder', style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w600, color: BruchaColors.ink)),
            ])),
          ),
        )),
      ]),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
