import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class HoldOrderTicket {
  final String id;
  final String date;
  final String time;
  final String user;
  final String tableNumber;

  HoldOrderTicket({
    required this.id,
    required this.date,
    required this.time,
    required this.user,
    required this.tableNumber,
  });

  Future<Uint8List> _generatePdfTicket() async {
    final pdf = pw.Document();

    final ByteData logoData = await rootBundle.load('assets/icons/logo.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll57,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
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
                        pw.Text("Table No: $tableNumber",
                            style: pw.TextStyle(
                                fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text("Table No: $user",
                            style: pw.TextStyle(
                                fontSize: 10, fontWeight: pw.FontWeight.bold)),
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
            pw.SizedBox(height: 5),
            pw.Text("Contact: 17807306"),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  // Save the PDF File Locally
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
      }
    } catch (e) {
      print("Failed to save PDF: $e");
    }
  }
}
