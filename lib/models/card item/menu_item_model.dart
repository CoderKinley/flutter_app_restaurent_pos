// menu_item.dart
class MenuItem {
  final int id;
  final String name;
  final double price;
  final String image;
  int quantity;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
  });

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'],
      name: map['name'],
      price: map['price'].toDouble(),
      image: map['image'],
      quantity: map['quantity'],
    );
  }
}
