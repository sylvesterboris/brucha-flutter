import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/menu_item.dart';
import '../theme/app_theme.dart';

// ── BADGE CHIP ────────────────────────────────────────────────────────────────
class BadgeChip extends StatelessWidget {
  final BadgeType badge;
  const BadgeChip(this.badge, {super.key});

  @override
  Widget build(BuildContext context) {
    if (badge == BadgeType.none) return const SizedBox.shrink();
    final (text, bg, fg) = switch (badge) {
      BadgeType.popular => ('★ Popular', BruchaColors.gold,     BruchaColors.ink),
      BadgeType.veg     => ('🌱 Veg',    BruchaColors.greenVeg, BruchaColors.greenVegBg),
      BadgeType.newItem => ('✦ New',     BruchaColors.rust,     Colors.white),
      _                 => ('',          Colors.transparent,    Colors.transparent),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(3)),
      child: Text(text, style: GoogleFonts.jost(fontSize: 9, fontWeight: FontWeight.w600, color: fg, letterSpacing: 0.8)),
    );
  }
}

// ── SECTION HEADER ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withOpacity(0.3);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(children: [
        Expanded(child: Divider(color: muted, thickness: 1)),
        const SizedBox(width: 14),
        Text(title, style: GoogleFonts.cormorantGaramond(fontSize: 17, fontWeight: FontWeight.w600, color: BruchaColors.ink2, letterSpacing: 1.2)),
        const SizedBox(width: 10),
        Container(width: 5, height: 5, decoration: BoxDecoration(color: BruchaColors.gold, shape: BoxShape.circle)),
        const SizedBox(width: 14),
        Expanded(child: Divider(color: muted, thickness: 1)),
      ]),
    );
  }
}

// ── ORNAMENT DIVIDER ──────────────────────────────────────────────────────────
class OrnamentDivider extends StatelessWidget {
  const OrnamentDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 50, height: 0.5, color: BruchaColors.ink3),
        const SizedBox(width: 10),
        Transform.rotate(angle: 0.785398, child: Container(width: 5, height: 5, color: BruchaColors.gold)),
        const SizedBox(width: 10),
        Container(width: 50, height: 0.5, color: BruchaColors.ink3),
      ]),
    );
  }
}

// ── QUANTITY CONTROL ──────────────────────────────────────────────────────────
class QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool small;
  const QtyControl({super.key, required this.qty, required this.onAdd, required this.onRemove, this.small = false});

  @override
  Widget build(BuildContext context) {
    final sz = small ? 26.0 : 30.0;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _PressBtn(label: '−', size: sz, onTap: onRemove),
      SizedBox(width: sz, child: Text('$qty', textAlign: TextAlign.center,
          style: GoogleFonts.jost(fontSize: small ? 13 : 15, fontWeight: FontWeight.w600, color: BruchaColors.ink))),
      _PressBtn(label: '+', size: sz, onTap: onAdd),
    ]);
  }
}

class _PressBtn extends StatefulWidget {
  final String label; final double size; final VoidCallback onTap;
  const _PressBtn({required this.label, required this.size, required this.onTap});
  @override State<_PressBtn> createState() => _PressBtnState();
}

class _PressBtnState extends State<_PressBtn> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.86).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _ctrl.forward(),
    onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
    onTapCancel: () => _ctrl.reverse(),
    child: ScaleTransition(scale: _scale,
      child: Container(
        width: widget.size, height: widget.size,
        decoration: BoxDecoration(color: BruchaColors.parch2, border: Border.all(color: BruchaColors.parch3), borderRadius: BorderRadius.circular(4)),
        child: Center(child: Text(widget.label, style: GoogleFonts.jost(fontSize: 17, fontWeight: FontWeight.w600, color: BruchaColors.ink2))),
      ),
    ),
  );
}

// ── GOLD BUTTON ───────────────────────────────────────────────────────────────
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  const GoldButton({super.key, required this.label, this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity, height: 52,
        decoration: BoxDecoration(color: loading ? BruchaColors.ink2 : BruchaColors.ink, borderRadius: BorderRadius.circular(8)),
        child: Center(child: loading
          ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: BruchaColors.gold2, strokeWidth: 2))
          : Text(label, style: GoogleFonts.cormorantGaramond(fontSize: 17, fontWeight: FontWeight.w600, color: BruchaColors.gold2, letterSpacing: 1))),
      ),
    );
  }
}

// ── STAR RATING DISPLAY ───────────────────────────────────────────────────────
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final int count;
  const StarRatingDisplay({super.key, required this.rating, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.star_rounded, color: BruchaColors.gold, size: 12),
      const SizedBox(width: 2),
      Text(rating.toStringAsFixed(1), style: GoogleFonts.jost(fontSize: 10, fontWeight: FontWeight.w600, color: BruchaColors.gold)),
      Text(' ($count)', style: GoogleFonts.jost(fontSize: 9, color: BruchaColors.ink3)),
    ]);
  }
}
