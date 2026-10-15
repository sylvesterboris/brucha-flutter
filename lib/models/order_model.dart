import 'menu_item.dart';

class CartCustomisation {
  final Map<String, List<String>> selections; // groupTitle -> selected option labels
  double extraCost;

  CartCustomisation({Map<String, List<String>>? selections, this.extraCost = 0})
      : selections = selections ?? {};

  String get summary {
    final parts = <String>[];
    for (final e in selections.entries) {
      if (e.value.isNotEmpty) parts.addAll(e.value);
    }
    return parts.join(' · ');
  }

  Map<String, dynamic> toJson() => {'selections': selections.map((k,v)=>MapEntry(k,v)), 'extraCost': extraCost};
}

class CartItem {
  final MenuItem item;
  int quantity;
  CartCustomisation customisation;

  CartItem({required this.item, this.quantity = 1, CartCustomisation? customisation})
      : customisation = customisation ?? CartCustomisation();

  double get lineTotal => (item.price + customisation.extraCost) * quantity;
  double get unitPrice => item.price + customisation.extraCost;
}

class OrderRecord {
  final String id;
  final String orderNumber;
  final String tableNumber;
  final DateTime createdAt;
  final List<OrderedItem> items;
  final double total;
  String status; // received, preparing, ready, delivered

  OrderRecord({
    required this.id,
    required this.orderNumber,
    required this.tableNumber,
    required this.createdAt,
    required this.items,
    required this.total,
    this.status = 'received',
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'orderNumber': orderNumber, 'tableNumber': tableNumber,
    'createdAt': createdAt.toIso8601String(),
    'items': items.map((i) => i.toJson()).toList(),
    'total': total, 'status': status,
  };

  factory OrderRecord.fromJson(Map<String, dynamic> j) => OrderRecord(
    id: j['id'], orderNumber: j['orderNumber'], tableNumber: j['tableNumber'],
    createdAt: DateTime.parse(j['createdAt']),
    items: (j['items'] as List).map((i) => OrderedItem.fromJson(i)).toList(),
    total: (j['total'] as num).toDouble(),
    status: j['status'] ?? 'received',
  );
}

class OrderedItem {
  final int itemId;
  final String name;
  final String emoji;
  final int quantity;
  final double price;
  final String customSummary;

  OrderedItem({required this.itemId, required this.name, required this.emoji,
      required this.quantity, required this.price, this.customSummary = ''});

  Map<String, dynamic> toJson() => {'itemId': itemId, 'name': name, 'emoji': emoji,
      'quantity': quantity, 'price': price, 'customSummary': customSummary};

  factory OrderedItem.fromJson(Map<String, dynamic> j) => OrderedItem(
    itemId: j['itemId'], name: j['name'], emoji: j['emoji'],
    quantity: j['quantity'], price: (j['price'] as num).toDouble(),
    customSummary: j['customSummary'] ?? '',
  );
}

class DailySpecial {
  final int itemId;
  final String title;
  final double discountPercent;
  final DateTime validUntil;

  const DailySpecial({required this.itemId, required this.title,
      required this.discountPercent, required this.validUntil});

  bool get isValid => DateTime.now().isBefore(validUntil);
}
