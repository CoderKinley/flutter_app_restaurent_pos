import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';

// class  ProceedPages extends StatelessWidget {
//   const ProceedPages({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: const Center(
//         child: Text("Bill Page"),
//       ),
//     );
//   }
// }

class ProceedPaymentBill extends StatelessWidget {
  final String id;
  final String user;
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
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Bill ID: $id",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text("User: $user"),
            pw.Text("Table No: $tableNo"),
            pw.SizedBox(height: 8),
            pw.Text("Items:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ...items.map((item) => pw.Text(
                "${item['name']} - Qty: ${item['quantity']}, Price: \$${item['price']}")),
            pw.Divider(),
            pw.Text("Subtotal: \$${subTotal.toStringAsFixed(2)}"),
            pw.Text("GST: \$${gst.toStringAsFixed(2)}"),
            pw.Text("Total Quantity: $totalQuantity"),
            pw.Text("Date: $date"),
            pw.Text("Time: $time"),
            pw.SizedBox(height: 8),
            pw.Text("Total Amount: \$${totalAmount.toStringAsFixed(2)}",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text("Payment Mode: $payMode",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
                              child: Text(item['name'],
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
                                "\$${item['price']}",
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
                            "Subtotal", "\$${subTotal.toStringAsFixed(2)}"),
                        _buildSummaryRow("GST", "\$${gst.toStringAsFixed(2)}"),
                        _buildSummaryRow(
                            "Total Quantity", totalQuantity.toString()),
                        const Divider(height: 24),
                        _buildSummaryRow("Total Amount",
                            "\$${totalAmount.toStringAsFixed(2)}",
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
                          label: const Text("Print"),
                          onPressed: () async {
                            final pdfData = await _generatePdf();
                            await Printing.layoutPdf(
                                onLayout: (format) async => pdfData);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.share),
                          label: const Text("Share"),
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
// Helper method for summary rows
}
