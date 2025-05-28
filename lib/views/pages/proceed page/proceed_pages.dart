import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_system_legphel/bloc/proceed_order_bloc/bloc/proceed_order_bloc.dart';
import 'package:pos_system_legphel/models/Menu%20Model/proceed_order_model.dart';
import 'package:pos_system_legphel/models/Menu%20Model/receipt_model.dart';
import 'package:uuid/uuid.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_bill_model.dart';
import 'package:pos_system_legphel/views/pages/proceed%20page/proceed_payment_bill.dart';
import 'package:pos_system_legphel/views/pages/proceed%20page/qr_code_display_page.dart';
import 'package:pos_system_legphel/bloc/bill_bloc/bill_bloc.dart';
import 'package:pos_system_legphel/models/Bill/bill_summary_model.dart';
import 'package:pos_system_legphel/models/Bill/bill_details_model.dart';
import 'package:pos_system_legphel/bloc/menu_item_bloc/bloc/menu_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProceedPages extends StatefulWidget {
  final List<MenuBillModel> items;
  final String customername;
  final String phoneNumber;
  final String tableNumber;
  final String orderID;
  final String branchName;
  final double subTotal;
  final double totalCost;
  final String orderNumber;
  final double bst;
  final double serviceTax;

  const ProceedPages({
    super.key,
    required this.items,
    required this.bst,
    required this.subTotal,
    required this.serviceTax,
    required this.branchName,
    required this.orderNumber,
    required this.customername,
    required this.orderID,
    required this.phoneNumber,
    required this.tableNumber,
    required this.totalCost,
  });

  @override
  _ProceedOrderScreenState createState() => _ProceedOrderScreenState();
}

class _ProceedOrderScreenState extends State<ProceedPages> {
  String selectedServiceType = 'Dine In';
  int splitCount = 1;
  List<double> splitAmounts = [];
  bool isSplit = false;

  // Add new state variables for discounts
  double fixedDiscount = 0.0;
  double percentageDiscount = 0.0;
  double bstCalculated = 0.0;
  double serviceChargeCalculated = 0.0;
  double amountAfterDiscount = 0.0;

  List<double> suggestedAmounts = [];
  double finalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _updateFinalAmount();
    _calculateSuggestedAmounts();
  }

  void _calculateSuggestedAmounts() {
    final baseAmount = widget.totalCost;
    suggestedAmounts = [
      (baseAmount / 50).ceil() * 50, // Round to nearest 50
      (baseAmount / 100).ceil() * 100, // Round to nearest 100
      (baseAmount / 500).ceil() * 500, // Round to nearest 500
    ];
  }

  // calculation fo the Whatever logic for the Discount, BST, SST whatever......
  void _updateFinalAmount() {
    double amount = widget.subTotal; // Start with subtotal

    // Apply percentage discount first
    if (percentageDiscount > 0) {
      amount = amount * (1 - percentageDiscount / 100);
    }
    // Then apply fixed discount
    amount = amount - fixedDiscount;

    bstCalculated = amount * (widget.bst / 100);
    serviceChargeCalculated = amount * (widget.serviceTax / 100);

    // Calculate BST and service tax as percentages on the discounted amount
    // double bstAmount = amount * (widget.bst / widget.subTotal);
    // double serviceTaxAmount = amount * (widget.serviceTax / widget.subTotal);

    // Add BST and service tax to get final amount
    // amount = amount + bstAmount + serviceTaxAmount;

    setState(() {
      finalAmount = amount + bstCalculated + serviceChargeCalculated;
      amountAfterDiscount = amount;
    });
    _calculateSuggestedAmounts();
  }

  void _showDiscountDialog() {
    double tempFixedDiscount = fixedDiscount;
    double tempPercentageDiscount = percentageDiscount;
    double tempFinalAmount = finalAmount;
    double tempBstCalculated = bstCalculated;
    double tempServiceChargeCalculated = serviceChargeCalculated;
    double tempAmountAfterDiscount = amountAfterDiscount;

    final fixedDiscountController = TextEditingController(
      text: tempFixedDiscount > 0 ? tempFixedDiscount.toString() : '',
    );
    final percentageDiscountController = TextEditingController(
      text: tempPercentageDiscount > 0 ? tempPercentageDiscount.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void updateTempCalculations() {
              double amount = widget.subTotal;
              if (tempPercentageDiscount > 0) {
                amount = amount * (1 - tempPercentageDiscount / 100);
              }
              amount = amount - tempFixedDiscount;

              tempBstCalculated = amount * (widget.bst / 100);
              tempServiceChargeCalculated = amount * (widget.serviceTax / 100);
              tempAmountAfterDiscount = amount;
              tempFinalAmount =
                  amount + tempBstCalculated + tempServiceChargeCalculated;
            }

            return AlertDialog(
              title: const Text("Apply Discount"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Fixed Discount (Nu.)",
                        hintText: "Enter amount",
                        border: OutlineInputBorder(),
                      ),
                      controller: fixedDiscountController,
                      onChanged: (value) {
                        setState(() {
                          tempFixedDiscount = double.tryParse(value) ?? 0.0;
                          updateTempCalculations();
                        });
                        // Update parent widget state
                        this.setState(() {
                          fixedDiscount = tempFixedDiscount;
                          percentageDiscount = tempPercentageDiscount;
                          bstCalculated = tempBstCalculated;
                          serviceChargeCalculated = tempServiceChargeCalculated;
                          amountAfterDiscount = tempAmountAfterDiscount;
                          finalAmount = tempFinalAmount;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Percentage Discount (%)",
                        hintText: "Enter percentage",
                        border: OutlineInputBorder(),
                      ),
                      controller: percentageDiscountController,
                      onChanged: (value) {
                        setState(() {
                          tempPercentageDiscount =
                              double.tryParse(value) ?? 0.0;
                          updateTempCalculations();
                        });
                        // Update parent widget state
                        this.setState(() {
                          fixedDiscount = tempFixedDiscount;
                          percentageDiscount = tempPercentageDiscount;
                          bstCalculated = tempBstCalculated;
                          serviceChargeCalculated = tempServiceChargeCalculated;
                          amountAfterDiscount = tempAmountAfterDiscount;
                          finalAmount = tempFinalAmount;
                        });
                      },
                    ),
                    if (tempFixedDiscount > 0 || tempPercentageDiscount > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (tempPercentageDiscount > 0)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text(
                                  "New Amount after ${tempPercentageDiscount.toStringAsFixed(1)}% discount: Nu. ${tempAmountAfterDiscount.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (tempFixedDiscount > 0)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text(
                                  "New Amount after Nu. ${tempFixedDiscount.toStringAsFixed(2)} discount: Nu. ${tempAmountAfterDiscount.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const Divider(height: 10),
                            Text(
                              "Final Amount: Nu. ${tempFinalAmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Reset values when canceling
                    this.setState(() {
                      fixedDiscount = 0.0;
                      percentageDiscount = 0.0;
                      _updateFinalAmount();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    this.setState(() {
                      fixedDiscount = tempFixedDiscount;
                      percentageDiscount = tempPercentageDiscount;
                      bstCalculated = tempBstCalculated;
                      serviceChargeCalculated = tempServiceChargeCalculated;
                      amountAfterDiscount = tempAmountAfterDiscount;
                      finalAmount = tempFinalAmount;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
                      splitAmounts = List.generate(
                          splitCount, (index) => finalAmount / splitCount);
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
    return BlocListener<BillBloc, BillState>(
      listener: (context, state) {
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
                content: const Text('Bill has been successfully submitted!'),
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
      },
      child: Scaffold(
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
          iconTheme: const IconThemeData(
            color: Colors.white, // 👈 this makes the back button white
          ),
          centerTitle: false,
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 3, 27, 48),
        ),
        body: Row(
          children: [
            // Left Side: Order Details
            Expanded(
              flex: 5,
              child: Container(
                color: Colors.grey[200],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Type Card
                    Card(
                      margin: const EdgeInsets.all(16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Service Type',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 3, 27, 48),
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                filled: true,
                                fillColor: Colors.white,
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
                          ],
                        ),
                      ),
                    ),
                    // Order Items Card
                    Expanded(
                      child: Card(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Order Items',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 3, 27, 48),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color:
                                          const Color.fromARGB(255, 3, 27, 48)
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${widget.items.length} Items',
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 3, 27, 48),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child: ListView.builder(
                                itemCount: widget.items.length,
                                itemBuilder: (context, index) {
                                  final item = widget.items[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                      title: Text(
                                        item.product.menuName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Nu. ${item.product.price} × ${item.quantity}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      trailing: Text(
                                        'Nu. ${item.totalPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color.fromARGB(255, 3, 27, 48),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right Side: Payment and Total
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Column(
                  children: [
                    // Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order Summary Card
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Order Summary',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 3, 27, 48),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Subtotal',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          'Nu. ${amountAfterDiscount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (percentageDiscount > 0 ||
                                        fixedDiscount > 0) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Discount',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            'Nu. ${(percentageDiscount > 0 ? (widget.subTotal * percentageDiscount / 100) : 0) + fixedDiscount}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'BST',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          'Nu. ${bstCalculated.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Service Charge',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          'Nu. ${serviceChargeCalculated.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Total Amount',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromARGB(255, 3, 27, 48),
                                          ),
                                        ),
                                        Text(
                                          'Nu. ${finalAmount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromARGB(255, 3, 27, 48),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Discount Section
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Discount',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromARGB(255, 3, 27, 48),
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: _showDiscountDialog,
                                          icon: const Icon(Icons.discount,
                                              size: 18),
                                          label: const Text('Apply Discount'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 3, 27, 48),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (fixedDiscount > 0 ||
                                        percentageDiscount > 0) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color:
                                                Colors.green.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (percentageDiscount > 0)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.percent,
                                                        color: Colors.green,
                                                        size: 16),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      "Percentage Discount: ${percentageDiscount.toStringAsFixed(1)}%",
                                                      style: const TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (fixedDiscount > 0)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.attach_money,
                                                        color: Colors.green,
                                                        size: 16),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      "Fixed Discount: Nu. ${fixedDiscount.toStringAsFixed(2)}",
                                                      style: const TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            const Divider(height: 16),
                                            Row(
                                              children: [
                                                const Icon(Icons.receipt_long,
                                                    color: Colors.grey,
                                                    size: 16),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Original Amount: Nu. ${widget.totalCost.toStringAsFixed(2)}",
                                                  style: const TextStyle(
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Fixed Payment Method Card at Bottom
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Method',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 3, 27, 48),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPaymentButtons(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            Expanded(child: _paymentButton('COMPLIMENTARY')),
            const SizedBox(width: 5),
            Expanded(child: _paymentButton('CREDIT')),
          ],
        ),
      ],
    );
  }

  Widget _paymentButton(String method) {
    // Define colors based on payment method
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (method) {
      case 'SCAN':
        backgroundColor =
            const Color.fromARGB(255, 3, 27, 48); // Dark blue for SCAN
        break;
      case 'CASH':
        backgroundColor = const Color.fromARGB(255, 3, 27, 48)
            .withOpacity(0.9); // Slightly transparent dark blue
        break;
      case 'CARD':
        backgroundColor = const Color.fromARGB(255, 3, 27, 48)
            .withOpacity(0.8); // More transparent dark blue
        break;
      case 'CREDIT':
        backgroundColor = const Color.fromARGB(255, 3, 27, 48)
            .withOpacity(0.7); // Most transparent dark blue
        break;
      default:
        backgroundColor = const Color.fromARGB(255, 3, 27, 48).withOpacity(0.6);
    }

    return SizedBox(
      width: 80,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          // If payment method is CARD, show QR code page first
          if (method == 'SCAN') {
            final bool? proceed = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => const QrCodeDisplayPage(),
              ),
            );

            // If user didn't proceed (pressed back), return
            if (proceed != true) {
              return;
            }
          }

          // clears the history form the front page you know
          context.read<MenuBloc>().add(RemoveAllFromCart());
          // Create bill summary
          final billSummary = BillSummaryModel(
            fnbBillNo: widget.orderNumber,
            primaryCustomerName: widget.customername,
            phoneNo: widget.phoneNumber,
            tableNo: widget.tableNumber,
            pax: 1,
            outlet: widget.branchName,
            orderType: selectedServiceType,
            subTotal: amountAfterDiscount,
            bst: bstCalculated,
            serviceCharge: serviceChargeCalculated,
            discount: (percentageDiscount > 0
                    ? (widget.subTotal * percentageDiscount / 100)
                    : 0) +
                fixedDiscount,
            totalAmount: finalAmount,
            paymentStatus: "PAID",
            amountSettled: finalAmount,
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

          // adding to the proceed model
          final proceedOrderItems = ProceedOrderModel(
            orderNumber: widget.orderNumber,
            holdOrderId: widget.orderID,
            tableNumber: widget.tableNumber,
            customerName: widget.customername,
            phoneNumber: widget.phoneNumber,
            restaurantBranchName: widget.branchName,
            orderDateTime: DateTime.now(),
            menuItems: widget.items,
            totalAmount: finalAmount,
          );

          // Submit bill using bloc
          context.read<BillBloc>().add(SubmitBill(
                billSummary: billSummary,
                billDetails: billDetails,
              ));
          context
              .read<ProceedOrderBloc>()
              .add(AddProceedOrder(proceedOrderItems));

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
                subTotal: amountAfterDiscount,
                bst: bstCalculated,
                serviceTax: serviceChargeCalculated,
                totalQuantity:
                    widget.items.fold(0, (sum, item) => sum + item.quantity),
                date: DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                time: DateFormat('hh:mm a').format(DateTime.now()),
                totalAmount: finalAmount,
                payMode: method,
                discount: (percentageDiscount > 0
                        ? (widget.subTotal * percentageDiscount / 100)
                        : 0) +
                    fixedDiscount,
                branchName: widget.branchName,
              ),
            ),
          );

          // Handle the result if needed
          if (result != null) {
            // Do something with the result returned from ProceedPaymentBill
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
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

  // calculating the suggested amount in the bill section you know what and you know who
  List<double> _getSuggestedAmounts() {
    final baseAmount = finalAmount;
    final List<double> amounts = [];

    // Round down to nearest 50
    final lower50 = (baseAmount / 50.0).floor() * 50.0;
    if (lower50 > 0) amounts.add(lower50);

    // Round up to nearest 50
    final upper50 = (baseAmount / 50.0).ceil() * 50.0;
    if (upper50 != lower50) amounts.add(upper50);

    // Round down to nearest 100
    final lower100 = (baseAmount / 100.0).floor() * 100.0;
    if (lower100 > 0 && !amounts.contains(lower100)) amounts.add(lower100);

    // Round up to nearest 100
    final upper100 = (baseAmount / 100.0).ceil() * 100.0;
    if (upper100 != lower100 && !amounts.contains(upper100))
      amounts.add(upper100);

    // Round down to nearest 500
    final lower500 = (baseAmount / 500.0).floor() * 500.0;
    if (lower500 > 0 && !amounts.contains(lower500)) amounts.add(lower500);

    // Round up to nearest 500
    final upper500 = (baseAmount / 500.0).ceil() * 500.0;
    if (upper500 != lower500 && !amounts.contains(upper500))
      amounts.add(upper500);

    // Sort amounts
    amounts.sort();

    return amounts;
  }
}
