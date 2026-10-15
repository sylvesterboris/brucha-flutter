# ☕ Brucha v2 — Complete Flutter Ordering App

Full-featured QR table ordering system with 16 features built in.

---

## 📁 Project Structure

```
lib/
├── main.dart                        ← App entry, MultiProvider, all routes
├── theme/app_theme.dart             ← Light + dark theme (Cormorant + Jost)
├── models/
│   ├── menu_item.dart               ← MenuItem + customGroups + dietaryTags + ratings + Hindi
│   └── order_model.dart             ← CartItem, CartCustomisation, OrderRecord, DailySpecial
├── providers/
│   ├── cart_provider.dart           ← Cart + coupons + loyalty points + order saving
│   └── app_provider.dart            ← Theme, locale, favourites, filters, ratings, availability, history
├── widgets/
│   ├── common_widgets.dart          ← BadgeChip, SectionHeader, QtyControl, GoldButton, StarRating
│   ├── menu_card.dart               ← Card with favourite ❤️, availability, ratings, customisation trigger
│   ├── cart_sheet.dart              ← Cart with coupons, loyalty, dismissible rows, notes
│   └── customisation_sheet.dart     ← Item customiser (milk, sugar, size, extras)
└── screens/
    ├── splash_screen.dart           ← Animated logo splash
    ├── menu_screen.dart             ← Full menu: search, dietary filters, favourites, daily special,
    │                                    call waiter, language toggle, dark mode toggle, category tabs
    ├── success_screen.dart          ← Order confirmed + live status tracker + dish rating
    ├── history_screen.dart          ← Order history + loyalty punch card + reorder
    ├── analytics_screen.dart        ← Sales dashboard (fl_chart) + item availability controls
    └── qr_admin_screen.dart         ← 12-table QR grid → analytics
```

---

## ✅ All 16 Features

| # | Feature | Screen | Effort |
|---|---------|--------|--------|
| 1 | **Call Waiter** button with snackbar notification | MenuScreen FAB | Easy |
| 2 | **Item Customiser** — milk type, sugar, size, extras, price update | customisation_sheet.dart | Medium |
| 3 | **Menu Search** — live filter by name/description/Hindi | MenuScreen AppBar | Easy |
| 4 | **Dietary Filters** — Veg, Vegan, Gluten-Free, Nut-Free toggle chips | MenuScreen | Easy |
| 5 | **Favourites ❤️** — heart on card, persisted, "Your Picks" section | MenuItemCard + AppProvider | Easy |
| 6 | **Order History** — all past orders, time-ago, items & total | history_screen.dart | Medium |
| 7 | **Reorder** — one-tap re-adds all items from a past order | HistoryScreen | Medium |
| 8 | **In-App Promo Codes** — validate, apply %, remove, shake on error | CartSheet | Medium |
| 9 | **Loyalty Points** — earn per order, redeem at checkout, punch card visual | CartProvider + HistoryScreen | Medium |
| 10 | **Item Availability** — staff toggle sold-out, card greyed + overlay | AppProvider + AnalyticsScreen | Medium |
| 11 | **Live Order Status** — Received → Preparing → Ready tracker | SuccessScreen | Hard |
| 12 | **Dish Ratings** — post-order star rating per item, shown on cards | SuccessScreen + AppProvider | Easy |
| 13 | **Sales Dashboard** — revenue, orders, top items bar chart, orders-by-hour line chart | analytics_screen.dart | Hard |
| 14 | **Daily Special** banner in hero with time-limited offer | MenuScreen hero | Medium |
| 15 | **Multi-language** — English ↔ Hindi toggle (menu names + UI) | AppProvider + all screens | Medium |
| 16 | **Dark Mode** — full dark palette, OS-aware, persistent toggle | BruchaTheme + AppProvider | Easy |

---

## 🚀 Setup

```bash
flutter pub get
flutter run
```

**Valid promo codes to test:**
- `BRUCHA10` → 10% off
- `WELCOME20` → 20% off
- `COFFEE15` → 15% off

---

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `google_fonts` | Cormorant Garamond + Jost |
| `provider` | State management (AppProvider + CartProvider) |
| `shared_preferences` | Persist favourites, ratings, history, loyalty points, theme, locale |
| `fl_chart` | Bar chart (top items) + Line chart (orders by hour) |
| `flutter_rating_bar` | Post-order dish star ratings |
| `qr_flutter` | QR code generation for each table |
| `flutter_staggered_animations` | Staggered grid animations |
| `confetti` | (Optional) confetti on "Ready" status |
| `uuid` | Unique order IDs |

---

## 🔗 QR Deep Linking

Each QR encodes: `https://brucha.cafe/menu?table=N`

**Android** `AndroidManifest.xml`:
```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="https" android:host="brucha.cafe"/>
</intent-filter>
```

**Read table in main.dart** (use `uni_links` package):
```dart
String _tableFromUri() {
  final uri = Uri.tryParse(PlatformDispatcher.instance.defaultRouteName);
  return uri?.queryParameters['table'] ?? '1';
}
```
