import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_bill_model.dart';
import 'package:printing/printing.dart';

class HoldOrderBarTicket {
  final String id;
  final String date;
  final String time;
  final String user;
  final String contact;
  final String tableNumber;
  final List<MenuBillModel> items;

  HoldOrderBarTicket({
    required this.id,
    required this.date,
    required this.time,
    required this.user,
    required this.tableNumber,
    required this.contact,
    required this.items,
  });

  Future<Uint8List> _generatePdfTicket() async {
    final pdf = pw.Document();

    final ByteData logoData = await rootBundle.load('assets/icons/logo.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();

    // Filter items to only include beverages
    final beverageItems =
        items.where((item) => item.product.menuType == "Beverage").toList();

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
                      width: 100,
                      height: 100,
                      child: pw.Image(pw.MemoryImage(logoBytes)),
                    ),
                    // Right: Business Details
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("BOT",
                            style: pw.TextStyle(
                                fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text("Table: $tableNumber",
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
            pw.Text("Customer: $user", style: const pw.TextStyle(fontSize: 7)),
            pw.Text("Table Number: $tableNumber",
                style: const pw.TextStyle(fontSize: 7)),
            pw.Text("Contact: $contact",
                style: const pw.TextStyle(fontSize: 7)),
            pw.SizedBox(height: 5),
            pw.Divider(),
            // Items Header
            pw.Text("Drinks Ordered",
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
            pw.Divider(thickness: 0.5),
            // Only display beverage items
            ...beverageItems.map((item) => pw.Row(
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
      if (await Permission.manageExternalStorage.request().isGranted) {
        final pdfData = await _generatePdfTicket();

        final ticketDirectory =
            Directory('/storage/emulated/0/Bar Ticket Folder PDF');
        if (!await ticketDirectory.exists()) {
          await ticketDirectory.create(recursive: true);
        }

        final file = File('${ticketDirectory.path}/bar_ticket_$id.pdf');
        await file.writeAsBytes(pdfData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Bar Ticket Saved to ${file.path}"),
          ),
        );

        print("Bar Ticket PDF saved to ${file.path}");

        await Printing.sharePdf(
          bytes: pdfData,
          filename: "bar_order_$id.pdf",
        );

        print("Bar Ticket PDF sent to printer.");
      }
    } catch (e) {
      print("Failed to save or print Bar Ticket PDF: $e");
    }
  }
}
