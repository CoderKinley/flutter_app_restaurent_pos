import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This class is use to print the Bill data and also to save the pdf format to the local storage
class BillService {
  /// Generate PDF for bill receipt
  static Future<Uint8List> generatePdf({
    required String id,
    required String user,
    required String phoneNo,
    required String tableNo,
    required List<Map<String, dynamic>> items,
    required double subTotal,
    required double bst,
    required double serviceTax,
    required int totalQuantity,
    required String date,
    required String time,
    required double totalAmount,
    required String payMode,
    required String orderNumber,
    required String branchName,
  }) async {
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
                pw.Text("Nu.${(bst).toStringAsFixed(2)}",
                    style: const pw.TextStyle(fontSize: 8)),
              ],
            ),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("B.S.T 10%:", style: const pw.TextStyle(fontSize: 8)),
                pw.Text("Nu.${(serviceTax).toStringAsFixed(2)}",
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
  static Future<void> savePdfLocally({
    required BuildContext context,
    required String id,
    required Future<Uint8List> Function() pdfGenerator,
  }) async {
    try {
      // Request storage permissions first
      if (await Permission.manageExternalStorage.request().isGranted) {
        final pdfData = await pdfGenerator();

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
  static Future<void> printWithEscPos({
    required BuildContext context,
    required String orderNumber,
    required String branchName,
    required double bstAmt,
    required double serviceAmt,
    required String id,
    required String user,
    required String phoneNo,
    required String tableNo,
    required List<Map<String, dynamic>> items,
    required double subTotal,
    required double bst,
    required double serviceTax,
    required int totalQuantity,
    required String date,
    required String time,
    required double discount,
    required double totalAmount,
    required String payMode,
  }) async {
    try {
      // Get the saved server address from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final serverAddress = prefs.getString('server_ip_address');

      if (serverAddress == null) {
        throw Exception(
            'Server address not configured. Please set up the printer IP address in Settings.');
      }

      // Split the address into IP and port
      final parts = serverAddress.split(':');
      if (parts.length != 2) {
        throw Exception(
            'Invalid server address format. Please check the IP address configuration.');
      }

      final ipAddress = parts[0];
      final port = int.parse(parts[1]);

      final socket = await Socket.connect(ipAddress, port);

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
      buffer.writeln('LEGPHEL HOTEL');
      buffer.write(boldOff);
      buffer.write("Branch Name: ");
      buffer.writeln(branchName);
      buffer.writeln('Rinchending, Phuentsholing');
      buffer.writeln('Mobile: +975-17872219');
      // buffer.writeln('TPN: LAC00091');
      // buffer.writeln('Email: legphel.hotel@gmail.com');

      buffer.writeln('-' * lineLength);
      buffer.write(leftAlign);

      buffer.writeln('Order No: $orderNumber');
      buffer.writeln('Table No: $tableNo');
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
      void addSummaryLine(String label, String value, {bool bold = false}) {
        int space = lineLength - label.length - value.length;
        String padding = ' ' * (space < 0 ? 0 : space);
        if (bold) buffer.write(boldOn);
        buffer.writeln('$label$padding$value');
        if (bold) buffer.write(boldOff);
      }

      buffer.writeln();
      addSummaryLine('Total Quantity:', '$totalQuantity');

      buffer.writeln('-' * lineLength);

      addSummaryLine('Subtotal:', 'Nu.${subTotal.toStringAsFixed(2)}');
      addSummaryLine('Service ${bst}%:', 'Nu.${(bstAmt).toStringAsFixed(2)}');
      addSummaryLine(
          'B.S.T ${serviceTax}%:', 'Nu.${(serviceAmt).toStringAsFixed(2)}');
      addSummaryLine('Discount:', 'Nu.${discount.toStringAsFixed(2)}');

      buffer.writeln('-' * lineLength);
      addSummaryLine('Total Amount:', 'Nu.${totalAmount.toStringAsFixed(2)}',
          bold: true);
      addSummaryLine('Payment Mode:', payMode);

      buffer.writeln('-' * lineLength);

      buffer.write(centerAlign);
      buffer.write(boldOn);
      buffer.writeln('Thank You! Visit Again!');
      buffer.write(boldOff);
      buffer.writeln('Have a great day!');
      buffer.writeln();
      buffer.writeln();
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
        SnackBar(
          content: Text('Failed to print: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Share PDF using platform sharing capabilities
  static Future<void> sharePdf({
    required String id,
    required Future<Uint8List> Function() pdfGenerator,
  }) async {
    final pdfData = await pdfGenerator();
    await Printing.sharePdf(bytes: pdfData, filename: "bill_$id.pdf");
  }
}
