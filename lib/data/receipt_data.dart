import 'dart:math';

import 'package:pos_system_legphel/models/card%20item/receipt_model.dart';

class ReceiptRepository {
  List<Receipt> fetchReceipts() {
    return List.generate(10, (index) {
      return Receipt(
        id: generateUniqueId(),
        date: "2025-02-07",
        time: generateRandomTime(),
        totalAmount: generateRandomTotal(),
        tableNumber: getRandomTableNumber(),
        orderType: getRandomOrderType(),
        items: generateRandomItems(),
      );
    });
  }

  String generateUniqueId() {
    Random random = Random();
    return "#${random.nextInt(999999).toString().padLeft(6, '0')}";
  }

  String generateRandomTime() {
    Random random = Random();
    int hour = random.nextInt(12) + 1;
    int minute = random.nextInt(60);
    String period = random.nextBool() ? "AM" : "PM";
    return "$hour:${minute.toString().padLeft(2, '0')} $period";
  }

  double generateRandomTotal() {
    return Random().nextDouble() * 900 + 100;
  }

  int? getRandomTableNumber() {
    return Random().nextBool() ? Random().nextInt(20) + 1 : null;
  }

  String getRandomOrderType() {
    List<String> orderTypes = ["Dine In", "Take Away", "Delivery"];
    return orderTypes[Random().nextInt(orderTypes.length)];
  }

  List<Item> generateRandomItems() {
    List<Item> menuItems = [
      Item(name: "Burger", price: 150.00, quantity: 1),
      Item(name: "French Fries", price: 100.00, quantity: 1),
      Item(name: "Coke", price: 50.00, quantity: 1),
      Item(name: "Pizza", price: 400.00, quantity: 1),
    ];

    return List.generate(Random().nextInt(4) + 1, (index) {
      var item = menuItems[Random().nextInt(menuItems.length)];
      return Item(
          name: item.name,
          quantity: Random().nextInt(3) + 1,
          price: item.price);
    });
  }
}
