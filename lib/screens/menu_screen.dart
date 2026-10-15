import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/menu_item.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/menu_card.dart';
import '../widgets/cart_sheet.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  MenuCategory? _selectedCat;
  String _search = '';
  late AnimationController _heroCtrl;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late ScrollController _scrollCtrl;
  bool _isScrolled = false;
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _heroFade  = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));
    _heroCtrl.forward();
    _scrollCtrl = ScrollController()..addListener(() {
      final s = _scrollCtrl.offset > 60;
      if (s != _isScrolled) setState(() => _isScrolled = s);
    });
  }
  @override void dispose() { _heroCtrl.dispose(); _scrollCtrl.dispose(); _searchCtrl.dispose(); super.dispose(); }

  void _openCart() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), child: const CartSheet()),
    );
  }

  void _callWaiter() {
    HapticFeedback.heavyImpact();
    context.read<AppProvider>().callWaiter();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Text('🔔', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Text('Waiter notified for Table ${context.read<CartProvider>().tableNumber}',
          style: GoogleFonts.jost(fontSize: 13, color: Colors.white)),
      ]),
      backgroundColor: BruchaColors.ink2,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cart  = context.watch<CartProvider>();
    final app   = context.watch<AppProvider>();
    final count = cart.totalCount;
    final isHindi = app.locale.languageCode == 'hi';
    final filtered = app.filteredMenu(_selectedCat, _search);
    final cats = filtered.map((i) => i.category).toSet().toList()..sort((a,b)=>a.index.compareTo(b.index));
    final favIds = app.favourites;
    final favItems = kMenu.where((i) => favIds.contains(i.id)).toList();

    return Scaffold(
      backgroundColor: BruchaColors.parch,
      drawer: Drawer(
        backgroundColor: BruchaColors.ink,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              color: BruchaColors.ink2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Brucha', style: GoogleFonts.cormorantGaramond(fontSize: 28, fontWeight: FontWeight.w300, color: BruchaColors.gold2, letterSpacing: 2)),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, color: BruchaColors.gold2, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Text('COFFEE & KITCHEN', style: GoogleFonts.jost(fontSize: 9, color: BruchaColors.gold.withOpacity(0.7), letterSpacing: 3)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(border: Border.all(color: BruchaColors.ink3), borderRadius: BorderRadius.circular(20)),
                    child: Text('Table ${cart.tableNumber} · Active Session', style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.gold3, letterSpacing: 1)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                children: [
                  ListTile(
                    leading: Icon(Icons.restaurant_menu_outlined, color: BruchaColors.gold3, size: 20),
                    title: Text(isHindi ? 'मेन्यू' : 'Explore Menu', style: GoogleFonts.jost(fontSize: 13, color: BruchaColors.cream)),
                    onTap: () => Navigator.pop(context),
                    dense: true,
                  ),
                  ListTile(
                    leading: Icon(Icons.history_rounded, color: BruchaColors.gold3, size: 20),
                    title: Text(isHindi ? 'ऑर्डर इतिहास' : 'Order History & Points', style: GoogleFonts.jost(fontSize: 13, color: BruchaColors.cream)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/history');
                    },
                    dense: true,
                  ),
                  ListTile(
                    leading: Icon(Icons.people_outline, color: BruchaColors.gold3, size: 20),
                    title: Text(isHindi ? 'बिल शेयर करें' : 'Split the Bill', style: GoogleFonts.jost(fontSize: 13, color: BruchaColors.cream)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/split');
                    },
                    dense: true,
                  ),
                  ListTile(
                    leading: Icon(Icons.room_service_outlined, color: BruchaColors.gold3, size: 20),
                    title: Text(isHindi ? 'वेटर' : 'Call Waiter', style: GoogleFonts.jost(fontSize: 13, color: BruchaColors.cream)),
                    onTap: () {
                      Navigator.pop(context);
                      _callWaiter();
                    },
                    dense: true,
                  ),
                  if (app.userRole == UserRole.admin || app.userRole == UserRole.staff) ...[
                    Divider(color: BruchaColors.ink2, height: 20, indent: 8, endIndent: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4, bottom: 8),
                      child: Text('STAFF & ADMIN', style: GoogleFonts.jost(fontSize: 9, color: BruchaColors.ink3, letterSpacing: 1.5)),
                    ),
                    if (app.userRole == UserRole.admin) ...[
                      ListTile(
                        leading: Icon(Icons.bar_chart_rounded, color: BruchaColors.gold3, size: 20),
                        title: Text('Sales Analytics', style: GoogleFonts.jost(fontSize: 13, color: BruchaColors.cream)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/analytics');
                        },
                        dense: true,
                      ),
                      ListTile(
                        leading: Icon(Icons.qr_code_scanner_rounded, color: BruchaColors.gold3, size: 20),
                        title: Text('QR Codes & Tables', style: GoogleFonts.jost(fontSize: 13, color: BruchaColors.cream)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/admin/qr');
                        },
                        dense: true,
                      ),
                    ],
                    ListTile(
                      leading: Icon(Icons.kitchen_outlined, color: BruchaColors.gold3, size: 20),
                      title: Text('Kitchen Display', style: GoogleFonts.jost(fontSize: 13, color: BruchaColors.cream)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/kitchen');
                      },
                      dense: true,
                    ),
                  ],
                  Divider(color: BruchaColors.ink2, height: 20, indent: 8, endIndent: 8),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                    title: Text(isHindi ? 'लॉग आउट' : 'Logout', style: GoogleFonts.jost(fontSize: 13, color: Colors.redAccent)),
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      await app.logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      }
                    },
                    dense: true,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('v2.0.0 · Crafted with Care', style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink3)),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // ── APP BAR ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: _showSearch ? 160 : 220,
            pinned: true,
            backgroundColor: BruchaColors.ink,
            iconTheme: IconThemeData(color: BruchaColors.gold2),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: FadeTransition(opacity: _heroFade, child: SlideTransition(position: _heroSlide,
                child: _HeroPanel(tableNumber: cart.tableNumber, special: app.dailySpecial, isHindi: isHindi, isCompact: _showSearch))),
              title: AnimatedOpacity(opacity: _isScrolled ? 1 : 0, duration: const Duration(milliseconds: 200),
                child: Text('Brucha', style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.w300, color: BruchaColors.gold2, letterSpacing: 2))),
            ),
            actions: [
              // Language toggle
              IconButton(
                icon: Text(isHindi ? 'EN' : 'हि', style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.w600, color: BruchaColors.gold2)),
                onPressed: () { app.toggleLocale(); HapticFeedback.selectionClick(); },
              ),
              // Coffee/Matcha flavor toggle
              IconButton(
                icon: Icon(
                  app.themeFlavor == ThemeFlavor.coffee ? Icons.eco_outlined : Icons.coffee_outlined,
                  color: BruchaColors.gold2,
                  size: 20,
                ),
                onPressed: () { app.toggleThemeFlavor(); HapticFeedback.selectionClick(); },
              ),
              // Search toggle
              IconButton(
                icon: Icon(_showSearch ? Icons.close : Icons.search, color: BruchaColors.gold2, size: 20),
                onPressed: () { setState(() { _showSearch = !_showSearch; if (!_showSearch) { _search = ''; _searchCtrl.clear(); } }); },
              ),
              // Cart
              Padding(padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: GestureDetector(onTap: count > 0 ? _openCart : null,
                    child: AnimatedContainer(duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(color: count > 0 ? BruchaColors.gold : BruchaColors.ink2, borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.shopping_bag_outlined, size: 15, color: count > 0 ? BruchaColors.ink : BruchaColors.ink3),
                        const SizedBox(width: 5),
                        AnimatedSwitcher(duration: const Duration(milliseconds: 200),
                          child: Text('$count', key: ValueKey(count), style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w600, color: count > 0 ? BruchaColors.ink : BruchaColors.ink3))),
                      ]),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── SEARCH BAR ────────────────────────────────────────────────────
          if (_showSearch)
            SliverToBoxAdapter(child: Container(color: BruchaColors.ink, padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: GoogleFonts.jost(fontSize: 14, color: BruchaColors.cream),
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: isHindi ? 'मेन्यू में खोजें...' : 'Search the menu…',
                  hintStyle: GoogleFonts.jost(fontSize: 13, color: BruchaColors.ink3),
                  prefixIcon: Icon(Icons.search, color: BruchaColors.ink3, size: 20),
                  filled: true, fillColor: BruchaColors.ink2,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            )),

          // ── DIETARY FILTERS ────────────────────────────────────────────────
          SliverToBoxAdapter(child: _DietaryFilters()),

          // ── CATEGORY TABS ─────────────────────────────────────────────────
          SliverPersistentHeader(pinned: true, delegate: _CatTabsDelegate(
            selectedCat: _selectedCat,
            onSelect: (cat) { setState(() => _selectedCat = cat); HapticFeedback.selectionClick(); },
          )),

          // ── FAVOURITES SECTION ────────────────────────────────────────────
          if (favItems.isNotEmpty && _selectedCat == null && _search.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              sliver: SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SectionHeader(isHindi ? 'आपकी पसंद' : 'Your Picks ❤️'),
                GridView.builder(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.72),
                  itemCount: favItems.length,
                  itemBuilder: (_, i) => AnimationConfiguration.staggeredGrid(position: i, duration: const Duration(milliseconds: 400), columnCount: 2,
                    child: ScaleAnimation(scale: 0.92, child: FadeInAnimation(child: MenuItemCard(item: favItems[i], index: i, isHindi: isHindi)))),
                ),
              ])),
            ),

          // ── MENU SECTIONS ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 120),
            sliver: SliverList(delegate: SliverChildBuilderDelegate((context, secIdx) {
              final cat = cats[secIdx];
              final items = filtered.where((i) => i.category == cat).toList();
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SectionHeader(isHindi ? cat.label : cat.label),
                AnimationLimiter(child: GridView.builder(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.72),
                  itemCount: items.length,
                  itemBuilder: (_, i) => AnimationConfiguration.staggeredGrid(position: i, duration: const Duration(milliseconds: 400), columnCount: 2,
                    child: ScaleAnimation(scale: 0.92, child: FadeInAnimation(child: MenuItemCard(item: items[i], index: i, isHindi: isHindi)))),
                )),
              ]);
            }, childCount: cats.length)),
          ),
        ],
      ),

      // ── FABs ────────────────────────────────────────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Column(mainAxisSize: MainAxisSize.min, children: [
        // Action row: Waiter + Split Bill + Kitchen (admin)
        Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
          FloatingActionButton.extended(
            heroTag: 'waiter',
            onPressed: _callWaiter,
            backgroundColor: BruchaColors.ink2,
            elevation: 4,
            icon: Icon(Icons.room_service_outlined, color: BruchaColors.gold2, size: 18),
            label: Text(isHindi ? 'वेटर' : 'Waiter', style: GoogleFonts.jost(fontSize: 11, color: BruchaColors.gold2)),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.extended(
            heroTag: 'split',
            onPressed: () { HapticFeedback.mediumImpact(); Navigator.pushNamed(context, '/split'); },
            backgroundColor: BruchaColors.ink2,
            elevation: 4,
            icon: Icon(Icons.people_outline, color: BruchaColors.gold2, size: 18),
            label: Text(isHindi ? 'बिल शेयर' : 'Split Bill', style: GoogleFonts.jost(fontSize: 11, color: BruchaColors.gold2)),
          ),
          if (app.userRole == UserRole.admin || app.userRole == UserRole.staff) ...[
            const SizedBox(width: 8),
            FloatingActionButton(
              heroTag: 'kds',
              onPressed: () { HapticFeedback.selectionClick(); Navigator.pushNamed(context, '/kitchen'); },
              backgroundColor: BruchaColors.ink2,
              elevation: 4,
              mini: true,
              child: Icon(Icons.restaurant_menu_outlined, color: BruchaColors.gold2, size: 18),
            ),
          ],
        ]),
        if (count > 0) ...[
          const SizedBox(height: 8),
          _CheckoutBar(count: count, total: cart.grandTotal, onTap: _openCart),
        ],
      ]),
    );
  }
}

// ── HERO PANEL ─────────────────────────────────────────────────────────────────
class _HeroPanel extends StatelessWidget {
  final String tableNumber;
  final DailySpecial? special;
  final bool isHindi;
  final bool isCompact;
  const _HeroPanel({required this.tableNumber, this.special, this.isHindi = false, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Container(
        color: BruchaColors.ink,
        padding: const EdgeInsets.only(top: 56, bottom: 4),
        child: Center(
          child: Text('Brucha', style: GoogleFonts.cormorantGaramond(fontSize: 28, fontWeight: FontWeight.w300, color: BruchaColors.gold2, letterSpacing: 4)),
        ),
      );
    }
    return Container(color: BruchaColors.ink, padding: const EdgeInsets.only(top: 56, bottom: 10),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 28, height: 0.5, color: BruchaColors.gold.withOpacity(0.5)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('CRAFTED WITH CARE', style: GoogleFonts.jost(fontSize: 9, color: BruchaColors.gold, letterSpacing: 3))),
          Container(width: 28, height: 0.5, color: BruchaColors.gold.withOpacity(0.5)),
        ]),
        const SizedBox(height: 6),
        Text('Brucha', style: GoogleFonts.cormorantGaramond(fontSize: 40, fontWeight: FontWeight.w300, color: BruchaColors.gold2, letterSpacing: 4)),
        Text(isHindi ? 'कॉफी और किचन' : 'COFFEE  &  KITCHEN', style: GoogleFonts.jost(fontSize: 9, color: BruchaColors.ink3, letterSpacing: 4)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 44, height: 0.5, color: BruchaColors.ink3),
          const SizedBox(width: 8),
          Transform.rotate(angle: 0.785398, child: Container(width: 5, height: 5, color: BruchaColors.gold)),
          const SizedBox(width: 8),
          Container(width: 44, height: 0.5, color: BruchaColors.ink3),
        ]),
        const SizedBox(height: 8),
        // Daily special banner
        if (special != null && special!.isValid)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: BruchaColors.gold.withOpacity(0.15), border: Border.all(color: BruchaColors.gold.withOpacity(0.3)), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('✨', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text("${special!.discountPercent.toInt()}% off ${special!.title}",
                style: GoogleFonts.jost(fontSize: 11, color: BruchaColors.gold2, fontWeight: FontWeight.w500)),
              const SizedBox(width: 6),
              const Text('✨', style: TextStyle(fontSize: 14)),
            ]),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(border: Border.all(color: BruchaColors.ink3), borderRadius: BorderRadius.circular(20)),
          child: Text('TABLE $tableNumber  ·  7AM – 10PM', style: GoogleFonts.jost(fontSize: 9, color: BruchaColors.ink3, letterSpacing: 1.5)),
        ),
      ]),
    );
  }
}

// ── DIETARY FILTERS ────────────────────────────────────────────────────────────
class _DietaryFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final tags = [
      (DietaryTag.veg,      '🌱', 'Veg'),
      (DietaryTag.vegan,    '🌿', 'Vegan'),
      (DietaryTag.glutenFree, '🌾', 'Gluten-Free'),
      (DietaryTag.nutFree,  '🚫', 'Nut-Free'),
    ];
    return Container(color: BruchaColors.parch2,
      child: SingleChildScrollView(scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(children: tags.map((t) {
          final active = app.activeFilters.contains(t.$1);
          return GestureDetector(
            onTap: () { app.toggleFilter(t.$1); HapticFeedback.selectionClick(); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: active ? BruchaColors.greenVeg : Colors.transparent,
                border: Border.all(color: active ? BruchaColors.greenVeg : BruchaColors.parch3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text('${t.$2} ${t.$3}', style: GoogleFonts.jost(fontSize: 10, fontWeight: FontWeight.w500, color: active ? BruchaColors.greenVegBg : BruchaColors.ink3)),
            ),
          );
        }).toList()),
      ),
    );
  }
}

// ── CATEGORY TABS ──────────────────────────────────────────────────────────────
class _CatTabsDelegate extends SliverPersistentHeaderDelegate {
  final MenuCategory? selectedCat;
  final ValueChanged<MenuCategory?> onSelect;
  _CatTabsDelegate({required this.selectedCat, required this.onSelect});
  @override double get minExtent => 52;
  @override double get maxExtent => 52;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: BruchaColors.cream, child: Column(children: [
      Expanded(child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        children: [
          _Tab(label: 'All', emoji: '✦', selected: selectedCat == null, onTap: () => onSelect(null)),
          ...MenuCategory.values.map((cat) => _Tab(label: cat.label.split(' ').first, emoji: cat.tabEmoji, selected: selectedCat == cat, onTap: () => onSelect(cat))),
        ],
      )),
      Container(height: 1, color: BruchaColors.parch3),
    ]));
  }
  @override bool shouldRebuild(_CatTabsDelegate old) => old.selectedCat != selectedCat;
}

class _Tab extends StatelessWidget {
  final String label, emoji;
  final bool selected;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.emoji, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? BruchaColors.ink : Colors.transparent,
        border: Border.all(color: selected ? BruchaColors.ink : BruchaColors.parch3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$emoji  $label', style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w500,
        color: selected ? BruchaColors.gold2 : BruchaColors.ink3, letterSpacing: 0.3)),
    ),
  );
}

// ── CHECKOUT BAR ───────────────────────────────────────────────────────────────
class _CheckoutBar extends StatelessWidget {
  final int count; final double total; final VoidCallback onTap;
  const _CheckoutBar({required this.count, required this.total, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: GestureDetector(onTap: onTap,
      child: Container(height: 56,
        decoration: BoxDecoration(color: BruchaColors.ink, borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: BruchaColors.ink.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))]),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            AnimatedSwitcher(duration: const Duration(milliseconds: 200),
              child: Container(key: ValueKey(count), width: 28, height: 28,
                decoration: BoxDecoration(color: BruchaColors.gold, borderRadius: BorderRadius.circular(5)),
                child: Center(child: Text('$count', style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w700, color: BruchaColors.ink))))),
            const SizedBox(width: 10),
            Text('View Order', style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.w500, color: BruchaColors.gold3)),
          ]),
          Text('₹ ${total.toInt()}', style: GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.w600, color: BruchaColors.gold2)),
        ]),
      ),
    ),
  );
}
