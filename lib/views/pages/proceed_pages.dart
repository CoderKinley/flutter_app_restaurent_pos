import 'package:flutter/material.dart';
import 'package:pos_system_legphel/views/pages/proceed_payment_bill.dart';

class ProceedPages extends StatefulWidget {
  final List<Map<String, dynamic>> items; // Items to proceed with

  const ProceedPages({super.key, required this.items});

  @override
  _ProceedOrderScreenState createState() => _ProceedOrderScreenState();
}

class _ProceedOrderScreenState extends State<ProceedPages> {
  String selectedServiceType = 'Dine In'; // Default service type
  String selectedPaymentMode = 'Cash'; // Default payment mode
  final TextEditingController _noteController =
      TextEditingController(); // For any additional notes

  // Method to calculate total price
  double calculateTotal() {
    return widget.items
        .fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proceed Order'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          // Left side: Menu and Order options
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Order Type',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      value: 'Dine In',
                      items: ['Dine In', 'Takeaway', 'Delivery']
                          .map((type) =>
                              DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) {},
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      children: [
                        _menuItem('Chicken roll x 1', '150.00Nu'),
                        _menuItem('Black label x 2', '900.00Nu'),
                        _menuItem('Chicken 65 x 1', '200.00Nu'),
                        _menuItem('Black tea x 1', '30.00Nu'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right side: Price summary and payment options
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('1,280.00Nu',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  const Divider(),
                  const Text('Cash received',
                      style: TextStyle(fontSize: 16, color: Colors.green)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      _cashButton('1,290.00NU'),
                      _cashButton('1,300.00NU'),
                      _cashButton('1,500.00NU'),
                      _cashButton('2,000.00NU'),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(child: _paymentButton('CARD')),
                      const SizedBox(width: 10),
                      Expanded(child: _paymentButton('CASH')),
                      const SizedBox(width: 10),
                      Expanded(child: _paymentButton('SCAN')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(String title, String price) {
    return ListTile(
      title: Text(title),
      trailing: Text(price),
    );
  }

  Widget _orderTypeButton(String type) {
    return ElevatedButton(
      onPressed: () {},
      child: Text(type),
    );
  }

  Widget _cashButton(String amount) {
    return ElevatedButton(
      onPressed: () {},
      child: Text(amount),
    );
  }

  Widget _paymentButton(String method) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return const ProceedPaymentBill(
              id: "12345",
              user: "John Doe",
              tableNo: "10",
              items: [
                {"name": "Burger", "quantity": 2, "price": 5.99},
                {"name": "Pasta", "quantity": 1, "price": 7.49},
              ],
              subTotal: 19.47,
              gst: 1.95,
              totalQuantity: 3,
              date: "24-02-2025",
              time: "8:30 PM",
              totalAmount: 21.42,
              payMode: "Cash",
            );
          },
        ));
      },
      style: ElevatedButton.styleFrom(),
      child: Text(method),
    );
  }
}
