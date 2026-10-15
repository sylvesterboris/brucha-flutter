import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';
import 'customisation_sheet.dart';

class MenuItemCard extends StatefulWidget {
  final MenuItem item;
  final int index;
  final bool isHindi;
  const MenuItemCard({super.key, required this.item, required this.index, this.isHindi = false});

  @override State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _scale = Tween(begin: 1.0, end: 1.02).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _openCustomisation(BuildContext ctx) {
    if (widget.item.customGroups.isEmpty) {
      HapticFeedback.lightImpact();
      ctx.read<CartProvider>().add(widget.item);
      return;
    }
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomisationSheet(item: widget.item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart   = context.watch<CartProvider>();
    final app    = context.watch<AppProvider>();
    final qty    = cart.quantityOf(widget.item.id);
    final inCart = qty > 0;
    final avail  = app.isAvailable(widget.item.id);
    final isFav  = app.isFavourite(widget.item.id);
    final name   = widget.isHindi && widget.item.nameHi.isNotEmpty ? widget.item.nameHi : widget.item.name;
    final desc   = widget.isHindi && widget.item.descriptionHi.isNotEmpty ? widget.item.descriptionHi : widget.item.description;

    return MouseRegion(
      onEnter: (_) => _ctrl.forward(),
      onExit:  (_) => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedOpacity(
          opacity: avail ? 1.0 : 0.55,
          duration: const Duration(milliseconds: 300),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: inCart ? BruchaColors.parch : BruchaColors.cream,
              border: Border.all(color: inCart ? BruchaColors.gold : BruchaColors.parch3, width: inCart ? 1.5 : 1),
              borderRadius: BorderRadius.circular(6),
              boxShadow: inCart ? [BoxShadow(color: BruchaColors.ink.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))] : [],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── Image ──────────────────────────────────────────────────
              Stack(children: [
                Container(
                  height: 100, width: double.infinity,
                  decoration: BoxDecoration(
                    color: inCart ? BruchaColors.parch2 : BruchaColors.parch,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                  ),
                  child: Center(child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.7, end: 1.0),
                    duration: Duration(milliseconds: 300 + widget.index * 40),
                    curve: Curves.elasticOut,
                    builder: (_, v, child) => Transform.scale(scale: v, child: child),
                    child: Text(widget.item.emoji, style: const TextStyle(fontSize: 44)),
                  )),
                ),
                // Gradient
                Positioned(bottom: 0, left: 0, right: 0,
                  child: Container(height: 24, decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, (inCart ? BruchaColors.parch2 : BruchaColors.parch).withOpacity(0.9)]),
                  )),
                ),
                if (widget.item.badge != BadgeType.none)
                  Positioned(top: 8, right: 8, child: BadgeChip(widget.item.badge)),
                // Favourite heart
                Positioned(top: 8, left: 8,
                  child: GestureDetector(
                    onTap: () => app.toggleFavourite(widget.item.id),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        key: ValueKey(isFav),
                        size: 18,
                        color: isFav ? Colors.redAccent : BruchaColors.ink3,
                      ),
                    ),
                  ),
                ),
                // Sold out overlay
                if (!avail)
                  Positioned.fill(child: Container(
                    decoration: BoxDecoration(color: Colors.black38, borderRadius: const BorderRadius.vertical(top: Radius.circular(5))),
                    child: Center(child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: BruchaColors.rust, borderRadius: BorderRadius.circular(4)),
                      child: Text('Sold Out', style: GoogleFonts.jost(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                    )),
                  )),
              ]),

              // ── Body ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(11, 10, 11, 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: GoogleFonts.cormorantGaramond(fontSize: 14, fontWeight: FontWeight.w600, color: BruchaColors.ink, height: 1.25), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  // Rating
                  StarRatingDisplay(rating: widget.item.displayRating, count: widget.item.ratingCount),
                  const SizedBox(height: 2),
                  Text(desc, style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink3, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('₹ ${widget.item.price.toInt()}',
                      style: GoogleFonts.cormorantGaramond(fontSize: 16, fontWeight: FontWeight.w600, color: BruchaColors.gold)),
                    if (!avail)
                      Text('Unavailable', style: GoogleFonts.jost(fontSize: 9, color: BruchaColors.ink3))
                    else AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                      child: qty == 0
                          ? _AddButton(key: const ValueKey('add'), onTap: () { HapticFeedback.lightImpact(); _openCustomisation(context); })
                          : QtyControl(key: const ValueKey('qty'), qty: qty, small: true,
                              onAdd: () { HapticFeedback.lightImpact(); _openCustomisation(context); },
                              onRemove: () {
                                HapticFeedback.lightImpact();
                                final cartItems = context.read<CartProvider>().items
                                    .where((c) => c.item.id == widget.item.id).toList();
                                if (cartItems.isNotEmpty) {
                                  final k = '${widget.item.id}_${cartItems.first.customisation.summary}';
                                  context.read<CartProvider>().decrement(k);
                                }
                              }),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AddButton({super.key, required this.onTap});
  @override State<_AddButton> createState() => _AddButtonState();
}
class _AddButtonState extends State<_AddButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  @override void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 110)); _scale = Tween(begin: 1.0, end: 0.85).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _ctrl.forward(),
    onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
    onTapCancel: () => _ctrl.reverse(),
    child: ScaleTransition(scale: _scale, child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(color: BruchaColors.ink, borderRadius: BorderRadius.circular(5)),
      child: Center(child: Icon(Icons.add, color: BruchaColors.gold2, size: 18)),
    )),
  );
}
