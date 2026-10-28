/// Oprema se osvaja PO ARTIKLU (zvonce, svetlo, zaštita od sunca, motor/baterija...)
/// i važi kroz sva vozila (bicikl -> trotinet -> e-bicikl -> skuter -> auto/teleport).
enum ItemSlot { bell, light, sunProtection, engine }

enum Vehicle { bike, scooter, eBike, moped, car }

class Item {
  final String id;
  final ItemSlot slot;
  final int tier;
  final String? color; // boje i ukrasi kao dodatna motivacija
  final int minPoints; // uslov za osvajanje, popunjavamo kasnije
  final Duration? maxAvgTime;

  const Item({
    required this.id,
    required this.slot,
    required this.tier,
    this.color,
    this.minPoints = 0,
    this.maxAvgTime,
  });
}
