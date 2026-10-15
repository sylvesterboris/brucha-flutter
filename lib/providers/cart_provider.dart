import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/menu_item.dart';
import '../models/order_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  String tableNumber = '1';
  String? lastOrderNumber;
  String? specialNotes;
  String? appliedCoupon;
  double couponDiscount = 0;
  int loyaltyPoints = 0;
  bool usePoints = false;

  static const _uuid = Uuid();

  List<CartItem> get items => _items.values.toList();
  int    get totalCount  => _items.values.fold(0, (s, c) => s + c.quantity);
  double get subtotal    => _items.values.fold(0.0, (s, c) => s + c.lineTotal);
  double get gst         => subtotal * 0.05;
  double get pointsValue => usePoints ? (loyaltyPoints / 10).clamp(0, subtotal * 0.2) : 0;
  double get grandTotal  => (subtotal + gst - couponDiscount - pointsValue).clamp(0, double.infinity);
  int    get earnedPoints=> (grandTotal / 10).floor();

  bool hasItem(int id) => _items.values.any((c) => c.item.id == id);
  int quantityOf(int id) => _items.values.where((c) => c.item.id == id).fold(0, (s, c) => s + c.quantity);

  void add(MenuItem item, {CartCustomisation? customisation}) {
    final key = '${item.id}_${customisation?.summary ?? ""}';
    if (_items.containsKey(key)) {
      _items[key]!.quantity++;
    } else {
      _items[key] = CartItem(item: item, customisation: customisation ?? CartCustomisation());
    }
    notifyListeners();
  }

  void decrement(String key) {
    if (!_items.containsKey(key)) return;
    if (_items[key]!.quantity <= 1) {
      _items.remove(key);
    } else {
      _items[key]!.quantity--;
    }
    notifyListeners();
  }

  void removeItem(String key) {
    _items.remove(key);
    notifyListeners();
  }

  bool applyCoupon(String code) {
    final validCoupons = {'BRUCHA10': 10.0, 'WELCOME20': 20.0, 'COFFEE15': 15.0};
    if (validCoupons.containsKey(code.toUpperCase())) {
      appliedCoupon = code.toUpperCase();
      couponDiscount = subtotal * (validCoupons[code.toUpperCase()]! / 100);
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeCoupon() {
    appliedCoupon = null;
    couponDiscount = 0;
    notifyListeners();
  }

  void toggleUsePoints() {
    usePoints = !usePoints;
    notifyListeners();
  }

  Future<String> placeOrder() async {
    final n = '#${(1000 + DateTime.now().millisecondsSinceEpoch % 8999)}';
    lastOrderNumber = n;

    // Build order record
    final record = OrderRecord(
      id: _uuid.v4(),
      orderNumber: n,
      tableNumber: tableNumber,
      createdAt: DateTime.now(),
      items: _items.values.map((ci) => OrderedItem(
        itemId: ci.item.id, name: ci.item.name, emoji: ci.item.emoji,
        quantity: ci.quantity, price: ci.unitPrice,
        customSummary: ci.customisation.summary,
      )).toList(),
      total: grandTotal,
    );

    // Save to history
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('order_history') ?? [];
    existing.insert(0, jsonEncode(record.toJson()));
    if (existing.length > 50) existing.removeLast();
    await prefs.setStringList('order_history', existing);

    // Update loyalty points
    final pts = (prefs.getInt('loyalty_points') ?? 0) + earnedPoints - (usePoints ? loyaltyPoints : 0);
    await prefs.setInt('loyalty_points', pts.clamp(0, 99999));

    _items.clear();
    specialNotes = null;
    appliedCoupon = null;
    couponDiscount = 0;
    usePoints = false;
    notifyListeners();
    return n;
  }

  Future<void> loadLoyaltyPoints() async {
    final prefs = await SharedPreferences.getInstance();
    loyaltyPoints = prefs.getInt('loyalty_points') ?? 0;
    notifyListeners();
  }

  void reset() {
    _items.clear();
    lastOrderNumber = null;
    specialNotes = null;
    appliedCoupon = null;
    couponDiscount = 0;
    usePoints = false;
    notifyListeners();
  }
}
