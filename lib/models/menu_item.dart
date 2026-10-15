enum MenuCategory {
  hotCoffee,
  icedCoffee,
  frappes,
  tea,
  matcha,
  coolers,
  shakes,
  burgers,
  pasta,
  pizza,
  fries,
  nachos,
  garlicBreads,
  sandwiches,
  wraps,
  desserts,
}

extension MenuCategoryX on MenuCategory {
  String get label {
    switch (this) {
      case MenuCategory.hotCoffee:   return 'Hot Coffee';
      case MenuCategory.icedCoffee:  return 'Iced Coffee';
      case MenuCategory.frappes:     return 'Frappes';
      case MenuCategory.tea:         return 'Tea';
      case MenuCategory.matcha:      return 'Matcha Special';
      case MenuCategory.coolers:     return 'Yummm Coolers';
      case MenuCategory.shakes:      return 'Shake It Up';
      case MenuCategory.burgers:     return 'Burgers';
      case MenuCategory.pasta:       return 'Pasta';
      case MenuCategory.pizza:       return 'Pizza – 6pc';
      case MenuCategory.fries:       return 'Fries';
      case MenuCategory.nachos:      return 'Nachos';
      case MenuCategory.garlicBreads:return 'Garlic Breads & Snacks';
      case MenuCategory.sandwiches:  return 'Sandwiches';
      case MenuCategory.wraps:       return 'Tortilla Wraps';
      case MenuCategory.desserts:    return 'Desserts';
    }
  }

  String get tabEmoji {
    switch (this) {
      case MenuCategory.hotCoffee:   return '☕';
      case MenuCategory.icedCoffee:  return '🧊';
      case MenuCategory.frappes:     return '🥤';
      case MenuCategory.tea:         return '🍵';
      case MenuCategory.matcha:      return '🍵✨';
      case MenuCategory.coolers:     return '🍋';
      case MenuCategory.shakes:      return '🥛';
      case MenuCategory.burgers:     return '🍔';
      case MenuCategory.pasta:       return '🍝';
      case MenuCategory.pizza:       return '🍕';
      case MenuCategory.fries:       return '🍟';
      case MenuCategory.nachos:      return '🫔';
      case MenuCategory.garlicBreads:return '🥖';
      case MenuCategory.sandwiches:  return '🥪';
      case MenuCategory.wraps:       return '🌯';
      case MenuCategory.desserts:    return '🍰';
    }
  }

  // Group for tab bar display
  String get groupLabel {
    switch (this) {
      case MenuCategory.hotCoffee:
      case MenuCategory.icedCoffee:
      case MenuCategory.frappes:
      case MenuCategory.tea:
      case MenuCategory.matcha:    return 'Drinks';
      case MenuCategory.coolers:
      case MenuCategory.shakes:    return 'Coolers';
      case MenuCategory.burgers:
      case MenuCategory.pasta:
      case MenuCategory.pizza:     return 'Mains';
      case MenuCategory.fries:
      case MenuCategory.nachos:
      case MenuCategory.garlicBreads:
      case MenuCategory.sandwiches:
      case MenuCategory.wraps:     return 'Bites';
      case MenuCategory.desserts:  return 'Sweets';
    }
  }
}

enum BadgeType { none, popular, veg, newItem, nonVeg }

enum DietaryTag { veg, vegan, glutenFree, nutFree }

class CustomOption {
  final String label;
  final double extraPrice;
  const CustomOption(this.label, {this.extraPrice = 0});
}

class CustomGroup {
  final String title;
  final List<CustomOption> options;
  final bool multiSelect;
  const CustomGroup({required this.title, required this.options, this.multiSelect = false});
}

class MenuItem {
  final int id;
  final MenuCategory category;
  final String emoji;
  final String name;
  final String nameHi;
  final String description;
  final String descriptionHi;
  final double price;
  final BadgeType badge;
  final Set<DietaryTag> dietaryTags;
  final List<CustomGroup> customGroups;
  double rating;
  int ratingCount;

  MenuItem({
    required this.id,
    required this.category,
    required this.emoji,
    required this.name,
    this.nameHi = '',
    required this.description,
    this.descriptionHi = '',
    required this.price,
    this.badge = BadgeType.none,
    this.dietaryTags = const {},
    this.customGroups = const [],
    this.rating = 0,
    this.ratingCount = 0,
  });

  double get displayRating => ratingCount == 0 ? 0 : rating / ratingCount;
}

// ── SHARED CUSTOM GROUPS ─────────────────────────────────────────────────────
final _milkGroup = CustomGroup(title: 'Choice of Milk', options: [
  const CustomOption('Regular'),
  const CustomOption('Almond Milk', extraPrice: 79),
  const CustomOption('Lactose-Free (Amul)', extraPrice: 79),
  const CustomOption('Oat Milk', extraPrice: 79),
]);

final _coffeeAddons = CustomGroup(title: 'Add-ons', multiSelect: true, options: [
  const CustomOption('Irish Syrup', extraPrice: 49),
  const CustomOption('Hazelnut Syrup', extraPrice: 49),
  const CustomOption('Caramel Syrup', extraPrice: 49),
  const CustomOption('Espresso Shot', extraPrice: 49),
  const CustomOption('Chocolate', extraPrice: 49),
]);

final _icedCoffeeAddons = CustomGroup(title: 'Add-ons', multiSelect: true, options: [
  const CustomOption('Hazelnut', extraPrice: 49),
  const CustomOption('Caramel', extraPrice: 49),
  const CustomOption('Irish', extraPrice: 49),
  const CustomOption('Coconut', extraPrice: 49),
  const CustomOption('Whipped Cream', extraPrice: 49),
]);

final _frappe_protein = CustomGroup(title: 'Add-ons', multiSelect: true, options: [
  const CustomOption('Protein Scoop', extraPrice: 99),
]);

final _shakeAddons = CustomGroup(title: 'Add-ons', options: [
  const CustomOption('No Add-on'),
  const CustomOption('Protein Scoop', extraPrice: 99),
]);

final _chickenAddon = CustomGroup(title: 'Add-ons', multiSelect: true, options: [
  const CustomOption('Chicken', extraPrice: 69),
]);

final _garlicSizeGroup = CustomGroup(title: 'Size', options: [
  const CustomOption('2 pcs'),
  const CustomOption('4 pcs', extraPrice: 70),
]);

final _cheeseAddon = CustomGroup(title: 'Add-ons', multiSelect: true, options: [
  const CustomOption('Cheese Slice/Cheese Dip', extraPrice: 30),
]);

final _iceCreamAddon = CustomGroup(title: 'Add-ons', multiSelect: true, options: [
  const CustomOption('Ice Cream', extraPrice: 50),
]);

// ── COMPLETE BRUCHA MENU ─────────────────────────────────────────────────────
List<MenuItem> kMenu = [

  // ── HOT COFFEE ──────────────────────────────────────────────────────────────
  MenuItem(id:101, category:MenuCategory.hotCoffee, emoji:'☕', name:'Espresso',
      description:'Strong, concentrated coffee',                           price:99,
      dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup,_coffeeAddons]),
  MenuItem(id:102, category:MenuCategory.hotCoffee, emoji:'☕', name:'Americano',
      description:'Espresso, hot water',                                   price:129,
      dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup,_coffeeAddons]),
  MenuItem(id:103, category:MenuCategory.hotCoffee, emoji:'☕', name:'Cappuccino',
      description:'Espresso, steamed milk, foam',                          price:149,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup,_coffeeAddons]),
  MenuItem(id:104, category:MenuCategory.hotCoffee, emoji:'☕', name:'Jaggery Cappuccino',
      description:'Espresso, steamed milk, jaggery',                       price:159,
      badge:BadgeType.newItem, dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup]),
  MenuItem(id:105, category:MenuCategory.hotCoffee, emoji:'☕', name:'Caffè Latte',
      description:'Espresso, steamed milk',                                 price:149,
      dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup,_coffeeAddons]),
  MenuItem(id:106, category:MenuCategory.hotCoffee, emoji:'☕', name:'French Vanilla Latte',
      description:'Espresso, steamed milk, vanilla syrup',                  price:179,
      dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup,_coffeeAddons]),
  MenuItem(id:107, category:MenuCategory.hotCoffee, emoji:'☕', name:'Jaggery Latte',
      description:'Espresso, steamed milk, jaggery',                        price:159,
      dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup]),
  MenuItem(id:108, category:MenuCategory.hotCoffee, emoji:'☕', name:'Caffè Mocha',
      description:'Espresso, chocolate, steamed milk',                       price:179,
      dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup,_coffeeAddons]),
  MenuItem(id:109, category:MenuCategory.hotCoffee, emoji:'☕', name:'Caramel Mocha',
      description:'Espresso, chocolate, steamed milk, caramel',              price:229,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup,_coffeeAddons]),
  MenuItem(id:110, category:MenuCategory.hotCoffee, emoji:'☕', name:'Filter Coffee',
      description:'Ground coffee, hot water, milk',                          price:139,
      dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup]),
  MenuItem(id:111, category:MenuCategory.hotCoffee, emoji:'☕', name:'Cortado',
      description:'Equal parts of espresso, steamed milk',                   price:159,
      dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup]),
  MenuItem(id:112, category:MenuCategory.hotCoffee, emoji:'☕', name:'Macchiato',
      description:'Espresso, milk foam',                                      price:130,
      dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup,_coffeeAddons]),
  MenuItem(id:113, category:MenuCategory.hotCoffee, emoji:'🍫', name:'Brucha Special Hot Chocolate',
      description:'Melted chocolate, milk, whipped cream',                    price:209,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup]),
  MenuItem(id:114, category:MenuCategory.hotCoffee, emoji:'☕', name:'Affogato',
      description:'Espresso, vanilla ice cream',                              price:159,
      dietaryTags:{DietaryTag.veg}),

  // ── ICED COFFEE ─────────────────────────────────────────────────────────────
  MenuItem(id:201, category:MenuCategory.icedCoffee, emoji:'🧊', name:'Iced Cappuccino',
      description:'Espresso, cold milk, foam',                               price:149,
      dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup,_icedCoffeeAddons]),
  MenuItem(id:202, category:MenuCategory.icedCoffee, emoji:'🧊', name:'Iced Americano',
      description:'Espresso, cold water, ice',                               price:139,
      dietaryTags:{DietaryTag.veg}, customGroups:[_icedCoffeeAddons]),
  MenuItem(id:203, category:MenuCategory.icedCoffee, emoji:'🧊', name:'Iced Latte',
      description:'Espresso, cold milk, ice',                                 price:159,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup,_icedCoffeeAddons]),
  MenuItem(id:204, category:MenuCategory.icedCoffee, emoji:'🧊', name:'Iced Mocha',
      description:'Espresso, chocolate, cold milk, ice',                      price:169,
      dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup,_icedCoffeeAddons]),
  MenuItem(id:205, category:MenuCategory.icedCoffee, emoji:'🧊', name:'Vietnamese Coffee',
      description:'Strong coffee, sweetened condensed milk, ice',              price:179,
      badge:BadgeType.newItem, dietaryTags:{DietaryTag.veg}),

  // ── FRAPPES ─────────────────────────────────────────────────────────────────
  MenuItem(id:301, category:MenuCategory.frappes, emoji:'🥤', name:'Classic Cold Coffee',
      description:'Smooth classic cold coffee frappe',                         price:149,
      dietaryTags:{DietaryTag.veg}, customGroups:[_frappe_protein]),
  MenuItem(id:302, category:MenuCategory.frappes, emoji:'🥤', name:'Chef Special Cold Coffee',
      description:'Brucha\'s signature blend frappe',                          price:189,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}, customGroups:[_frappe_protein]),
  MenuItem(id:303, category:MenuCategory.frappes, emoji:'🥤', name:'Mocha Frappe',
      description:'Rich mocha flavoured frappe',                               price:179,
      dietaryTags:{DietaryTag.veg}, customGroups:[_frappe_protein]),
  MenuItem(id:304, category:MenuCategory.frappes, emoji:'🥤', name:'Mocha Choco Chip Frappe',
      description:'Mocha with chocolate chips blended in',                     price:189,
      dietaryTags:{DietaryTag.veg}, customGroups:[_frappe_protein]),
  MenuItem(id:305, category:MenuCategory.frappes, emoji:'🥤', name:'French Vanilla Frappe',
      description:'Creamy French vanilla frappe',                              price:189,
      dietaryTags:{DietaryTag.veg}, customGroups:[_frappe_protein]),
  MenuItem(id:306, category:MenuCategory.frappes, emoji:'🥤', name:'Caramel Frappe',
      description:'Sweet caramel frappe',                                      price:189,
      dietaryTags:{DietaryTag.veg}, customGroups:[_frappe_protein]),
  MenuItem(id:307, category:MenuCategory.frappes, emoji:'🥤', name:'Hazelnut Frappe',
      description:'Rich hazelnut frappe',                                      price:189,
      dietaryTags:{DietaryTag.veg}, customGroups:[_frappe_protein]),
  MenuItem(id:308, category:MenuCategory.frappes, emoji:'🥤', name:'Irish Frappe',
      description:'Irish flavoured cold frappe',                               price:189,
      dietaryTags:{DietaryTag.veg}, customGroups:[_frappe_protein]),
  MenuItem(id:309, category:MenuCategory.frappes, emoji:'🥤', name:'Lotus Biscoff Frappe',
      description:'Lotus Biscoff blended frappe',                              price:229,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}, customGroups:[_frappe_protein]),
  MenuItem(id:310, category:MenuCategory.frappes, emoji:'🥤', name:'Tiramisu Frappe',
      description:'Tiramisu inspired frappe',                                  price:189,
      dietaryTags:{DietaryTag.veg}, customGroups:[_frappe_protein]),
  MenuItem(id:311, category:MenuCategory.frappes, emoji:'🥤', name:'Coconut Frappe',
      description:'Refreshing coconut frappe',                                 price:189,
      dietaryTags:{DietaryTag.veg, DietaryTag.vegan}, customGroups:[_frappe_protein]),

  // ── TEA ─────────────────────────────────────────────────────────────────────
  MenuItem(id:401, category:MenuCategory.tea, emoji:'🍵', name:'Brucha Special Masala Chai',
      description:'House blend spiced masala chai',                            price:89,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}),
  MenuItem(id:402, category:MenuCategory.tea, emoji:'🍵', name:'Green Tea',
      description:'Light, refreshing green tea',                               price:89,
      dietaryTags:{DietaryTag.veg, DietaryTag.vegan}),
  MenuItem(id:403, category:MenuCategory.tea, emoji:'🍵', name:'Honey Ginger Lemon Tea',
      description:'Soothing honey, ginger & lemon blend',                      price:89,
      dietaryTags:{DietaryTag.veg, DietaryTag.vegan}),

  // ── MATCHA SPECIAL ──────────────────────────────────────────────────────────
  MenuItem(id:410, category:MenuCategory.matcha, emoji:'🍓🍵', name:'Baddie Matcha (Strawberry)',
      description:'Vibrant pink strawberry puree meets premium organic matcha and cold milk', price:219,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup]),
  MenuItem(id:411, category:MenuCategory.matcha, emoji:'🍦🍵', name:'Vanilla Matcha',
      description:'Smooth vanilla syrup layered with Uji matcha and chilled milk',     price:199,
      dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup]),
  MenuItem(id:412, category:MenuCategory.matcha, emoji:'🥭🍵', name:'Mango Matcha',
      description:'Sweet tropical mango puree crowned with earthy matcha layers',       price:219,
      badge:BadgeType.newItem, dietaryTags:{DietaryTag.veg}, customGroups:[_milkGroup]),

  // ── YUMMM COOLERS ────────────────────────────────────────────────────────────
  MenuItem(id:501, category:MenuCategory.coolers, emoji:'🍋', name:'Classic Lemonade',
      description:'Freshly squeezed classic lemonade',                         price:129,
      dietaryTags:{DietaryTag.veg, DietaryTag.vegan}),
  MenuItem(id:502, category:MenuCategory.coolers, emoji:'🥤', name:'Masala Coke',
      description:'Chilled coke with masala twist',                            price:129,
      dietaryTags:{DietaryTag.veg, DietaryTag.vegan}),
  MenuItem(id:503, category:MenuCategory.coolers, emoji:'🍋', name:'Lemon Iced Tea',
      description:'Refreshing lemon iced tea',                                 price:149,
      dietaryTags:{DietaryTag.veg, DietaryTag.vegan}),
  MenuItem(id:504, category:MenuCategory.coolers, emoji:'🍑', name:'Peach Iced Tea',
      description:'Chilled peach iced tea',                                    price:149,
      dietaryTags:{DietaryTag.veg, DietaryTag.vegan}),
  MenuItem(id:505, category:MenuCategory.coolers, emoji:'🍹', name:'Passionfruit Mojito',
      description:'Tropical passionfruit mojito',                              price:169,
      dietaryTags:{DietaryTag.veg, DietaryTag.vegan}),
  MenuItem(id:506, category:MenuCategory.coolers, emoji:'🌿', name:'Virgin Mint Mojito',
      description:'Classic refreshing mint mojito',                            price:149,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg, DietaryTag.vegan}),
  MenuItem(id:507, category:MenuCategory.coolers, emoji:'🍉', name:'Watermelon Mint Mojito',
      description:'Watermelon & mint mojito',                                  price:169,
      dietaryTags:{DietaryTag.veg, DietaryTag.vegan}),
  MenuItem(id:508, category:MenuCategory.coolers, emoji:'🌶️', name:'Spicy Mango Mojito',
      description:'Tangy mango with a spicy kick',                             price:169,
      dietaryTags:{DietaryTag.veg, DietaryTag.vegan}),
  MenuItem(id:509, category:MenuCategory.coolers, emoji:'🍋', name:'Zesty Lemon Mojito',
      description:'Zesty lemon mojito with mint',                              price:169,
      dietaryTags:{DietaryTag.veg, DietaryTag.vegan}),
  MenuItem(id:510, category:MenuCategory.coolers, emoji:'🥝', name:'Kiwi Mint Cooler',
      description:'Fresh kiwi and mint cooler',                                price:169,
      dietaryTags:{DietaryTag.veg, DietaryTag.vegan}),
  MenuItem(id:511, category:MenuCategory.coolers, emoji:'🍒', name:'Cranberry Mojito',
      description:'Tangy cranberry mojito',                                    price:169,
      dietaryTags:{DietaryTag.veg, DietaryTag.vegan}),
  MenuItem(id:512, category:MenuCategory.coolers, emoji:'🍏', name:'Green Apple Punch Mojito',
      description:'Green apple punch with mojito base',                        price:169,
      dietaryTags:{DietaryTag.veg, DietaryTag.vegan}),

  // ── SHAKES ──────────────────────────────────────────────────────────────────
  MenuItem(id:601, category:MenuCategory.shakes, emoji:'🥛', name:'Vanilla Shake',
      description:'Classic creamy vanilla milkshake',                          price:149,
      dietaryTags:{DietaryTag.veg}, customGroups:[_shakeAddons]),
  MenuItem(id:602, category:MenuCategory.shakes, emoji:'🍓', name:'Classic Strawberry Shake',
      description:'Fresh strawberry milkshake',                                price:149,
      dietaryTags:{DietaryTag.veg}, customGroups:[_shakeAddons]),
  MenuItem(id:603, category:MenuCategory.shakes, emoji:'🍫', name:'Classic Chocolate Shake',
      description:'Rich chocolate milkshake',                                  price:199,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}, customGroups:[_shakeAddons]),
  MenuItem(id:604, category:MenuCategory.shakes, emoji:'🍪', name:'Lotus Biscoff Shake',
      description:'Lotus Biscoff blended milkshake',                           price:199,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}, customGroups:[_shakeAddons]),
  MenuItem(id:605, category:MenuCategory.shakes, emoji:'🍫', name:'Nutella Brownie Shake',
      description:'Nutella and brownie milkshake',                             price:179,
      dietaryTags:{DietaryTag.veg}, customGroups:[_shakeAddons]),
  MenuItem(id:606, category:MenuCategory.shakes, emoji:'☕', name:'Tiramisu Shake',
      description:'Tiramisu inspired milkshake',                               price:179,
      dietaryTags:{DietaryTag.veg}, customGroups:[_shakeAddons]),
  MenuItem(id:607, category:MenuCategory.shakes, emoji:'🍪', name:'Chocolate Oreo Shake',
      description:'Chocolate and Oreo milkshake',                              price:179,
      dietaryTags:{DietaryTag.veg}, customGroups:[_shakeAddons]),
  MenuItem(id:608, category:MenuCategory.shakes, emoji:'🥭', name:'Mango Cheese Shake',
      description:'Mango with cream cheese milkshake',                         price:179,
      dietaryTags:{DietaryTag.veg}, customGroups:[_shakeAddons]),
  MenuItem(id:609, category:MenuCategory.shakes, emoji:'🫐', name:'Blueberry Shake',
      description:'Fresh blueberry milkshake',                                 price:189,
      dietaryTags:{DietaryTag.veg}, customGroups:[_shakeAddons]),
  MenuItem(id:610, category:MenuCategory.shakes, emoji:'🍫', name:'KitKat Shake',
      description:'KitKat blended milkshake',                                  price:179,
      dietaryTags:{DietaryTag.veg}, customGroups:[_shakeAddons]),
  MenuItem(id:611, category:MenuCategory.shakes, emoji:'🍓', name:'Mixed Berry Shake',
      description:'Mixed berry milkshake',                                     price:189,
      dietaryTags:{DietaryTag.veg}, customGroups:[_shakeAddons]),
  MenuItem(id:612, category:MenuCategory.shakes, emoji:'🍫', name:'Chocolate Brownie Shake',
      description:'Rich chocolate brownie milkshake',                          price:199,
      dietaryTags:{DietaryTag.veg}, customGroups:[_shakeAddons]),
  MenuItem(id:613, category:MenuCategory.shakes, emoji:'🥜', name:'Peanut Butter Caramel Shake',
      description:'Peanut butter & caramel milkshake',                         price:199,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}, customGroups:[_shakeAddons]),

  // ── BURGERS ─────────────────────────────────────────────────────────────────
  MenuItem(id:701, category:MenuCategory.burgers, emoji:'🍔', name:'Aloo Patty Burger',
      description:'Classic aloo patty burger',                                  price:99,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}),
  MenuItem(id:702, category:MenuCategory.burgers, emoji:'🍔', name:'Cheese Veggie Crunch Burger',
      description:'Crispy veggie patty with cheese',                            price:139,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}),
  MenuItem(id:703, category:MenuCategory.burgers, emoji:'🍔', name:'Grilled Paneer Burger',
      description:'Juicy grilled paneer burger',                                price:169,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}),
  MenuItem(id:704, category:MenuCategory.burgers, emoji:'🍔', name:'Grilled Chicken Burger',
      description:'Tender grilled chicken burger',                              price:169,
      badge:BadgeType.popular),
  MenuItem(id:705, category:MenuCategory.burgers, emoji:'🍔', name:'BBQ Chicken Burger',
      description:'Smoky BBQ sauce chicken burger',                             price:169),

  // ── PASTA ───────────────────────────────────────────────────────────────────
  MenuItem(id:801, category:MenuCategory.pasta, emoji:'🍝', name:'White Sauce Pasta with Veggies',
      description:'Creamy white sauce with garden veggies',                     price:229,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}, customGroups:[_chickenAddon]),
  MenuItem(id:802, category:MenuCategory.pasta, emoji:'🍝', name:'Red Sauce Pasta with Veggies',
      description:'Tangy tomato red sauce with veggies',                        price:229,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}, customGroups:[_chickenAddon]),
  MenuItem(id:803, category:MenuCategory.pasta, emoji:'🍝', name:'Pink Sauce Pasta with Veggies',
      description:'Signature pink sauce blend with veggies',                    price:249,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}, customGroups:[_chickenAddon]),

  // ── PIZZA ───────────────────────────────────────────────────────────────────
  MenuItem(id:901, category:MenuCategory.pizza, emoji:'🍕', name:'Margherita',
      description:'Classic tomato sauce & mozzarella',                          price:219,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}),
  MenuItem(id:902, category:MenuCategory.pizza, emoji:'🍕', name:'Veggie Pizza',
      description:'Fresh garden vegetables on pizza base',                      price:249,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}),
  MenuItem(id:903, category:MenuCategory.pizza, emoji:'🍕', name:'Veggie Farmhouse',
      description:'Loaded farmhouse veggie pizza',                              price:279,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}),
  MenuItem(id:904, category:MenuCategory.pizza, emoji:'🍕', name:'Cheese Golden Corn Pizza',
      description:'Golden corn with extra cheese',                              price:239,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}),
  MenuItem(id:905, category:MenuCategory.pizza, emoji:'🍕', name:'Peppy Paneer Pizza',
      description:'Spicy paneer with peppers',                                  price:289,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}),
  MenuItem(id:906, category:MenuCategory.pizza, emoji:'🍕', name:'Peri Peri Chicken Pizza',
      description:'Fiery peri peri chicken pizza',                              price:289,
      badge:BadgeType.popular),
  MenuItem(id:907, category:MenuCategory.pizza, emoji:'🍕', name:'BBQ Chicken Pizza',
      description:'Smoky BBQ chicken with onions',                              price:299),

  // ── FRIES ───────────────────────────────────────────────────────────────────
  MenuItem(id:1001, category:MenuCategory.fries, emoji:'🍟', name:'Salted Fries',
      description:'Classic crispy salted fries',                                price:120,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}),
  MenuItem(id:1002, category:MenuCategory.fries, emoji:'🍟', name:'Loaded Cheese Fries',
      description:'Fries loaded with melted cheese',                            price:179,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}),
  MenuItem(id:1003, category:MenuCategory.fries, emoji:'🍟', name:'Peri Peri Fries',
      description:'Fries tossed in peri peri spice',                            price:149,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}),
  MenuItem(id:1004, category:MenuCategory.fries, emoji:'🍟', name:'Cheese Peri Peri Fries',
      description:'Peri peri fries with cheese drizzle',                        price:169,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}),
  MenuItem(id:1005, category:MenuCategory.fries, emoji:'🍟', name:'Jalapeno Cheese Fries',
      description:'Cheesy fries with jalapeno kick',                            price:189,
      dietaryTags:{DietaryTag.veg}),
  MenuItem(id:1006, category:MenuCategory.fries, emoji:'🍟', name:'Peri Peri Chicken Fries',
      description:'Peri peri fries topped with chicken',                        price:219),
  MenuItem(id:1007, category:MenuCategory.fries, emoji:'🍟', name:'Chicken Strips (8 pcs)',
      description:'Crispy chicken strips, 8 pieces',                            price:229),
  MenuItem(id:1008, category:MenuCategory.fries, emoji:'🍟', name:'Chicken Loaded Fries',
      description:'Fries loaded with spiced chicken',                           price:199,
      badge:BadgeType.popular),

  // ── NACHOS ──────────────────────────────────────────────────────────────────
  MenuItem(id:1101, category:MenuCategory.nachos, emoji:'🫔', name:'Cheese Corn Nachos',
      description:'Crispy nachos with cheese & corn',                           price:139,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}),
  MenuItem(id:1102, category:MenuCategory.nachos, emoji:'🫔', name:'Mexican Baked Nachos',
      description:'Oven baked Mexican style nachos',                            price:169,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}, customGroups:[_chickenAddon]),

  // ── GARLIC BREADS & SNACKS ───────────────────────────────────────────────────
  MenuItem(id:1201, category:MenuCategory.garlicBreads, emoji:'🥖', name:'Chilli Cheese Garlic Bread',
      description:'Spicy chilli cheese garlic bread',                           price:99,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}, customGroups:[_garlicSizeGroup]),
  MenuItem(id:1202, category:MenuCategory.garlicBreads, emoji:'🥖', name:'Corn Cheese Garlic Bread',
      description:'Sweet corn with cheese garlic bread',                        price:99,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}, customGroups:[_garlicSizeGroup]),
  MenuItem(id:1203, category:MenuCategory.garlicBreads, emoji:'🥖', name:'Mushroom Cheese Garlic Bread',
      description:'Sautéed mushroom with cheese garlic bread',                  price:119,
      dietaryTags:{DietaryTag.veg}, customGroups:[_garlicSizeGroup]),
  MenuItem(id:1204, category:MenuCategory.garlicBreads, emoji:'🥖', name:'Tomato Basil Bruschetta',
      description:'Fresh tomato basil bruschetta',                              price:149,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}, customGroups:[_garlicSizeGroup]),
  MenuItem(id:1205, category:MenuCategory.garlicBreads, emoji:'🥖', name:'Paneer Garlic Bread',
      description:'Seasoned paneer on garlic bread',                            price:149,
      dietaryTags:{DietaryTag.veg}, customGroups:[_garlicSizeGroup]),
  MenuItem(id:1206, category:MenuCategory.garlicBreads, emoji:'🥖', name:'Chicken Garlic Bread',
      description:'Spiced chicken on garlic bread',                             price:149, customGroups:[_garlicSizeGroup]),
  MenuItem(id:1207, category:MenuCategory.garlicBreads, emoji:'🥑', name:'Avocado Guac Open Toastie',
      description:'Fresh avocado guacamole on toast',                           price:99,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}),
  MenuItem(id:1208, category:MenuCategory.garlicBreads, emoji:'🍜', name:'Plain Maggi',
      description:'Classic Maggi noodles',                                      price:99,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}),
  MenuItem(id:1209, category:MenuCategory.garlicBreads, emoji:'🍜', name:'Cheese Masala Maggi',
      description:'Maggi noodles with cheese & masala',                         price:139,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}),

  // ── SANDWICHES ──────────────────────────────────────────────────────────────
  MenuItem(id:1301, category:MenuCategory.sandwiches, emoji:'🥪', name:'Paneer Tikka Sandwich',
      description:'Spiced paneer tikka sandwich, 4 pcs',                        price:189,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}, customGroups:[_cheeseAddon]),
  MenuItem(id:1302, category:MenuCategory.sandwiches, emoji:'🥪', name:'Peri Peri Paneer Sandwich',
      description:'Peri peri spiced paneer sandwich, 4 pcs',                    price:199,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}, customGroups:[_cheeseAddon]),
  MenuItem(id:1303, category:MenuCategory.sandwiches, emoji:'🥪', name:'Corn and Cheese Sandwich',
      description:'Sweet corn & cheese sandwich, 4 pcs',                        price:189,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}, customGroups:[_cheeseAddon]),
  MenuItem(id:1304, category:MenuCategory.sandwiches, emoji:'🥪', name:'Classic Grilled Sandwich',
      description:'Classic grilled veggie sandwich, 4 pcs',                     price:199,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}, customGroups:[_cheeseAddon]),
  MenuItem(id:1305, category:MenuCategory.sandwiches, emoji:'🥪', name:'Chicken Tikka Sandwich',
      description:'Spiced chicken tikka sandwich, 4 pcs',                       price:199, customGroups:[_cheeseAddon]),
  MenuItem(id:1306, category:MenuCategory.sandwiches, emoji:'🥪', name:'Peri Peri Chicken Sandwich',
      description:'Fiery peri peri chicken sandwich, 4 pcs',                    price:209,
      badge:BadgeType.popular, customGroups:[_cheeseAddon]),

  // ── TORTILLA WRAPS ───────────────────────────────────────────────────────────
  MenuItem(id:1401, category:MenuCategory.wraps, emoji:'🌯', name:'Aloo Patty Wrap',
      description:'Classic aloo patty in tortilla wrap',                        price:149,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}, customGroups:[_cheeseAddon]),
  MenuItem(id:1402, category:MenuCategory.wraps, emoji:'🌯', name:'Fresh Veggie Cheese Corn Wrap',
      description:'Fresh veggies with cheese & corn',                           price:169,
      badge:BadgeType.veg, dietaryTags:{DietaryTag.veg}, customGroups:[_cheeseAddon]),
  MenuItem(id:1403, category:MenuCategory.wraps, emoji:'🌯', name:'Paneer Tikka Wrap',
      description:'Spiced paneer tikka tortilla wrap',                          price:179,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}, customGroups:[_cheeseAddon]),
  MenuItem(id:1404, category:MenuCategory.wraps, emoji:'🌯', name:'Chicken Tikka Wrap',
      description:'Spiced chicken tikka in tortilla',                           price:189, customGroups:[_cheeseAddon]),
  MenuItem(id:1405, category:MenuCategory.wraps, emoji:'🌯', name:'BBQ Chicken Wrap',
      description:'Smoky BBQ chicken tortilla wrap',                            price:199, customGroups:[_cheeseAddon]),
  MenuItem(id:1406, category:MenuCategory.wraps, emoji:'🌯', name:'Chicken Seekh Wrap',
      description:'Juicy chicken seekh kebab wrap',                             price:199,
      badge:BadgeType.popular, customGroups:[_cheeseAddon]),

  // ── DESSERTS ─────────────────────────────────────────────────────────────────
  MenuItem(id:1501, category:MenuCategory.desserts, emoji:'🍫', name:'Choco Brownie with Ice Cream',
      description:'Warm chocolate brownie with ice cream scoop',                price:139,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}),
  MenuItem(id:1502, category:MenuCategory.desserts, emoji:'🧇', name:'Nutella Waffle',
      description:'Crispy waffle with Nutella spread',                          price:159,
      badge:BadgeType.popular, dietaryTags:{DietaryTag.veg}, customGroups:[_iceCreamAddon]),
  MenuItem(id:1503, category:MenuCategory.desserts, emoji:'🧇', name:'Chocolate Waffle',
      description:'Classic chocolate waffle',                                   price:139,
      dietaryTags:{DietaryTag.veg}, customGroups:[_iceCreamAddon]),
  MenuItem(id:1504, category:MenuCategory.desserts, emoji:'🧇', name:'Blueberry Waffle',
      description:'Waffle with blueberry topping',                              price:149,
      dietaryTags:{DietaryTag.veg}, customGroups:[_iceCreamAddon]),
];
