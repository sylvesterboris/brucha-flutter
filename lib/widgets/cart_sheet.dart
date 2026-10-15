import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

class CartSheet extends StatefulWidget {
  const CartSheet({super.key});
  @override State<CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends State<CartSheet> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  final _notesCtrl  = TextEditingController();
  final _couponCtrl = TextEditingController();
  bool _placing = false;
  bool _couponError = false;
  bool _showCoupon = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _slide = Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
    context.read<CartProvider>().loadLoyaltyPoints();
  }
  @override void dispose() { _ctrl.dispose(); _notesCtrl.dispose(); _couponCtrl.dispose(); super.dispose(); }

  Future<void> _placeOrder() async {
    if (_placing) return;
    setState(() => _placing = true);
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;
    final cart = context.read<CartProvider>();
    cart.specialNotes = _notesCtrl.text;
    final orderNum = await cart.placeOrder();
    await context.read<AppProvider>().reloadHistory();
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.pushNamed(context, '/success', arguments: orderNum);
  }

  void _applyCoupon() {
    final ok = context.read<CartProvider>().applyCoupon(_couponCtrl.text);
    setState(() => _couponError = !ok);
    if (ok) { HapticFeedback.lightImpact(); _showCoupon = false; }
    else HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return FadeTransition(
      opacity: _ctrl,
      child: SlideTransition(
        position: _slide,
        child: Container(
          decoration: BoxDecoration(color: BruchaColors.cream, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 14),
            Container(width: 38, height: 3.5, decoration: BoxDecoration(color: BruchaColors.parch3, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            // Header
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Your Order', style: GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.w600, color: BruchaColors.ink)),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(border: Border.all(color: BruchaColors.parch3), borderRadius: BorderRadius.circular(20)),
                  child: Text('Table ${cart.tableNumber}', style: GoogleFonts.jost(fontSize: 11, color: BruchaColors.ink3, letterSpacing: 1))),
              ])),
            const SizedBox(height: 4),
            const OrnamentDivider(),

            if (cart.items.isEmpty)
              Padding(padding: const EdgeInsets.symmetric(vertical: 36),
                child: Column(children: [
                  const Text('☕', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text('Your order is empty.', style: GoogleFonts.cormorantGaramond(fontSize: 18, color: BruchaColors.ink3)),
                  Text('Add something wonderful.', style: GoogleFonts.jost(fontSize: 12, color: BruchaColors.ink3)),
                ]))
            else ...[
              // Items
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.32),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shrinkWrap: true,
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => Divider(color: BruchaColors.parch2, height: 1),
                  itemBuilder: (_, i) {
                    final ci = cart.items[i];
                    final key = '${ci.item.id}_${ci.customisation.summary}';
                    return Dismissible(
                      key: Key(key),
                      direction: DismissDirection.endToStart,
                      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), color: BruchaColors.rust.withOpacity(0.15), child: const Icon(Icons.delete_outline, color: BruchaColors.rust)),
                      onDismissed: (_) => cart.removeItem(key),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(children: [
                          Text(ci.item.emoji, style: const TextStyle(fontSize: 26)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(ci.item.name, style: GoogleFonts.cormorantGaramond(fontSize: 15, fontWeight: FontWeight.w600, color: BruchaColors.ink)),
                            if (ci.customisation.summary.isNotEmpty)
                              Text(ci.customisation.summary, style: GoogleFonts.jost(fontSize: 9, color: BruchaColors.ink3)),
                            Text('₹ ${ci.unitPrice.toInt()} each', style: GoogleFonts.jost(fontSize: 11, color: BruchaColors.ink3)),
                          ])),
                          QtyControl(qty: ci.quantity, small: true,
                            onAdd:    () => cart.add(ci.item, customisation: ci.customisation),
                            onRemove: () => cart.decrement(key)),
                          const SizedBox(width: 10),
                          SizedBox(width: 56, child: Text('₹ ${ci.lineTotal.toInt()}', textAlign: TextAlign.right, style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.w500, color: BruchaColors.ink))),
                        ]),
                      ),
                    );
                  },
                ),
              ),

              Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 0), child: Column(children: [
                Divider(color: BruchaColors.parch2),

                // Loyalty points row
                if (cart.loyaltyPoints > 0)
                  GestureDetector(
                    onTap: () { cart.toggleUsePoints(); HapticFeedback.selectionClick(); },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: cart.usePoints ? BruchaColors.gold3.withOpacity(0.3) : BruchaColors.parch,
                        border: Border.all(color: cart.usePoints ? BruchaColors.gold : BruchaColors.parch3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        const Text('⭐', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${cart.loyaltyPoints} Points available', style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w500, color: BruchaColors.ink)),
                          Text('Worth ₹${(cart.loyaltyPoints/10).floor()}', style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink3)),
                        ])),
                        Switch(value: cart.usePoints, onChanged: (_) { cart.toggleUsePoints(); HapticFeedback.selectionClick(); }, activeColor: BruchaColors.gold),
                      ]),
                    ),
                  ),

                // Coupon row
                if (cart.appliedCoupon != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: BruchaColors.greenVegBg, border: Border.all(color: BruchaColors.greenVeg), borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      const Text('🎟️', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${cart.appliedCoupon} applied — −₹${cart.couponDiscount.toInt()}',
                        style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w500, color: BruchaColors.greenVeg))),
                      GestureDetector(onTap: cart.removeCoupon, child: const Icon(Icons.close, size: 16, color: BruchaColors.greenVeg)),
                    ]),
                  )
                else if (_showCoupon)
                  Row(children: [
                    Expanded(child: TextField(
                      controller: _couponCtrl,
                      textCapitalization: TextCapitalization.characters,
                      style: GoogleFonts.jost(fontSize: 13, color: BruchaColors.ink),
                      decoration: InputDecoration(
                        hintText: 'Enter promo code',
                        hintStyle: GoogleFonts.jost(fontSize: 12, color: BruchaColors.ink3),
                        errorText: _couponError ? 'Invalid code' : null,
                        isDense: true,
                      ),
                    )),
                    const SizedBox(width: 8),
                    GestureDetector(onTap: _applyCoupon, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: BruchaColors.ink, borderRadius: BorderRadius.circular(8)),
                      child: Text('Apply', style: GoogleFonts.jost(fontSize: 12, color: BruchaColors.gold2)),
                    )),
                  ])
                else
                  GestureDetector(
                    onTap: () => setState(() { _showCoupon = true; _couponError = false; }),
                    child: Row(children: [
                      Icon(Icons.local_offer_outlined, size: 14, color: BruchaColors.ink3),
                      const SizedBox(width: 6),
                      Text('Add promo code', style: GoogleFonts.jost(fontSize: 12, color: BruchaColors.ink3, decoration: TextDecoration.underline)),
                    ]),
                  ),

                const SizedBox(height: 10),

                // Summary
                _SRow('Subtotal', '₹ ${cart.subtotal.toInt()}'),
                const SizedBox(height: 4),
                _SRow('GST (5%)', '₹ ${cart.gst.toInt()}'),
                if (cart.couponDiscount > 0) ...[const SizedBox(height: 4), _SRow('Coupon Discount', '−₹ ${cart.couponDiscount.toInt()}', color: BruchaColors.greenVeg)],
                if (cart.usePoints && cart.pointsValue > 0) ...[const SizedBox(height: 4), _SRow('Points Redeemed', '−₹ ${cart.pointsValue.toInt()}', color: BruchaColors.gold)],
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Total', style: GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.w600, color: BruchaColors.ink)),
                  AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: Text('₹ ${cart.grandTotal.toInt()}', key: ValueKey(cart.grandTotal.toInt()), style: GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.w600, color: BruchaColors.gold))),
                ]),
                // Earn points note
                Padding(padding: const EdgeInsets.only(top: 4),
                  child: Text('You\'ll earn ${cart.earnedPoints} points with this order ⭐',
                    style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink3, fontStyle: FontStyle.italic))),

                const SizedBox(height: 12),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  style: GoogleFonts.jost(fontSize: 13, color: BruchaColors.ink),
                  decoration: InputDecoration(hintText: 'Notes for the kitchen — allergies, preferences…', hintStyle: GoogleFonts.jost(fontSize: 12, color: BruchaColors.ink3)),
                ),
                const SizedBox(height: 14),
                GoldButton(label: 'Place Order · Table ${cart.tableNumber}', onTap: _placeOrder, loading: _placing),
                const SizedBox(height: 28),
              ])),
            ],
          ]),
        ),
      ),
    );
  }
}

class _SRow extends StatelessWidget {
  final String l, v;
  final Color? color;
  const _SRow(this.l, this.v, {this.color});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(l, style: GoogleFonts.jost(fontSize: 13, color: BruchaColors.ink3)),
    Text(v, style: GoogleFonts.jost(fontSize: 13, color: color ?? BruchaColors.ink3)),
  ]);
}
