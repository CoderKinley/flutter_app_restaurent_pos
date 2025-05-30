import 'package:flutter/material.dart';
import 'bill_service.dart';
import 'dart:typed_data';
import 'qr_code_display_page.dart';

class ProceedPaymentBill extends StatelessWidget {
  final String id;
  final String user;
  final String phoneNo;
  final String tableNo;
  final List<Map<String, dynamic>> items;
  final double subTotal;
  final double bst;
  final double serviceTax;
  final int totalQuantity;
  final String date;
  final String time;
  final double totalAmount;
  final String payMode;
  final String orderNumber;
  final String branchName;
  final double discount;

  const ProceedPaymentBill({
    super.key,
    required this.orderNumber,
    required this.branchName,
    required this.id,
    required this.user,
    required this.phoneNo,
    required this.tableNo,
    required this.items,
    required this.subTotal,
    required this.bst,
    required this.serviceTax,
    required this.totalQuantity,
    required this.date,
    required this.time,
    required this.totalAmount,
    required this.payMode,
    required this.discount,
  });

  // Generate PDF data by calling service
  Future<Uint8List> _generatePdf() {
    return BillService.generatePdf(
      id: id,
      user: user,
      phoneNo: phoneNo,
      tableNo: tableNo,
      items: items,
      subTotal: subTotal,
      bst: bst,
      serviceTax: serviceTax,
      totalQuantity: totalQuantity,
      date: date,
      time: time,
      totalAmount: totalAmount,
      payMode: payMode,
      orderNumber: orderNumber,
      branchName: branchName,
    );
  }

  Future<void> _showQrCodePage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QrCodeDisplayPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 27, 48),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Bill Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.check,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: colorScheme.background.withOpacity(0.05),
        child: Row(
          children: [
            // Left Section - Order Details Only
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section
                          Container(
                            padding: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    payMode,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Invoice #$orderNumber",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                    Icons.store, "Branch: $branchName"),
                                _buildInfoRow(
                                  Icons.table_bar,
                                  "Table No: $tableNo",
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "$date at $time",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      _getPaymentIcon(payMode),
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Paid via $payMode",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Items Section
                          const SizedBox(height: 24),
                          Text(
                            "ORDER DETAILS",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Item headers
                          Container(
                            padding: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Item",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "Qty",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "Price",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Item list
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        item['menuName'],
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "× ${item['quantity']}",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: colorScheme.onSurface,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Nu.${item['price']}",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: colorScheme.onSurface,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const Divider(
                            thickness: 0.5,
                          ),
                          _buildSummaryRow(
                              "Total Quantity", totalQuantity.toString()),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Right Section - Financial Info and Actions
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Summary Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              _buildSummaryRow(
                                  "Sub Total", subTotal.toString()),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(thickness: 1.5),
                              ),
                              _buildSummaryRow("BST", bst.toStringAsFixed(2)),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                              ),
                              _buildSummaryRow("Service Charge",
                                  serviceTax.toStringAsFixed(2)),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(thickness: 1.5),
                              ),
                              _buildSummaryRow(
                                "Total Amount",
                                "Nu.${totalAmount.toStringAsFixed(2)}",
                                isTotal: true,
                                colorScheme: colorScheme,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Action Buttons Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.share),
                                label: const Text("Share PDF"),
                                onPressed: () async {
                                  await BillService.sharePdf(
                                    id: id,
                                    pdfGenerator: _generatePdf,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.receipt_long),
                                label: const Text("Thermal Print"),
                                onPressed: () => BillService.printWithEscPos(
                                  context: context,
                                  id: id,
                                  discount: discount,
                                  user: user,
                                  phoneNo: phoneNo,
                                  tableNo: tableNo,
                                  items: items,
                                  subTotal: subTotal,
                                  bst: subTotal / bst,
                                  bstAmt: bst,
                                  serviceAmt: serviceTax,
                                  serviceTax: subTotal / serviceTax,
                                  totalQuantity: totalQuantity,
                                  date: date,
                                  time: time,
                                  totalAmount: totalAmount,
                                  payMode: payMode,
                                  orderNumber: orderNumber,
                                  branchName: branchName,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.save_alt),
                                label: const Text("Save PDF"),
                                onPressed: () => BillService.savePdfLocally(
                                  context: context,
                                  id: id,
                                  pdfGenerator: _generatePdf,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      colorScheme.secondaryContainer,
                                  foregroundColor:
                                      colorScheme.onSecondaryContainer,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false, ColorScheme? colorScheme}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? colorScheme?.primary : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? colorScheme?.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String payMode) {
    switch (payMode.toLowerCase()) {
      case 'cash':
        return Icons.payments;
      case 'card':
        return Icons.credit_card;
      case 'qr':
        return Icons.qr_code;
      case 'online':
        return Icons.language;
      default:
        return Icons.payment;
    }
  }
}
