import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_bill_model.dart';
import 'package:pos_system_legphel/views/pages/proceed%20page/proceed_payment_bill.dart';
import 'package:pos_system_legphel/bloc/bill_bloc/bill_bloc.dart';
import 'package:pos_system_legphel/models/Bill/bill_summary_model.dart';
import 'package:pos_system_legphel/models/Bill/bill_details_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProceedPages extends StatefulWidget {
  final List<MenuBillModel> items;
  final String customername;
  final String phoneNumber;
  final String tableNumber;
  final String orderID;
  final String branchName;
  final double totalCostWithTax;
  final String orderNumber;

  const ProceedPages({
    super.key,
    required this.items,
    required this.branchName,
    required this.orderNumber,
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
        title: Text(
          'Proceed Order (#${widget.orderNumber})',
          style: const TextStyle(
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
          // Right Side: Payment and Total --------------------------------------------------------------
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
                                  const Row(
                                    children: [
                                      Text(
                                        'Total',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Text(
                                      //   '   (Including 20% charge)',
                                      //   style: TextStyle(
                                      //     fontSize: 14,
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                      // ),
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
        onPressed: () async {
          // Create bill summary
          final billSummary = BillSummaryModel(
            fnbBillNo: widget.orderNumber,
            primaryCustomerName: widget.customername,
            phoneNo: widget.phoneNumber,
            tableNo: "No Table",
            pax: 1, // You might want to add this as a parameter
            outlet: widget.branchName,
            orderType: selectedServiceType,
            subTotal: calculateTotal(),
            bst: calculateTotal() * 0.2, // 20% BST
            serviceCharge: 0, // Add if needed
            discount: 0, // Add if needed
            totalAmount: widget.totalCostWithTax,
            paymentStatus: 'PAID',
            amountSettled: widget.totalCostWithTax,
            amountRemaining: 0,
            paymentMode: method,
            date: DateTime.now(),
            time: DateTime.now(),
          );

          // Create bill details
          const uuid = Uuid();

          final billDetails = widget.items
              .map((item) => BillDetailsModel(
                    id: uuid.v4(),
                    menuName: item.product.menuName,
                    rate: double.parse(item.product.price),
                    quantity: item.quantity,
                    amount: item.totalPrice,
                    fnbBillNo: widget.orderNumber,
                    date: DateTime.now(),
                    time: DateTime.now(),
                  ))
              .toList();

          // Submit bill using bloc
          context.read<BillBloc>().add(SubmitBill(
                billSummary: billSummary,
                billDetails: billDetails,
              ));

          // Listen to bloc state changes
          context.read<BillBloc>().stream.listen((state) {
            if (state is BillSubmitted) {
              // Show success dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 30),
                        SizedBox(width: 10),
                        Text('Success'),
                      ],
                    ),
                    content:
                        const Text('Bill has been successfully submitted!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            } else if (state is BillError) {
              // Show error dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Row(
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 30),
                        SizedBox(width: 10),
                        Text('Error'),
                      ],
                    ),
                    content: Text('Failed to submit bill: ${state.message}'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          });

          // Navigate to payment bill page
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProceedPaymentBill(
                orderNumber: widget.orderNumber,
                id: widget.orderID,
                user: widget.customername,
                phoneNo: widget.phoneNumber,
                tableNo: widget.tableNumber,
                items: widget.items
                    .map((item) => {
                          "menuName": item.product.menuName,
                          "quantity": item.quantity,
                          "price":
                              (double.parse(item.product.price) * item.quantity)
                                  .toStringAsFixed(2),
                        })
                    .toList(),
                subTotal: calculateTotal(),
                gst: calculateTotal() * 0.2,
                totalQuantity:
                    widget.items.fold(0, (sum, item) => sum + item.quantity),
                date: DateFormat('dd-MM-yyyy').format(DateTime.now()),
                time: DateFormat('hh:mm a').format(DateTime.now()),
                totalAmount: calculateTotal(),
                payMode: method,
                branchName: widget.branchName,
              ),
            ),
          );

          // You can now handle the result if needed
          if (result != null) {
            // Do something with the result returned from ProceedPaymentBill
          }
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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
