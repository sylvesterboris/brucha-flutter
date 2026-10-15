import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/success_screen.dart';
import 'screens/qr_admin_screen.dart';
import 'screens/history_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/kitchen_display_screen.dart';
import 'screens/bill_split_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));
  runApp(const BruchaApp());
}

class BruchaApp extends StatelessWidget {
  const BruchaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()..tableNumber = _tableFromUri()),
      ],
      child: Consumer<AppProvider>(
        builder: (_, app, __) => MaterialApp(
          title: 'Brucha — Coffee & Kitchen',
          debugShowCheckedModeBanner: false,
          theme:      BruchaTheme.light,
          locale:     app.locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('hi')],
          initialRoute: '/',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':          return _fade(const SplashScreen());
              case '/login':     return _fade(const LoginScreen());
              case '/menu':      return _fade(const MenuScreen());
              case '/success':
                final n = settings.arguments as String? ?? '#0000';
                return _fade(SuccessScreen(orderNumber: n));
              case '/history':   return _slide(const HistoryScreen());
              case '/admin/qr':  return _slide(const QrAdminScreen());
              case '/analytics': return _slide(const AnalyticsScreen());
              case '/kitchen':   return _slide(const KitchenDisplayScreen());
              case '/split':     return _slide(const BillSplitScreen());
              default:           return _fade(const MenuScreen());
            }
          },
        ),
      ),
    );
  }
}

String _tableFromUri() {
  // Parse deep link: brucha.cafe/menu?table=N
  // In production: use uni_links package to read PlatformDispatcher.instance.defaultRouteName
  return '1';
}

PageRoute _fade(Widget page) => PageRouteBuilder(
  pageBuilder: (_, __, ___) => page,
  transitionDuration: const Duration(milliseconds: 400),
  transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
);

PageRoute _slide(Widget page) => PageRouteBuilder(
  pageBuilder: (_, __, ___) => page,
  transitionDuration: const Duration(milliseconds: 350),
  transitionsBuilder: (_, anim, __, child) => SlideTransition(
    position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
    child: child,
  ),
);
