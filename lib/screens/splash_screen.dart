import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoCtrl, _lineCtrl, _fadeCtrl;
  late Animation<double> _logoScale, _logoFade, _lineWidth, _textFade, _exitFade;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _lineCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _logoScale = Tween(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _logoFade  = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);
    _lineWidth = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _lineCtrl, curve: Curves.easeOut));
    _textFade  = CurvedAnimation(parent: _lineCtrl, curve: Curves.easeOut);
    _exitFade  = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn));
    _run();
  }

  Future<void> _run() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _lineCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    await _fadeCtrl.forward();
    if (mounted) {
      final app = Provider.of<AppProvider>(context, listen: false);
      if (app.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/menu');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override void dispose() { _logoCtrl.dispose(); _lineCtrl.dispose(); _fadeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _exitFade,
      builder: (_, child) => Opacity(opacity: _exitFade.value, child: child),
      child: Scaffold(
        backgroundColor: BruchaColors.ink,
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          ScaleTransition(scale: _logoScale, child: FadeTransition(opacity: _logoFade,
            child: Column(children: [
              SizedBox(width: 130, height: 130, child: Stack(alignment: Alignment.center, children: [
                Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: BruchaColors.gold.withOpacity(0.1), width: 1))),
                Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: BruchaColors.gold.withOpacity(0.15), width: 1))),
                const Text('☕', style: TextStyle(fontSize: 46)),
              ])),
              const SizedBox(height: 20),
              Text('Brucha', style: GoogleFonts.cormorantGaramond(fontSize: 52, fontWeight: FontWeight.w300, color: BruchaColors.gold2, letterSpacing: 6)),
            ]),
          )),
          const SizedBox(height: 16),
          AnimatedBuilder(animation: _lineWidth, builder: (_, __) => Container(width: 120 * _lineWidth.value, height: 0.5, color: BruchaColors.gold.withOpacity(0.5))),
          const SizedBox(height: 14),
          FadeTransition(opacity: _textFade, child: Text('COFFEE  &  KITCHEN', style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink3, letterSpacing: 5))),
          const SizedBox(height: 6),
          FadeTransition(opacity: _textFade, child: Text('Slow food. Good coffee.', style: GoogleFonts.cormorantGaramond(fontSize: 14, fontStyle: FontStyle.italic, color: BruchaColors.ink3.withOpacity(0.7)))),
        ])),
      ),
    );
  }
}
