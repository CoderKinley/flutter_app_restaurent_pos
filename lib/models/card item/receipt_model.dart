class Receipt {
  final String id;
  final String date;
  final String time;
  final double totalAmount;
  final int? tableNumber;
  final String orderType;
  final List<Item> items;

  Receipt({
    required this.id,
    required this.date,
    required this.time,
    required this.totalAmount,
    this.tableNumber,
    required this.orderType,
    required this.items,
  });
}

class Item {
  final String name;
  final int quantity;
  final double price;

  Item({
    required this.name,
    required this.quantity,
    required this.price,
  });
}
