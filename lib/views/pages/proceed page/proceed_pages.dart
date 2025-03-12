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
  final double totalCostWithTax;

  const ProceedPages({
    super.key,
    required this.items,
    required this.branchName,
    required this.customername,
    required this.orderID,
    required this.phoneNumber,
    required this.tableNumber,
    required this.totalCostWithTax,
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Proceed Order',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 3, 27, 48),
      ),
      body: Row(
        children: [
          // Left Side: Order Details
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Type Dropdown
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      value: selectedServiceType,
                      items: ['Dine In', 'Takeaway', 'Delivery']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedServiceType = value!;
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1, thickness: 1),
                  // Order Items List
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        return ListTile(
                          title: Text(
                            '${item.product.menuName} x ${item.quantity}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          trailing: Text(
                            '${item.totalPrice.toStringAsFixed(2)} Nu',
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right Side: Payment and Total
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: LayoutBuilder(
                // Use LayoutBuilder for better constraints
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Scrollable Top Section
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Total Amount Section
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        '   (Including 20% charge)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  FocusScope(
                                    child: Focus(
                                      onFocusChange: (hasFocus) {
                                        if (hasFocus) {
                                          // Auto-scroll to input when focused
                                          Scrollable.ensureVisible(
                                            context,
                                            duration: const Duration(
                                                milliseconds: 300),
                                          );
                                        }
                                      },
                                      child: TextFormField(
                                        controller: TextEditingController(
                                          text: widget.totalCostWithTax
                                              .toString(),
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "0.00",
                                        ),
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 20, thickness: 1),
                                  // Split Bill Button
                                  ElevatedButton(
                                    onPressed: _showSplitDialog,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 24),
                                      backgroundColor: const Color.fromARGB(
                                          255, 0, 150, 136),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      "Split Bill",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              // Split Amounts (if enabled)
                              if (isSplit)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    Text(
                                      "Split Among $splitCount People:",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...splitAmounts.map(
                                      (amount) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Text(
                                          '${amount.toStringAsFixed(2)} Nu',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      _buildPaymentButtons(),

                      // Fixed Bottom Buttons
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 16),
                      //   child: Column(
                      //     children: [
                      //       // First Row for CASH and SCAN
                      //       Row(
                      //         children: [
                      //           Expanded(child: _paymentButton('CASH')),
                      //           const SizedBox(width: 10),
                      //           Expanded(child: _paymentButton('SCAN')),
                      //         ],
                      //       ),
                      //       const SizedBox(height: 10),
                      //       Row(
                      //         children: [
                      //           Expanded(child: _paymentButton('CARD')),
                      //           const SizedBox(width: 10),
                      //           Expanded(child: _paymentButton('CREDIT')),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButtons() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _paymentButton('CASH')),
            const SizedBox(width: 5),
            Expanded(child: _paymentButton('SCAN')),
            const SizedBox(width: 5),
            Expanded(child: _paymentButton('CARD')),
            const SizedBox(width: 5),
            Expanded(child: _paymentButton('CREDIT')),
          ],
        ),
      ],
    );
  }

  Widget _paymentButton(String method) {
    return SizedBox(
      width: 80, // Fixed width for square
      height: 50, // Fixed height for square
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProceedPaymentBill(
                  id: widget.orderID,
                  user: widget.customername,
                  phoneNo: widget.phoneNumber,
                  tableNo: widget.tableNumber,
                  items: widget.items
                      .map((item) => {
                            "menuName": item.product.menuName,
                            "quantity": item.quantity,
                            "price": item.product.price
                          })
                      .toList(),
                  subTotal: calculateTotal(),
                  gst: calculateTotal() * 0.2,
                  totalQuantity:
                      widget.items.fold(0, (sum, item) => sum + item.quantity),
                  date: DateFormat('dd-MM-yyyy').format(DateTime.now()),
                  time: DateFormat('hh:mm a').format(DateTime.now()),
                  totalAmount: calculateTotal() * 1.2,
                  payMode: method,
                ),
              ));
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Slightly rounded corners
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              method,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
