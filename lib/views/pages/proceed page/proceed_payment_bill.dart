import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class ProceedPaymentBill extends StatelessWidget {
  final String id;
  final String user;
  final String phoneNo;
  final String tableNo;
  final List<Map<String, dynamic>> items;
  final double subTotal;
  final double gst;
  final int totalQuantity;
  final String date;
  final String time;
  final double totalAmount;
  final String payMode;

  const ProceedPaymentBill({
    super.key,
    required this.id,
    required this.user,
    required this.phoneNo,
    required this.tableNo,
    required this.items,
    required this.subTotal,
    required this.gst,
    required this.totalQuantity,
    required this.date,
    required this.time,
    required this.totalAmount,
    required this.payMode,
  });

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();

    final ByteData logoData =
        await rootBundle.load('assets/icons/logo.png'); // Load logo
    final Uint8List logoBytes = logoData.buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Header Section with Logo & Business Info
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Left: Logo
                pw.Container(
                  width: 100,
                  height: 100,
                  child: pw.Image(pw.MemoryImage(logoBytes)),
                ),
                // Right: Business Details
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Legphel",
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 2),
                    pw.Text("Mobile 1: +975-17772393",
                        style: const pw.TextStyle(fontSize: 7)),
                    pw.Text("Mobile 2: +975-77772393",
                        style: const pw.TextStyle(fontSize: 7)),
                    pw.Text("TPN: LAC00091",
                        style: const pw.TextStyle(fontSize: 7)),
                    pw.Text("Acc No: 200108440",
                        style: const pw.TextStyle(fontSize: 7)),
                    pw.Text("Post Box: 239",
                        style: const pw.TextStyle(fontSize: 7)),
                    pw.Text(
                      "legphel.hotel@gmail.com",
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                    pw.Text("Rinchending, Phuentsholing",
                        style: const pw.TextStyle(fontSize: 7)),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1),

            // Bill Details
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Text("Bill ID: $id", style: const pw.TextStyle(fontSize: 7)),
                pw.Text("Date: $date", style: const pw.TextStyle(fontSize: 7)),
                pw.Text("Time: $time", style: const pw.TextStyle(fontSize: 7)),
              ],
            ),
            pw.Text("User: $user", style: const pw.TextStyle(fontSize: 7)),
            pw.Text("Table No: $tableNo",
                style: const pw.TextStyle(fontSize: 7)),
            pw.SizedBox(height: 5),

            // Items Header
            pw.Text("Items Purchased",
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
            pw.Divider(thickness: 0.5),

            // Items List
            ...items.map((item) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                        child: pw.Text(
                            "${item['menuName']} x${item['quantity']}",
                            style: const pw.TextStyle(fontSize: 7))),
                    pw.Text("Nu.${item['price']}",
                        style: const pw.TextStyle(fontSize: 7)),
                  ],
                )),
            pw.Divider(thickness: 1),

            // Bill Summary
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Subtotal:", style: const pw.TextStyle(fontSize: 8)),
                pw.Text("Nu.${subTotal.toStringAsFixed(2)}",
                    style: const pw.TextStyle(fontSize: 8)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Service 10%:", style: const pw.TextStyle(fontSize: 8)),
                pw.Text("Nu.${(gst / 2).toStringAsFixed(2)}",
                    style: const pw.TextStyle(fontSize: 8)),
              ],
            ),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("B.S.T 10%:", style: const pw.TextStyle(fontSize: 8)),
                pw.Text("Nu.${(gst / 2).toStringAsFixed(2)}",
                    style: const pw.TextStyle(fontSize: 8)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Discount: ", style: const pw.TextStyle(fontSize: 8)),
                pw.Text("Nu. 0.00", style: const pw.TextStyle(fontSize: 8)),
              ],
            ),

            pw.Divider(),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Total Quantity:",
                    style: const pw.TextStyle(fontSize: 8)),
                pw.Text("$totalQuantity",
                    style: const pw.TextStyle(fontSize: 8)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Total Amount:",
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.Text("Nu.${totalAmount.toStringAsFixed(2)}",
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Payment Mode:",
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.Text(payMode,
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 10),

            // Thank You Note
            pw.Text("Thank You! Visit Again!",
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.Text("Have a great day!",
                style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  /// Saves PDF to local storage
  Future<void> _savePdfLocally(BuildContext context) async {
    try {
      // Request storage permissions first
      if (await Permission.manageExternalStorage.request().isGranted) {
        final pdfData = await _generatePdf();

        // Create directory in root storage
        final billDirectory = Directory('/storage/emulated/0/Bill Folder PDF');

        // Create the directory if it doesn't exist
        if (!await billDirectory.exists()) {
          await billDirectory.create(recursive: true);
        }

        // Create and save the file
        final file = File('${billDirectory.path}/bill_$id.pdf');
        await file.writeAsBytes(pdfData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved to ${file.path}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PDF: $e')),
      );
    }
  }

  /// Print directly to thermal printer using ESC/POS commands
  Future<void> printWithEscPos(BuildContext context) async {
    try {
      // Connect to the thermal printer
      final socket = await Socket.connect('192.168.1.251', 9100);

      // Initialize printer
      List<int> bytes = [];

      // ESC @ - Initialize printer
      bytes.addAll([27, 64]);

      // Center align
      bytes.addAll([27, 97, 1]);

      // Bold text for header
      bytes.addAll([27, 69, 1]);
      bytes.addAll(utf8.encode('LEGPHEL\n'));
      bytes.addAll([27, 69, 0]); // Bold off

      // Normal text for address
      bytes.addAll(utf8.encode('Rinchending, Phuentsholing\n'));
      bytes.addAll(utf8.encode('Mobile: +975-17772393, +975-77772393\n'));
      bytes.addAll(utf8.encode('TPN: LAC00091\n'));
      bytes.addAll(utf8.encode('Email: legphel.hotel@gmail.com\n'));

      // Divider
      bytes.addAll(utf8.encode('--------------------------------\n'));

      // Left align
      bytes.addAll([27, 97, 0]);

      // Bill details
      bytes.addAll(utf8.encode('Bill ID: $id\n'));
      bytes.addAll(utf8.encode('Date: $date\n'));
      bytes.addAll(utf8.encode('Time: $time\n'));
      bytes.addAll(utf8.encode('User: $user\n'));
      bytes.addAll(utf8.encode('Table No: $tableNo\n'));

      // Divider
      bytes.addAll(utf8.encode('--------------------------------\n'));

      // Center align for header
      bytes.addAll([27, 97, 1]);
      bytes.addAll(utf8.encode('ITEMS PURCHASED\n'));

      // Left align for items
      bytes.addAll([27, 97, 0]);

      // Items list
      for (var item in items) {
        String itemLine = '${item['menuName']} x${item['quantity']}';
        String priceLine = 'Nu.${item['price']}';

        // Calculate spaces needed to align price to the right
        int lineLength = 32; // Typical thermal printer width
        int spacesNeeded = lineLength - itemLine.length - priceLine.length;
        if (spacesNeeded < 1) spacesNeeded = 1;

        String spaces = ' ' * spacesNeeded;
        bytes.addAll(utf8.encode('$itemLine$spaces$priceLine\n'));
      }

      // Divider
      bytes.addAll(utf8.encode('--------------------------------\n'));

      // Bill summary
      String subtotalLine = 'Subtotal:';
      String subtotalValue = 'Nu.${subTotal.toStringAsFixed(2)}';
      int subtotalSpaces = 32 - subtotalLine.length - subtotalValue.length;
      bytes.addAll(
          utf8.encode('$subtotalLine${' ' * subtotalSpaces}$subtotalValue\n'));

      String serviceLine = 'Service 10%:';
      String serviceValue = 'Nu.${(gst / 2).toStringAsFixed(2)}';
      int serviceSpaces = 32 - serviceLine.length - serviceValue.length;
      bytes.addAll(
          utf8.encode('$serviceLine${' ' * serviceSpaces}$serviceValue\n'));

      String bstLine = 'B.S.T 10%:';
      String bstValue = 'Nu.${(gst / 2).toStringAsFixed(2)}';
      int bstSpaces = 32 - bstLine.length - bstValue.length;
      bytes.addAll(utf8.encode('$bstLine${' ' * bstSpaces}$bstValue\n'));

      String discountLine = 'Discount:';
      String discountValue = 'Nu. 0.00';
      int discountSpaces = 32 - discountLine.length - discountValue.length;
      bytes.addAll(
          utf8.encode('$discountLine${' ' * discountSpaces}$discountValue\n'));

      // Divider
      bytes.addAll(utf8.encode('--------------------------------\n'));

      String quantityLine = 'Total Quantity:';
      String quantityValue = '$totalQuantity';
      int quantitySpaces = 32 - quantityLine.length - quantityValue.length;
      bytes.addAll(
          utf8.encode('$quantityLine${' ' * quantitySpaces}$quantityValue\n'));

      // Bold for total amount
      bytes.addAll([27, 69, 1]);
      String totalLine = 'Total Amount:';
      String totalValue = 'Nu.${totalAmount.toStringAsFixed(2)}';
      int totalSpaces = 32 - totalLine.length - totalValue.length;
      bytes.addAll(utf8.encode('$totalLine${' ' * totalSpaces}$totalValue\n'));
      bytes.addAll([27, 69, 0]); // Bold off

      String paymentLine = 'Payment Mode:';
      String paymentValue = payMode;
      int paymentSpaces = 32 - paymentLine.length - paymentValue.length;
      bytes.addAll(
          utf8.encode('$paymentLine${' ' * paymentSpaces}$paymentValue\n'));

      // Divider
      bytes.addAll(utf8.encode('--------------------------------\n'));

      // Center align for footer
      bytes.addAll([27, 97, 1]);

      // Bold for thank you
      // Bold for thank you
      bytes.addAll([27, 69, 1]);
      bytes.addAll(utf8.encode('Thank You! Visit Again!\n'));
      bytes.addAll([27, 69, 0]); // Bold off

      bytes.addAll(utf8.encode('Have a great day!\n'));

      // Feed and cut paper
      bytes.addAll([27, 100, 3]); // Feed 3 lines
      bytes.addAll([29, 86, 1]); // Cut paper

      // Send data to printer
      socket.add(bytes);
      await socket.flush();
      socket.destroy();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Print job sent to thermal printer')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to print: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Bill Details',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Bill #$id",
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                        const SizedBox(height: 8),
                        Text(user, style: const TextStyle(fontSize: 16)),
                        Text(phoneNo, style: const TextStyle(fontSize: 16)),
                        Text("Table: $tableNo",
                            style: const TextStyle(fontSize: 16)),
                        Text("$date at $time",
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),

                  // Items Section
                  const SizedBox(height: 20),
                  const Text("ORDER DETAILS",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(item['menuName'],
                                  style: const TextStyle(fontSize: 16)),
                            ),
                            Expanded(
                              child: Text(
                                "× ${item['quantity']}",
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Nu.${item['price']}",
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Summary Section
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                            "Subtotal", "Nu.${subTotal.toStringAsFixed(2)}"),
                        _buildSummaryRow("B.S.T 10%",
                            "Nu.${(subTotal * 0.1).toStringAsFixed(2)}"),
                        _buildSummaryRow("Service Charge 10%",
                            "Nu.${(subTotal * 0.1).toStringAsFixed(2)}"),
                        _buildSummaryRow(
                            "Total Quantity", totalQuantity.toString()),
                        const Divider(height: 24),
                        _buildSummaryRow("Total Amount",
                            "Nu.${totalAmount.toStringAsFixed(2)}",
                            isTotal: true),
                        const SizedBox(height: 8),
                        Text("Paid via $payMode",
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),

                  // Action Buttons
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.print),
                          label: const Text("Share PDF"),
                          onPressed: () async {
                            final pdfData = await _generatePdf();
                            await Printing.sharePdf(
                                bytes: pdfData, filename: "bill_$id.pdf");
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.receipt),
                          label: const Text("Thermal Print"),
                          onPressed: () => printWithEscPos(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Save PDF"),
                      onPressed: () => _savePdfLocally(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
