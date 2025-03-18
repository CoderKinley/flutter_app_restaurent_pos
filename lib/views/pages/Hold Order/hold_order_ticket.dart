import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_bill_model.dart';
import 'package:printing/printing.dart';

class HoldOrderTicket {
  final String id;
  final String date;
  final String time;
  final String user;
  final String tableNumber;
  final String contact;
  final List<MenuBillModel> items;

  HoldOrderTicket({
    required this.id,
    required this.date,
    required this.time,
    required this.user,
    required this.contact,
    required this.tableNumber,
    required this.items,
  });

  Future<Uint8List> _generatePdfTicket() async {
    final pdf = pw.Document();

    final ByteData logoData = await rootBundle.load('assets/icons/logo.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Logo
                    pw.Container(
                      width: 50,
                      height: 50,
                      child: pw.Image(pw.MemoryImage(logoBytes)),
                    ),
                    // Right: Business Details
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("KOT",
                            style: pw.TextStyle(
                                fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text("Table no: $tableNumber",
                            style: pw.TextStyle(
                                fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1),
            pw.Text("Date: $date", style: const pw.TextStyle(fontSize: 7)),
            pw.Text("Time: $time", style: const pw.TextStyle(fontSize: 7)),
            pw.Text("User: $user", style: const pw.TextStyle(fontSize: 7)),
            pw.Text("Table No: $tableNumber",
                style: const pw.TextStyle(fontSize: 7)),
            pw.Text("Contact: ${contact}",
                style: const pw.TextStyle(fontSize: 7)),
            pw.SizedBox(height: 5),
            pw.Divider(),
            // Items Header
            pw.Text("Items Ordered",
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
            pw.Divider(thickness: 0.5),
            ...items.map((item) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                        child: pw.Text(
                            "${item.product.menuName} x ${item.quantity}",
                            style: const pw.TextStyle(fontSize: 7))),
                    pw.Text("Nu.${item.totalPrice}",
                        style: const pw.TextStyle(fontSize: 7)),
                  ],
                )),
            pw.Divider(thickness: 1),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  Future<void> savePdfTicketLocally(BuildContext context) async {
    try {
      // Request permission for external storage
      if (await Permission.manageExternalStorage.request().isGranted) {
        final pdfData = await _generatePdfTicket();

        final ticketDirectory =
            Directory('/storage/emulated/0/Ticket Folder PDF');
        if (!await ticketDirectory.exists()) {
          await ticketDirectory.create(recursive: true);
        }

        final file = File('${ticketDirectory.path}/ticket_$id.pdf');
        await file.writeAsBytes(pdfData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Pdf Saved to ${file.path}"),
          ),
        );

        print("PDF saved to ${file.path}");

        // Print the PDF directly to a specific printer
        await Printing.sharePdf(
          bytes: pdfData,
          filename: "bill__$id.pdf",
        );

        print("PDF sent to printer.");
      }
    } catch (e) {
      print("Failed to save or print PDF: $e");
    }
  }
}
