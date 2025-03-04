import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_bill_model.dart';
import 'package:pos_system_legphel/views/pages/proceed_payment_bill.dart';
import 'package:uuid/uuid.dart';

class ProceedPages extends StatefulWidget {
  final List<MenuBillModel> items;

  const ProceedPages({super.key, required this.items});

  @override
  _ProceedOrderScreenState createState() => _ProceedOrderScreenState();
}

class _ProceedOrderScreenState extends State<ProceedPages> {
  String selectedServiceType = 'Dine In';

  double calculateTotal() {
    return widget.items.fold(0, (sum, item) => sum + item.totalPrice);
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
                      onChanged: (value) {
                        setState(() {
                          selectedServiceType = value!;
                        });
                      },
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        return ListTile(
                          title:
                              Text('${item.product.name} x ${item.quantity}'),
                          trailing:
                              Text('${item.totalPrice.toStringAsFixed(2)}Nu'),
                        );
                      },
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
                  Text('${calculateTotal().toStringAsFixed(2)}Nu',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  const Divider(),
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

  Widget _paymentButton(String method) {
    String getCurrentDate() {
      return DateFormat('dd-MM-yyyy')
          .format(DateTime.now()); // Get the current date
    }

    String getCurrentTime() {
      return DateFormat('hh:mm a')
          .format(DateTime.now()); // Get the current time
    }

    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            final uuid = Uuid();
            return ProceedPaymentBill(
              id: uuid.v4(),
              user: "Kinley Penjor",
              phoneNo: "+975-17807306",
              tableNo: "10",
              items: widget.items
                  .map((item) => {
                        "name": item.product.name,
                        "quantity": item.quantity,
                        "price": item.product.price,
                      })
                  .toList(),
              subTotal: calculateTotal(),
              gst: calculateTotal() * 0.05,
              totalQuantity:
                  widget.items.fold(0, (sum, item) => sum + item.quantity),
              date: getCurrentDate(), // Current date
              time: getCurrentTime(), // Current time
              totalAmount: calculateTotal() * 1.05,
              payMode: method,
            );
          },
        ));
      },
      style: ElevatedButton.styleFrom(),
      child: Text(method),
    );
  }
}
