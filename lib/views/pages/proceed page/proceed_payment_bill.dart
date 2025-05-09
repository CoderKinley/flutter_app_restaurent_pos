import 'dart:convert';
import 'dart:io';

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
  final String orderNumber;

  const ProceedPaymentBill({
    super.key,
    required this.orderNumber,
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
                pw.Text("Order No: $orderNumber",
                    style: const pw.TextStyle(fontSize: 7)),
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
      final socket = await Socket.connect('192.168.1.251', 9100);

      // ESC/POS command constants
      const String esc = '\x1B';
      const String gs = '\x1D';
      const String init = '$esc\x40';
      const String centerAlign = '$esc\x61\x01';
      const String leftAlign = '$esc\x61\x00';
      const String boldOn = '$esc\x45\x01';
      const String boldOff = '$esc\x45\x00';
      const String feed = '$esc\x64\x03';
      const String cut = '$gs\x56\x01';

      const int lineLength = 48;

      StringBuffer buffer = StringBuffer();
      buffer.write(init);
      buffer.write(centerAlign);
      buffer.write(boldOn);
      buffer.writeln('LEGPHEL EATS');
      buffer.write(boldOff);
      buffer.writeln('Rinchending, Phuentsholing');
      buffer.writeln('Mobile: +975-17872219');
      // buffer.writeln('TPN: LAC00091');
      // buffer.writeln('Email: legphel.hotel@gmail.com');

      buffer.writeln('-' * lineLength);
      buffer.write(leftAlign);

      buffer.writeln('Bill ID: $id');
      buffer.writeln('Order No: $orderNumber');
      buffer.write('Date: $date  ');
      buffer.writeln('Time: $time');
      // buffer.writeln('User: $user');
      // buffer.writeln('Table No: $tableNo');

      buffer.writeln('-' * lineLength);

      buffer.write(centerAlign);
      buffer.writeln('ITEMS PURCHASED');
      buffer.write(leftAlign);

      for (var item in items) {
        String itemLine = '${item['menuName']} x${item['quantity']}';
        String priceLine = 'Nu.${item['price']}';

        int spacesNeeded = lineLength - itemLine.length - priceLine.length;
        if (spacesNeeded < 1) spacesNeeded = 1;
        String spaces = ' ' * spacesNeeded;

        buffer.writeln('$itemLine$spaces$priceLine');
      }

      buffer.writeln('-' * lineLength);

      void addSummaryLine(String label, String value, {bool bold = false}) {
        int space = lineLength - label.length - value.length;
        String padding = ' ' * (space < 0 ? 0 : space);
        if (bold) buffer.write(boldOn);
        buffer.writeln('$label$padding$value');
        if (bold) buffer.write(boldOff);
      }

      // addSummaryLine('Subtotal:', 'Nu.${subTotal.toStringAsFixed(2)}');
      // addSummaryLine('Service 10%:', 'Nu.${(gst / 2).toStringAsFixed(2)}');
      // addSummaryLine('B.S.T 10%:', 'Nu.${(gst / 2).toStringAsFixed(2)}');
      // addSummaryLine('Discount:', 'Nu. 0.00');

      addSummaryLine('Total Quantity:', '$totalQuantity');
      addSummaryLine('Total Amount:', 'Nu.${totalAmount.toStringAsFixed(2)}',
          bold: true);
      addSummaryLine('Payment Mode:', payMode);

      buffer.writeln('-' * lineLength);

      buffer.write(centerAlign);
      buffer.write(boldOn);
      buffer.writeln('Thank You! Visit Again!');
      buffer.write(boldOff);
      buffer.writeln('Have a great day!');

      buffer.write(feed);
      buffer.write(cut);

      socket.add(utf8.encode(buffer.toString()));
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
                        // _buildSummaryRow(
                        //     "Subtotal", "Nu.${subTotal.toStringAsFixed(2)}"),
                        // _buildSummaryRow("B.S.T 10%",
                        //     "Nu.${(subTotal * 0.1).toStringAsFixed(2)}"),
                        // _buildSummaryRow("Service Charge 10%",
                        //     "Nu.${(subTotal * 0.1).toStringAsFixed(2)}"),
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
