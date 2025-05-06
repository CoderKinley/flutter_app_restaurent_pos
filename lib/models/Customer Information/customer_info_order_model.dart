class CustomerInfoOrderModel {
  final String name;
  final String contact;
  final String orderId;
  final String tableNo;
  final String orderNumber;

  CustomerInfoOrderModel({
    required this.name,
    required this.contact,
    required this.orderId,
    required this.tableNo,
    required this.orderNumber,
  });

  // Convert a CustomerInfoOrderModel instance to a map (for database or API purposes)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contact': contact,
      'orderId': orderId,
      'tableNo': tableNo,
      'orderNumber': orderNumber,
    };
  }

  // Create a CustomerInfoOrderModel instance from a map (e.g., when retrieving data from database or API)
  factory CustomerInfoOrderModel.fromMap(Map<String, dynamic> map) {
    return CustomerInfoOrderModel(
      name: map['name'],
      contact: map['contact'],
      orderId: map['orderId'],
      tableNo: map['tableNo'],
      orderNumber: map['orderNumber'],
    );
  }
}
