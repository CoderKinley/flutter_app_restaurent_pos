import 'package:flutter/material.dart';

class HoldOrderPage extends StatelessWidget {
  // Example list of tables, each with a list of on-hold items
  final List<Map<String, dynamic>> tables = [
    {
      'tableNumber': 1,
      'items': [
        {'name': 'Burger', 'quantity': 2, 'price': 5.00},
        {'name': 'Fries', 'quantity': 1, 'price': 2.50},
      ],
    },
    {
      'tableNumber': 2,
      'items': [
        {'name': 'Pizza', 'quantity': 1, 'price': 8.00},
        {'name': 'Soda', 'quantity': 3, 'price': 1.20},
      ],
    },
    {
      'tableNumber': 3,
      'items': [
        {'name': 'Pasta', 'quantity': 2, 'price': 6.50},
        {'name': 'Water', 'quantity': 4, 'price': 0.80},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hold Order Items'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: tables.length,
          itemBuilder: (context, tableIndex) {
            final table = tables[tableIndex];
            final tableNumber = table['tableNumber'];
            final items = table['items'];

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Table Number
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Table $tableNumber',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Order ID $tableNumber',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // List of items on hold for this table
                    for (var item in items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['name'],
                                style: TextStyle(
                                  fontSize: 12,
                                )),
                            Text('× ${item['quantity']}',
                                style: TextStyle(fontSize: 12)),
                            Text('\$${item['price']}',
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    SizedBox(height: 10),
                    // Total for this table
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Total: \$${items.fold(0, (sum, item) => sum + item['price'] * item['quantity'])}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Buttons for processing the order
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Handle process payment for this table
                            // Implement payment logic here
                          },
                          child: Text('Process Payment'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Handle cancel hold for this table
                            // Implement cancellation logic here
                          },
                          child: Text('Cancel Hold'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
