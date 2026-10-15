import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/menu_item.dart';
import '../providers/cart_provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class SuccessScreen extends StatefulWidget {
  final String orderNumber;
  const SuccessScreen({super.key, required this.orderNumber});
  @override State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with TickerProviderStateMixin {
  late AnimationController _mainCtrl, _particleCtrl, _pulseCtrl, _statusCtrl;
  late Animation<double> _iconScale, _iconFade, _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _cardScale, _pulse;
  final List<_Particle> _particles = [];

  // Order status simulation
  int _statusStep = 0; // 0=received, 1=preparing, 2=ready
  final _statusLabels = ['Order Received', 'Preparing', 'Ready to Serve 🎉'];
  final _statusIcons  = [Icons.check_circle_outline, Icons.restaurant_outlined, Icons.done_all_rounded];

  // Rating state
  bool _showRating = false;
  final Map<int, double> _ratings = {};
  List<MenuItem> _orderedItems = [];
  bool _ratingSubmitted = false;

  @override
  void initState() {
    super.initState();
    _mainCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _particleCtrl= AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _pulseCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _statusCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _iconScale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)));
    _iconFade  = CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.3));
    _textFade  = CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.4, 0.8));
    _textSlide = Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.4, 0.8, curve: Curves.easeOut)));
    _cardScale = Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.55, 1.0, curve: Curves.easeOutBack)));
    _pulse     = Tween(begin: 0.96, end: 1.04).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    final rng = Random();
    for (int i = 0; i < 22; i++) {
      _particles.add(_Particle(angle: rng.nextDouble() * 2 * pi, distance: 60 + rng.nextDouble() * 110,
        size: 4 + rng.nextDouble() * 6, color: [BruchaColors.gold, BruchaColors.gold2, BruchaColors.gold3, BruchaColors.rust, BruchaColors.parch3][rng.nextInt(5)]));
    }

    HapticFeedback.heavyImpact();
    _mainCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () { if (mounted) _particleCtrl.forward(); });

    // Simulate order status progression
    Future.delayed(const Duration(seconds: 4), () { if (mounted) setState(() => _statusStep = 1); });
    Future.delayed(const Duration(seconds: 9), () {
      if (mounted) {
        setState(() { _statusStep = 2; _showRating = true; });
        HapticFeedback.heavyImpact();
      }
    });

    // Load ordered items for rating
    _loadOrderedItems();
  }

  void _loadOrderedItems() {
    final history = context.read<AppProvider>().orderHistory;
    if (history.isNotEmpty) {
      final lastOrder = history.first;
      _orderedItems = lastOrder.items.map((oi) => kMenu.firstWhere((m) => m.id == oi.itemId, orElse: () => kMenu.first)).toList();
    }
  }

  Future<void> _submitRatings() async {
    final app = context.read<AppProvider>();
    for (final e in _ratings.entries) { await app.rateItem(e.key, e.value); }
    setState(() => _ratingSubmitted = true);
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() { _mainCtrl.dispose(); _particleCtrl.dispose(); _pulseCtrl.dispose(); _statusCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Scaffold(
      backgroundColor: BruchaColors.ink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // ── Animated icon ───────────────────────────────────────────────
            SizedBox(height: 160, child: Stack(alignment: Alignment.center, children: [
              AnimatedBuilder(animation: _particleCtrl, builder: (_, __) => CustomPaint(
                size: const Size(240, 240),
                painter: _ParticlePainter(particles: _particles, progress: _particleCtrl.value),
              )),
              ScaleTransition(scale: _iconScale, child: FadeTransition(opacity: _iconFade,
                child: ScaleTransition(scale: _pulse, child: Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(color: BruchaColors.ink2, border: Border.all(color: BruchaColors.gold.withOpacity(0.3), width: 1.5), borderRadius: BorderRadius.circular(22)),
                  child: const Center(child: Text('☕', style: TextStyle(fontSize: 44))),
                )),
              )),
            ])),

            // ── Text ──────────────────────────────────────────────────────────
            FadeTransition(opacity: _textFade, child: SlideTransition(position: _textSlide, child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 28, height: 0.5, color: BruchaColors.gold.withOpacity(0.4)),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('ORDER CONFIRMED', style: GoogleFonts.jost(fontSize: 9, color: BruchaColors.gold, letterSpacing: 3))),
                Container(width: 28, height: 0.5, color: BruchaColors.gold.withOpacity(0.4)),
              ]),
              const SizedBox(height: 14),
              Text('On its way to\nthe kitchen', textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(fontSize: 30, fontWeight: FontWeight.w300, color: BruchaColors.cream, height: 1.3)),
              const SizedBox(height: 10),
              Text('Sit back and relax — we\'ll bring\neverything fresh to your table.', textAlign: TextAlign.center,
                style: GoogleFonts.jost(fontSize: 13, color: BruchaColors.ink3, height: 1.7)),
            ]))),

            const SizedBox(height: 24),

            // ── Order card ────────────────────────────────────────────────────
            ScaleTransition(scale: _cardScale, child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(border: Border.all(color: BruchaColors.gold.withOpacity(0.25)), borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                Text('ORDER NUMBER', style: GoogleFonts.jost(fontSize: 9, color: BruchaColors.ink3, letterSpacing: 2.5)),
                const SizedBox(height: 6),
                Text(widget.orderNumber, style: GoogleFonts.cormorantGaramond(fontSize: 40, fontWeight: FontWeight.w600, color: BruchaColors.gold2)),
                Text('TABLE ${cart.tableNumber}', style: GoogleFonts.jost(fontSize: 9, color: BruchaColors.ink3, letterSpacing: 2)),
              ]),
            )),
            const SizedBox(height: 16),

            // ── Live order status tracker ─────────────────────────────────────
            ScaleTransition(scale: _cardScale, child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: BruchaColors.ink2, borderRadius: BorderRadius.circular(12), border: Border.all(color: BruchaColors.dkBorder)),
              child: Column(children: [
                Text('LIVE STATUS', style: GoogleFonts.jost(fontSize: 9, color: BruchaColors.ink3, letterSpacing: 2.5)),
                const SizedBox(height: 14),
                Row(children: List.generate(3, (i) {
                  final done  = i <= _statusStep;
                  final active= i == _statusStep;
                  return Expanded(child: Row(children: [
                    Expanded(child: Column(children: [
                      AnimatedContainer(duration: const Duration(milliseconds: 400),
                        width: active ? 36 : 28, height: active ? 36 : 28,
                        decoration: BoxDecoration(
                          color: done ? BruchaColors.gold : BruchaColors.ink3.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: done ? BruchaColors.gold : BruchaColors.ink3.withOpacity(0.4), width: active ? 2 : 1),
                        ),
                        child: Center(child: Icon(_statusIcons[i], size: active ? 18 : 14, color: done ? BruchaColors.ink : BruchaColors.ink3.withOpacity(0.4))),
                      ),
                      const SizedBox(height: 6),
                      Text(_statusLabels[i], textAlign: TextAlign.center,
                        style: GoogleFonts.jost(fontSize: 9, color: done ? BruchaColors.gold2 : BruchaColors.ink3, fontWeight: done ? FontWeight.w600 : FontWeight.w400)),
                    ])),
                    if (i < 2) Expanded(child: Container(height: 1.5, color: i < _statusStep ? BruchaColors.gold : BruchaColors.ink3.withOpacity(0.3))),
                  ]));
                })),
              ]),
            )),
            const SizedBox(height: 12),

            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.access_time_outlined, size: 13, color: BruchaColors.ink3),
              const SizedBox(width: 5),
              Text('Estimated wait: ', style: GoogleFonts.jost(fontSize: 12, color: BruchaColors.ink3)),
              Text('12–18 min', style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w600, color: BruchaColors.gold)),
            ]),

            // ── Dish Rating ───────────────────────────────────────────────────
            if (_showRating && _orderedItems.isNotEmpty && !_ratingSubmitted)
              FadeTransition(opacity: _textFade, child: Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: BruchaColors.ink2, borderRadius: BorderRadius.circular(12), border: Border.all(color: BruchaColors.gold.withOpacity(0.2))),
                child: Column(children: [
                  Text('How was your food?', style: GoogleFonts.cormorantGaramond(fontSize: 18, fontWeight: FontWeight.w600, color: BruchaColors.gold2)),
                  const SizedBox(height: 4),
                  Text('Rate your dishes', style: GoogleFonts.jost(fontSize: 11, color: BruchaColors.ink3)),
                  const SizedBox(height: 14),
                  ..._orderedItems.take(3).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(children: [
                      Text(item.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item.name, style: GoogleFonts.cormorantGaramond(fontSize: 14, fontWeight: FontWeight.w600, color: BruchaColors.cream))),
                      RatingBar.builder(
                        initialRating: _ratings[item.id] ?? 0,
                        minRating: 1, direction: Axis.horizontal, allowHalfRating: false,
                        itemCount: 5, itemSize: 22,
                        itemBuilder: (_, __) => Icon(Icons.star_rounded, color: BruchaColors.gold),
                        unratedColor: BruchaColors.ink3.withOpacity(0.4),
                        onRatingUpdate: (r) => setState(() => _ratings[item.id] = r),
                      ),
                    ]),
                  )),
                  const SizedBox(height: 4),
                  GestureDetector(onTap: _submitRatings, child: Container(
                    width: double.infinity, height: 44,
                    decoration: BoxDecoration(color: BruchaColors.gold, borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text('Submit Ratings', style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.w600, color: BruchaColors.ink))),
                  )),
                ]),
              )),

            if (_ratingSubmitted)
              Padding(padding: const EdgeInsets.only(top: 12),
                child: Text('Thank you for your feedback! ⭐', style: GoogleFonts.jost(fontSize: 12, color: BruchaColors.gold))),

            const SizedBox(height: 28),

            // ── Back button ───────────────────────────────────────────────────
            FadeTransition(opacity: _textFade, child: GestureDetector(
              onTap: () { HapticFeedback.lightImpact(); cart.reset(); Navigator.popUntil(context, (r) => r.isFirst); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 13),
                decoration: BoxDecoration(color: BruchaColors.gold, borderRadius: BorderRadius.circular(6)),
                child: Text('Back to Menu', style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.w600, color: BruchaColors.ink, letterSpacing: 0.5)),
              ),
            )),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/history'),
              child: Text('View Order History', style: GoogleFonts.jost(fontSize: 12, color: BruchaColors.ink3, decoration: TextDecoration.underline)),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Particle { final double angle, distance, size; final Color color; _Particle({required this.angle, required this.distance, required this.size, required this.color}); }

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  _ParticlePainter({required this.particles, required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final curve = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));
    for (final p in particles) {
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withOpacity(opacity);
      final dist = p.distance * curve;
      canvas.drawCircle(Offset(center.dx + cos(p.angle)*dist, center.dy + sin(p.angle)*dist), p.size*(1-progress*0.5), paint);
    }
  }
  @override bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
