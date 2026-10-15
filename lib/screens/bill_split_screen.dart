import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

// A lightweight in-memory split session (no backend needed for demo)
class SplitSession {
  final String tableNumber;
  final Map<String, List<_SplitItem>> participants; // name -> items
  SplitSession({required this.tableNumber}) : participants = {};
}

class _SplitItem {
  final MenuItem item;
  int quantity;
  _SplitItem(this.item, this.quantity);
  double get total => item.price * quantity;
}

class BillSplitScreen extends StatefulWidget {
  const BillSplitScreen({super.key});
  @override State<BillSplitScreen> createState() => _BillSplitScreenState();
}

class _BillSplitScreenState extends State<BillSplitScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<String> _participants = ['You'];
  int _activeParticipant = 0;
  final Map<String, List<_SplitItem>> _orders = {'You': []};
  final _nameCtrl = TextEditingController();
  bool _showAddPerson = false;

  // Available menu items to add
  MenuCategory? _filterCat;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); _nameCtrl.dispose(); super.dispose(); }

  String get _activeName => _participants[_activeParticipant];
  List<_SplitItem> get _activeItems => _orders[_activeName] ?? [];

  double _totalFor(String name) =>
      (_orders[name] ?? []).fold(0.0, (s, i) => s + i.total);

  double get _grandTotal =>
      _participants.fold(0.0, (s, n) => s + _totalFor(n));

  double get _grandTotalWithGST => _grandTotal * 1.05;

  void _addParticipant() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _participants.contains(name)) return;
    setState(() {
      _participants.add(name);
      _orders[name] = [];
      _nameCtrl.clear();
      _showAddPerson = false;
      _activeParticipant = _participants.length - 1;
    });
    HapticFeedback.selectionClick();
  }

  void _addItem(MenuItem item) {
    setState(() {
      final existing = _activeItems.where((i) => i.item.id == item.id).firstOrNull;
      if (existing != null) {
        existing.quantity++;
      } else {
        _orders[_activeName]!.add(_SplitItem(item, 1));
      }
    });
    HapticFeedback.lightImpact();
  }

  void _removeItem(MenuItem item) {
    setState(() {
      final existing = _activeItems.where((i) => i.item.id == item.id).firstOrNull;
      if (existing != null) {
        if (existing.quantity <= 1) {
          _orders[_activeName]!.remove(existing);
        } else {
          existing.quantity--;
        }
      }
    });
    HapticFeedback.lightImpact();
  }

  void _confirmOrder(BuildContext ctx) {
    // Add all split items to the main cart
    final cart = ctx.read<CartProvider>();
    for (final name in _participants) {
      for (final si in _orders[name] ?? []) {
        for (int q = 0; q < si.quantity; q++) {
          cart.add(si.item);
        }
      }
    }
    HapticFeedback.heavyImpact();
    Navigator.pop(ctx);
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text('Split order added to cart! ${_participants.length} people · ₹${_grandTotalWithGST.toInt()} total',
          style: GoogleFonts.jost(color: Colors.white)),
      backgroundColor: BruchaColors.ink2,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final filteredMenu = _filterCat == null
        ? kMenu
        : kMenu.where((i) => i.category == _filterCat).toList();

    return Scaffold(
      backgroundColor: BruchaColors.parch,
      appBar: AppBar(
        backgroundColor: BruchaColors.ink,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: BruchaColors.gold2, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Split the Bill', style: GoogleFonts.cormorantGaramond(
              fontSize: 22, fontWeight: FontWeight.w300, color: BruchaColors.gold2, letterSpacing: 2)),
          Text('Table ${cart.tableNumber} · ${_participants.length} people',
              style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink3, letterSpacing: 1)),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: Text('₹${_grandTotalWithGST.toInt()} total',
                style: GoogleFonts.cormorantGaramond(fontSize: 16, fontWeight: FontWeight.w600, color: BruchaColors.gold2))),
          ),
        ],
      ),
      body: Column(children: [
        // ── Participant tabs ────────────────────────────────────────────────
        Container(
          color: BruchaColors.ink,
          child: Column(children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: Row(children: [
                ..._participants.asMap().entries.map((e) {
                  final active = e.key == _activeParticipant;
                  final total = _totalFor(e.value);
                  return GestureDetector(
                    onTap: () { setState(() => _activeParticipant = e.key); HapticFeedback.selectionClick(); },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? BruchaColors.gold : BruchaColors.ink2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: active ? BruchaColors.gold : BruchaColors.dkBorder),
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(e.value, style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w600,
                            color: active ? BruchaColors.ink : BruchaColors.gold3)),
                        if (total > 0)
                          Text('₹${total.toInt()}', style: GoogleFonts.jost(fontSize: 10,
                              color: active ? BruchaColors.ink2 : BruchaColors.ink3)),
                      ]),
                    ),
                  );
                }),
                // Add person button
                GestureDetector(
                  onTap: () => setState(() => _showAddPerson = !_showAddPerson),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      border: Border.all(color: BruchaColors.gold.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(child: Icon(Icons.person_add_outlined, color: BruchaColors.gold, size: 18)),
                  ),
                ),
              ]),
            ),
            // Add person input
            if (_showAddPerson)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Row(children: [
                  Expanded(child: TextField(
                    controller: _nameCtrl,
                    autofocus: true,
                    style: GoogleFonts.jost(fontSize: 13, color: BruchaColors.cream),
                    decoration: InputDecoration(
                      hintText: 'Person\'s name…',
                      hintStyle: GoogleFonts.jost(fontSize: 12, color: BruchaColors.ink3),
                      filled: true, fillColor: BruchaColors.ink2,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addParticipant(),
                  )),
                  const SizedBox(width: 8),
                  GestureDetector(onTap: _addParticipant, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(color: BruchaColors.gold, borderRadius: BorderRadius.circular(8)),
                    child: Text('Add', style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w600, color: BruchaColors.ink)),
                  )),
                ]),
              ),
          ]),
        ),

        Expanded(child: Row(children: [
          // ── Menu picker (left) ──────────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Column(children: [
              // Category filter
              Container(
                color: BruchaColors.cream,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: Row(children: [
                    _CatChip(label: 'All', selected: _filterCat == null, onTap: () => setState(() => _filterCat = null)),
                    ...MenuCategory.values.map((cat) => _CatChip(
                      label: cat.tabEmoji,
                      selected: _filterCat == cat,
                      onTap: () => setState(() => _filterCat = cat),
                    )),
                  ]),
                ),
              ),
              Divider(height: 1, color: BruchaColors.parch3),
              Expanded(child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: filteredMenu.length,
                itemBuilder: (_, i) {
                  final item = filteredMenu[i];
                  final qtyInOrder = (_activeItems.where((s) => s.item.id == item.id).firstOrNull?.quantity ?? 0);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: qtyInOrder > 0 ? BruchaColors.parch : BruchaColors.cream,
                      border: Border.all(color: qtyInOrder > 0 ? BruchaColors.gold : BruchaColors.parch3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      Text(item.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.name, style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w500, color: BruchaColors.ink), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('₹${item.price.toInt()}', style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink3)),
                      ])),
                      if (qtyInOrder > 0)
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          _MiniBtn(icon: Icons.remove, onTap: () => _removeItem(item)),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text('$qtyInOrder', style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.w700, color: BruchaColors.gold))),
                          _MiniBtn(icon: Icons.add, onTap: () => _addItem(item), filled: true),
                        ])
                      else
                        _MiniBtn(icon: Icons.add, onTap: () => _addItem(item), filled: true),
                    ]),
                  );
                },
              )),
            ]),
          ),

          // ── Per-person summary (right) ──────────────────────────────────────
          Container(width: 1, color: BruchaColors.parch3),
          Expanded(
            flex: 2,
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: BruchaColors.parch2,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_activeName, style: GoogleFonts.cormorantGaramond(fontSize: 16, fontWeight: FontWeight.w600, color: BruchaColors.ink)),
                  Text('₹${(_totalFor(_activeName) * 1.05).toInt()} incl. GST',
                      style: GoogleFonts.jost(fontSize: 11, color: BruchaColors.ink3)),
                ]),
              ),
              Divider(height: 1, color: BruchaColors.parch3),
              Expanded(child: _activeItems.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('🛒', style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 6),
                    Text('Nothing added', style: GoogleFonts.jost(fontSize: 11, color: BruchaColors.ink3)),
                  ]))
                : ListView(padding: const EdgeInsets.all(10), children: _activeItems.map((si) =>
                    Padding(padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        Text(si.item.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Expanded(child: Text(si.item.name,
                            style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink),
                            maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Text('×${si.quantity}', style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink3)),
                        const SizedBox(width: 4),
                        Text('₹${si.total.toInt()}', style: GoogleFonts.jost(fontSize: 10, fontWeight: FontWeight.w600, color: BruchaColors.gold)),
                      ]),
                    )).toList(),
                ),
              ),
              // All person totals
              Container(
                padding: const EdgeInsets.all(10),
                color: BruchaColors.parch2,
                child: Column(children: [
                  ..._participants.map((name) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(name, style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink3)),
                      Text('₹${(_totalFor(name) * 1.05).toInt()}',
                          style: GoogleFonts.jost(fontSize: 10, fontWeight: FontWeight.w600, color: BruchaColors.ink)),
                    ]),
                  )),
                  Divider(color: BruchaColors.parch3),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Total', style: GoogleFonts.cormorantGaramond(fontSize: 14, fontWeight: FontWeight.w600, color: BruchaColors.ink)),
                    Text('₹${_grandTotalWithGST.toInt()}',
                        style: GoogleFonts.cormorantGaramond(fontSize: 14, fontWeight: FontWeight.w600, color: BruchaColors.gold)),
                  ]),
                ]),
              ),
            ]),
          ),
        ])),

        // ── Place order button ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          color: BruchaColors.cream,
          child: GoldButton(
            label: _grandTotal == 0
                ? 'Add items to place order'
                : 'Confirm Split Order · ₹${_grandTotalWithGST.toInt()}',
            onTap: _grandTotal > 0 ? () => _confirmOrder(context) : null,
          ),
        ),
      ]),
    );
  }
}

class _CatChip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _CatChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? BruchaColors.ink : Colors.transparent,
        border: Border.all(color: selected ? BruchaColors.ink : BruchaColors.parch3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(label, style: GoogleFonts.jost(fontSize: 12, color: selected ? BruchaColors.gold2 : BruchaColors.ink3)),
    ),
  );
}

class _MiniBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap; final bool filled;
  const _MiniBtn({required this.icon, required this.onTap, this.filled = false});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        color: filled ? BruchaColors.ink : BruchaColors.parch2,
        border: Border.all(color: filled ? BruchaColors.ink : BruchaColors.parch3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 14, color: filled ? BruchaColors.gold2 : BruchaColors.ink2),
    ),
  );
}
