import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_bill_model.dart';
import 'package:pos_system_legphel/views/pages/proceed%20page/proceed_payment_bill.dart';

class ProceedPages extends StatefulWidget {
  final List<MenuBillModel> items;
  final String customername;
  final String phoneNumber;
  final String tableNumber;
  final String orderID;
  final String branchName;

  const ProceedPages({
    super.key,
    required this.items,
    required this.branchName,
    required this.customername,
    required this.orderID,
    required this.phoneNumber,
    required this.tableNumber,
  });

  @override
  _ProceedOrderScreenState createState() => _ProceedOrderScreenState();
}

class _ProceedOrderScreenState extends State<ProceedPages> {
  String selectedServiceType = 'Dine In';
  int splitCount = 1;
  List<double> splitAmounts = [];
  bool isSplit = false;

  double calculateTotal() {
    return widget.items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  void _showSplitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Text("Split Bill"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: "Number of People"),
                  onChanged: (value) {
                    setState(() {
                      splitCount = int.tryParse(value) ?? 1;
                    });
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isSplit = true;
                      double total = calculateTotal();
                      splitAmounts = List.generate(
                          splitCount, (index) => total / splitCount);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Split Equally"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proceed Order'), centerTitle: true),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      value: selectedServiceType,
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
                              Text('${item.totalPrice.toStringAsFixed(2)} Nu'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: TextEditingController(
                                text: calculateTotal().toStringAsFixed(2),
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none, // Remove the border
                              ),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Nu',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      ElevatedButton(
                        onPressed: _showSplitDialog,
                        child: const Text("Split Bill"),
                      ),
                    ],
                  ),
                  if (isSplit)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              "Split Among $splitCount People:",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...splitAmounts.map(
                              (amount) =>
                                  Text('${amount.toStringAsFixed(2)} Nu'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
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
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return ProceedPaymentBill(
              id: widget.orderID,
              user: widget.customername,
              phoneNo: widget.phoneNumber,
              tableNo: widget.tableNumber,
              items: widget.items
                  .map((item) => {
                        "name": item.product.name,
                        "quantity": item.quantity,
                        "price": item.product.price
                      })
                  .toList(),
              subTotal: calculateTotal(),
              gst: calculateTotal() * 0.05,
              totalQuantity:
                  widget.items.fold(0, (sum, item) => sum + item.quantity),
              date: DateFormat('dd-MM-yyyy').format(DateTime.now()),
              time: DateFormat('hh:mm a').format(DateTime.now()),
              totalAmount: calculateTotal() * 1.05,
              payMode: method,
            );
          },
        ));
      },
      child: Text(method),
    );
  }
}
