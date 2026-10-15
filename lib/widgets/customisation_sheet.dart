import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

class CustomisationSheet extends StatefulWidget {
  final MenuItem item;
  const CustomisationSheet({super.key, required this.item});

  @override State<CustomisationSheet> createState() => _CustomisationSheetState();
}

class _CustomisationSheetState extends State<CustomisationSheet> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;

  // selections: groupTitle -> Set of selected option labels
  final Map<String, Set<String>> _selections = {};
  double _extraCost = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _slide = Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
    // Default selections
    for (final g in widget.item.customGroups) {
      _selections[g.title] = {g.options.first.label};
    }
    _recalcExtra();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _recalcExtra() {
    double extra = 0;
    for (final g in widget.item.customGroups) {
      for (final opt in g.options) {
        if (_selections[g.title]?.contains(opt.label) == true) {
          extra += opt.extraPrice;
        }
      }
    }
    setState(() => _extraCost = extra);
  }

  void _toggle(CustomGroup group, CustomOption opt) {
    setState(() {
      if (group.multiSelect) {
        if (_selections[group.title]?.contains(opt.label) == true) {
          _selections[group.title]!.remove(opt.label);
        } else {
          _selections.putIfAbsent(group.title, () => {}).add(opt.label);
        }
      } else {
        _selections[group.title] = {opt.label};
      }
    });
    _recalcExtra();
    HapticFeedback.selectionClick();
  }

  void _addToCart() {
    final customisation = CartCustomisation(
      selections: _selections.map((k, v) => MapEntry(k, v.toList())),
      extraCost: _extraCost,
    );
    context.read<CartProvider>().add(widget.item, customisation: customisation);
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.item.price + _extraCost;
    return SlideTransition(
      position: _slide,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: BruchaColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 14),
          Container(width: 38, height: 3.5, decoration: BoxDecoration(color: BruchaColors.parch3, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Text(widget.item.emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.item.name, style: GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.w600, color: BruchaColors.ink)),
                Text(widget.item.description, style: GoogleFonts.jost(fontSize: 11, color: BruchaColors.ink3)),
              ])),
            ]),
          ),
          const OrnamentDivider(),

          // Options
          Flexible(
            child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), shrinkWrap: true,
              children: widget.item.customGroups.map((group) {
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 4),
                    child: Row(children: [
                      Text(group.title, style: GoogleFonts.cormorantGaramond(fontSize: 16, fontWeight: FontWeight.w600, color: BruchaColors.ink)),
                      if (group.multiSelect) ...[
                        const SizedBox(width: 6),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: BruchaColors.parch2, borderRadius: BorderRadius.circular(4)),
                          child: Text('Multi-select', style: GoogleFonts.jost(fontSize: 9, color: BruchaColors.ink3))),
                      ]
                    ]),
                  ),
                  Wrap(spacing: 8, runSpacing: 8,
                    children: group.options.map((opt) {
                      final selected = _selections[group.title]?.contains(opt.label) == true;
                      return GestureDetector(
                        onTap: () => _toggle(group, opt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? BruchaColors.ink : BruchaColors.parch,
                            border: Border.all(color: selected ? BruchaColors.ink : BruchaColors.parch3, width: selected ? 1.5 : 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(opt.label, style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? BruchaColors.gold2 : BruchaColors.ink3)),
                            if (opt.extraPrice > 0) ...[
                              const SizedBox(width: 4),
                              Text('+₹${opt.extraPrice.toInt()}', style: GoogleFonts.jost(fontSize: 10, color: selected ? BruchaColors.gold3 : BruchaColors.ink3)),
                            ],
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ]);
              }).toList(),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: BruchaColors.cream,
              border: Border(top: BorderSide(color: BruchaColors.parch2)),
            ),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Total', style: GoogleFonts.jost(fontSize: 11, color: BruchaColors.ink3)),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text('₹ ${totalPrice.toInt()}',
                    key: ValueKey(totalPrice.toInt()),
                    style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.w600, color: BruchaColors.gold)),
                ),
              ]),
              const SizedBox(width: 16),
              Expanded(child: GoldButton(label: 'Add to Order', onTap: _addToCart)),
            ]),
          ),
        ]),
      ),
    );
  }
}
