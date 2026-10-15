import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_item.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';

enum UserRole { customer, staff, admin }

class AppProvider extends ChangeNotifier {
  // ── User Session & Role ───────────────────────────────────────────────────
  UserRole userRole = UserRole.customer;
  String? userPhoneNumber;
  bool get isLoggedIn => userPhoneNumber != null;

  // ── Theme ──────────────────────────────────────────────────────────────────
  ThemeFlavor themeFlavor = ThemeFlavor.coffee;

  // ── Language ───────────────────────────────────────────────────────────────
  Locale locale = const Locale('en');

  // ── Favourites ─────────────────────────────────────────────────────────────
  Set<int> _favourites = {};
  Set<int> get favourites => _favourites;
  bool isFavourite(int id) => _favourites.contains(id);

  // ── Dietary Filters ────────────────────────────────────────────────────────
  Set<DietaryTag> activeFilters = {};

  // ── Item Availability ──────────────────────────────────────────────────────
  Set<int> _unavailable = {};
  bool isAvailable(int id) => !_unavailable.contains(id);

  // ── Item Ratings ───────────────────────────────────────────────────────────
  Map<int, List<double>> _ratings = {};

  // ── Daily Special ──────────────────────────────────────────────────────────
  DailySpecial? dailySpecial = DailySpecial(
    itemId: 2,
    title: 'Today\'s Special',
    discountPercent: 15,
    validUntil: DateTime.now().add(const Duration(hours: 5)),
  );

  // ── Order History ──────────────────────────────────────────────────────────
  List<OrderRecord> orderHistory = [];

  // ── Waiter calls ──────────────────────────────────────────────────────────
  int waiterCallCount = 0;

  AppProvider() { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    themeFlavor = ThemeFlavor.values[prefs.getInt('themeFlavor') ?? 0];
    BruchaColors.activeFlavor = themeFlavor;
    locale = Locale(prefs.getString('locale') ?? 'en');
    userPhoneNumber = prefs.getString('userPhoneNumber');
    final roleIndex = prefs.getInt('userRole');
    userRole = roleIndex != null ? UserRole.values[roleIndex] : UserRole.customer;
    _favourites = (prefs.getStringList('favourites') ?? []).map(int.parse).toSet();
    _unavailable = (prefs.getStringList('unavailable') ?? []).map(int.parse).toSet();
    activeFilters = (prefs.getStringList('dietaryFilters') ?? [])
        .map((s) => DietaryTag.values[int.parse(s)]).toSet();

    // Load ratings
    final ratingsJson = prefs.getString('ratings');
    if (ratingsJson != null) {
      final Map<String, dynamic> raw = jsonDecode(ratingsJson);
      _ratings = raw.map((k, v) => MapEntry(int.parse(k), List<double>.from(v)));
      for (final item in kMenu) {
        if (_ratings.containsKey(item.id)) {
          item.rating = _ratings[item.id]!.reduce((a,b)=>a+b);
          item.ratingCount = _ratings[item.id]!.length;
        }
      }
    }

    // Load order history
    final hist = prefs.getStringList('order_history') ?? [];
    orderHistory = hist.map((s) => OrderRecord.fromJson(jsonDecode(s))).toList();

    notifyListeners();
  }

  // ── Theme ──────────────────────────────────────────────────────────────────

  Future<void> setThemeFlavor(ThemeFlavor flavor) async {
    themeFlavor = flavor;
    BruchaColors.activeFlavor = flavor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeFlavor', flavor.index);
    notifyListeners();
  }

  void toggleThemeFlavor() => setThemeFlavor(themeFlavor == ThemeFlavor.coffee ? ThemeFlavor.matcha : ThemeFlavor.coffee);

  // ── User Session ───────────────────────────────────────────────────────────
  Future<void> login(String phone, UserRole role) async {
    userPhoneNumber = phone;
    userRole = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPhoneNumber', phone);
    await prefs.setInt('userRole', role.index);
    notifyListeners();
  }

  Future<void> logout() async {
    userPhoneNumber = null;
    userRole = UserRole.customer;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userPhoneNumber');
    await prefs.remove('userRole');
    notifyListeners();
  }

  // ── Language ───────────────────────────────────────────────────────────────
  Future<void> setLocale(Locale loc) async {
    locale = loc;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', loc.languageCode);
    notifyListeners();
  }

  void toggleLocale() => setLocale(locale.languageCode == 'en' ? const Locale('hi') : const Locale('en'));

  // ── Favourites ─────────────────────────────────────────────────────────────
  Future<void> toggleFavourite(int id) async {
    if (_favourites.contains(id)) { _favourites.remove(id); }
    else { _favourites.add(id); }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favourites', _favourites.map((e) => '$e').toList());
    notifyListeners();
  }

  // ── Dietary Filters ────────────────────────────────────────────────────────
  Future<void> toggleFilter(DietaryTag tag) async {
    if (activeFilters.contains(tag)) { activeFilters.remove(tag); }
    else { activeFilters.add(tag); }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('dietaryFilters', activeFilters.map((t) => '${t.index}').toList());
    notifyListeners();
  }

  // ── Availability ───────────────────────────────────────────────────────────
  Future<void> toggleAvailability(int id) async {
    if (_unavailable.contains(id)) { _unavailable.remove(id); }
    else { _unavailable.add(id); }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('unavailable', _unavailable.map((e) => '$e').toList());
    notifyListeners();
  }

  // ── Ratings ────────────────────────────────────────────────────────────────
  Future<void> rateItem(int itemId, double rating) async {
    _ratings.putIfAbsent(itemId, () => []).add(rating);
    final item = kMenu.firstWhere((i) => i.id == itemId, orElse: () => kMenu.first);
    item.rating = _ratings[itemId]!.reduce((a,b)=>a+b);
    item.ratingCount = _ratings[itemId]!.length;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ratings', jsonEncode(_ratings.map((k,v)=>MapEntry('$k',v))));
    notifyListeners();
  }

  // ── Order History ──────────────────────────────────────────────────────────
  Future<void> reloadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final hist = prefs.getStringList('order_history') ?? [];
    orderHistory = hist.map((s) => OrderRecord.fromJson(jsonDecode(s))).toList();
    notifyListeners();
  }

  // ── Waiter ────────────────────────────────────────────────────────────────
  void callWaiter() {
    waiterCallCount++;
    notifyListeners();
  }

  // ── Filtered menu ─────────────────────────────────────────────────────────
  List<MenuItem> filteredMenu(MenuCategory? cat, String search) {
    var items = cat == null ? kMenu : kMenu.where((i) => i.category == cat).toList();
    if (activeFilters.isNotEmpty) {
      items = items.where((i) => activeFilters.every((t) => i.dietaryTags.contains(t))).toList();
    }
    if (search.isNotEmpty) {
      final q = search.toLowerCase();
      items = items.where((i) =>
          i.name.toLowerCase().contains(q) ||
          i.description.toLowerCase().contains(q) ||
          i.nameHi.contains(q)).toList();
    }
    return items;
  }
}
