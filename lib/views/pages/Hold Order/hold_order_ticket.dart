import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_print_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HoldOrderTicket {
  final String id;
  final String date;
  final String time;
  final String user;
  final String tableNumber;
  final String contact;
  final String orderNumber;
  final List<MenuPrintModel> items;

  HoldOrderTicket({
    required this.id,
    required this.date,
    required this.time,
    required this.orderNumber,
    required this.user,
    required this.contact,
    required this.tableNumber,
    required this.items,
  });

  /// Generates a PDF ticket with Kitchen Order Ticket (KOT) and Bill Order Ticket (BOT) sections.
  ///
  /// Loads the logo, separates menu items into beverage and non-beverage categories,
  /// and creates a PDF document with detailed order information including table number,
  /// date, time, user, contact, and itemized list of ordered products.
  ///
  /// Returns a [Uint8List] containing the generated PDF data.
  Future<Uint8List> _generatePdfTicket() async {
    final pdf = pw.Document();

    final ByteData logoData = await rootBundle.load('assets/icons/logo.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();

    final nonBeverageItems =
        items.where((item) => item.product.menuType != "Beverage").toList();
    final beverageItems =
        items.where((item) => item.product.menuType == "Beverage").toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            /// ----------- KOT Section -----------
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Container(
                      width: 100,
                      height: 100,
                      child: pw.Image(pw.MemoryImage(logoBytes)),
                    ),
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
            pw.Text("Contact: $contact",
                style: const pw.TextStyle(fontSize: 7)),
            pw.SizedBox(height: 5),
            pw.Divider(),
            pw.Text("Items Ordered",
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
            pw.Divider(thickness: 0.5),
            ...nonBeverageItems.map((item) => pw.Row(
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

            pw.SizedBox(height: 10),

            // Dashed line between KOT and BOT
            pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 0),
              child: pw.Row(
                children: List.generate(
                  75, // Adjust the count as needed for width
                  (index) =>
                      pw.Text('-', style: const pw.TextStyle(fontSize: 8)),
                ),
              ),
            ),
            // Dashed line between KOT and BOT
            pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 0),
              child: pw.Row(
                children: List.generate(
                  75, // Adjust the count as needed for width
                  (index) =>
                      pw.Text('-', style: const pw.TextStyle(fontSize: 8)),
                ),
              ),
            ),

            /// ----------- BOT Section -----------
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Container(
                      width: 100,
                      height: 100,
                      child: pw.Image(pw.MemoryImage(logoBytes)),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("BOT",
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
            pw.Text("Contact: $contact",
                style: const pw.TextStyle(fontSize: 7)),
            pw.SizedBox(height: 5),
            pw.Divider(),
            pw.Text("Items Ordered",
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
            pw.Divider(thickness: 0.5),
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

  /// Generates plain text for direct printing to thermal printer
  String _generatePlainTextTicket() {
    // For Kharpandi goenpa
    // final nonBeverageItems = items
    //     .where((item) =>
    //         item.product.menuType == "Food" ||
    //         item.product.menuType == "Beverage")
    //     .toList();

    // final beverageItems = items
    //     .where((item) =>
    //         item.product.menuType == "Cold Drinks" ||
    //         item.product.menuType == "Shake")
    //     .toList();

    //  for other branch
    final nonBeverageItems = items
        .where((item) => item.product.itemDestination == "Kitchen")
        .toList();

    final beverageItems =
        items.where((item) => item.product.itemDestination == "Bar").toList();

    // ESC/POS commands for formatting
    const String esc = '\x1B';
    const String gs = '\x1D';
    const String centerAlign = '$esc\x61\x01';
    const String leftAlign = '$esc\x61\x00';
    const String rightAlign = '$esc\x61\x02';
    const String boldOn = '$esc\x45\x01';
    const String boldOff = '$esc\x45\x00';
    const String doubleHeight = '$gs\x21\x01';
    const String normalHeight = '$gs\x21\x00';
    const String cut = '$gs\x56\x00'; // Full cut
    const String feed = '$esc\x64\x05'; // Feed 5 lines
    const String init = '$esc\x40'; // Initialize printer

    // For 80mm printers, use max 48 characters
    const int maxWidth = 48;
    const int priceWidth = 10;

    String formatItemLine(String itemName, int quantity, double price) {
      String itemText = "$itemName x$quantity";
      String priceText = "Nu.${price.toStringAsFixed(2)}";

      if (itemText.length > (maxWidth - priceWidth)) {
        String firstLine = itemText.substring(0, maxWidth - priceWidth);
        String remainingText = itemText.substring(maxWidth - priceWidth);
        int spaceCount = maxWidth - remainingText.length - priceText.length;
        spaceCount = spaceCount < 0 ? 0 : spaceCount;
        return "$firstLine\n$remainingText${" " * spaceCount}$priceText";
      }

      final spaceCount = maxWidth - itemText.length - priceText.length;
      return "$itemText${' ' * spaceCount}$priceText";
    }

    StringBuffer buffer = StringBuffer();
    buffer.write(init);

    // === KOT Section ===
    buffer.write(centerAlign);
    buffer.write(boldOn);
    buffer.write(doubleHeight);
    buffer.write('KOT\n');
    buffer.write(leftAlign);
    buffer.write('LEGPHEL EATS\n');
    buffer.write('Order no: #$orderNumber\n\n');
    buffer.write(boldOff);
    buffer.write(normalHeight);

    buffer.write(leftAlign);
    buffer.write('Date : $date  ');
    buffer.write('Time : $time\n');
    // buffer.write('User   : $user\n');
    // buffer.write('Contact: $contact\n');
    // buffer.write('Table  : $tableNumber\n\n');

    buffer.write('-' * maxWidth + '\n');
    buffer.write(boldOn);
    buffer.write('Items Ordered\n');
    buffer.write(boldOff);
    buffer.write('-' * maxWidth + '\n');

    for (var item in nonBeverageItems) {
      buffer.writeln(formatItemLine(
          item.product.menuName, item.quantity, item.totalPrice));
    }

    buffer.write('-' * maxWidth + '\n\n');

    buffer.write(boldOn);
    buffer.write(doubleHeight);
    buffer.write('\n\nOrder no: #$orderNumber\n\n');
    buffer.write(boldOff);
    buffer.write(normalHeight);

    buffer.write(feed);
    buffer.write(cut);

    // === BOT Section ===
    // buffer.write(init);
    // buffer.write(centerAlign);
    // buffer.write(boldOn);
    // buffer.write(doubleHeight);
    // buffer.write('Summary Bill\n');
    // buffer.write(doubleHeight);
    // buffer.write('Order no: #$orderNumber\n\n');
    // buffer.write(boldOff);
    // buffer.write(normalHeight);

    // buffer.write(leftAlign);
    // buffer.write('Date : $date');
    // buffer.write('Time : $time\n');
    // // buffer.write('User   : $user\n');
    // // buffer.write('Contact: $contact\n');
    // // buffer.write('Table  : $tableNumber\n\n');

    // buffer.write('-' * maxWidth + '\n');
    // buffer.write(boldOn);
    // buffer.write('Items Ordered\n');
    // buffer.write(boldOff);
    // buffer.write('-' * maxWidth + '\n');

    // for (var item in beverageItems) {
    //   buffer.writeln(formatItemLine(
    //       item.product.menuName, item.quantity, item.totalPrice));
    // }

    // buffer.write('-' * maxWidth + '\n');
    // buffer.write(feed);
    // buffer.write(cut);

// === KOT Section ===
    buffer.write(centerAlign);
    buffer.write(boldOn);
    buffer.write(doubleHeight);
    buffer.write('Order Summary\n');
    buffer.write(leftAlign);
    buffer.write('LEGPHEL EATS\n');
    buffer.write('Order no: #$orderNumber\n\n');
    buffer.write(boldOff);
    buffer.write(normalHeight);

    buffer.write(leftAlign);
    buffer.write('Date : $date  ');
    buffer.write('Time : $time\n');
    // buffer.write('User   : $user\n');
    // buffer.write('Contact: $contact\n');
    // buffer.write('Table  : $tableNumber\n\n');

    buffer.write('-' * maxWidth + '\n');
    buffer.write(boldOn);
    buffer.write('Items Ordered\n');
    buffer.write(boldOff);
    buffer.write('-' * maxWidth + '\n');

    for (var item in nonBeverageItems) {
      buffer.writeln(formatItemLine(
          item.product.menuName, item.quantity, item.totalPrice));
    }

    buffer.write('-' * maxWidth + '\n\n');

    // === BOT Section ===
    buffer.write(init);
    buffer.write(centerAlign);
    buffer.write(boldOn);
    buffer.write(doubleHeight);
    buffer.write('BOT\n');
    buffer.write(normalHeight);
    buffer.write(boldOff);

    buffer.write(leftAlign);
    buffer.write('-' * maxWidth + '\n');
    buffer.write(boldOn);
    buffer.write('Items Ordered\n');
    buffer.write(boldOff);
    buffer.write('-' * maxWidth + '\n');

    for (var item in beverageItems) {
      buffer.writeln(formatItemLine(
          item.product.menuName, item.quantity, item.totalPrice));
    }

    buffer.write('-' * maxWidth + '\n');

    buffer.write(boldOn);
    buffer.write(doubleHeight);
    buffer.write('\n\nOrder no: #$orderNumber\n\n');
    buffer.write(normalHeight);
    buffer.write(boldOff);

    buffer.write(feed);
    buffer.write(cut);

    // === KOT Section ===
    buffer.write(centerAlign);
    buffer.write(boldOn);
    buffer.write(doubleHeight);
    buffer.write('Order Summary\n');
    buffer.write(leftAlign);
    buffer.write('LEGPHEL EATS\n');
    buffer.write('Order no: #$orderNumber\n\n');
    buffer.write(boldOff);
    buffer.write(normalHeight);

    buffer.write(leftAlign);
    buffer.write('Date : $date  ');
    buffer.write('Time : $time\n');
    // buffer.write('User   : $user\n');
    // buffer.write('Contact: $contact\n');
    // buffer.write('Table  : $tableNumber\n\n');

    buffer.write('-' * maxWidth + '\n');
    buffer.write(boldOn);
    buffer.write('Items Ordered\n');
    buffer.write(boldOff);
    buffer.write('-' * maxWidth + '\n');

    for (var item in nonBeverageItems) {
      buffer.writeln(formatItemLine(
          item.product.menuName, item.quantity, item.totalPrice));
    }

    buffer.write('-' * maxWidth + '\n\n');

    // === BOT Section ===
    buffer.write(init);
    buffer.write(centerAlign);
    buffer.write(boldOn);
    buffer.write(doubleHeight);
    buffer.write('BOT\n');
    buffer.write(normalHeight);
    buffer.write(boldOff);

    buffer.write(leftAlign);
    buffer.write('-' * maxWidth + '\n');
    buffer.write(boldOn);
    buffer.write('Items Ordered\n');
    buffer.write(boldOff);
    buffer.write('-' * maxWidth + '\n');

    for (var item in beverageItems) {
      buffer.writeln(formatItemLine(
          item.product.menuName, item.quantity, item.totalPrice));
    }

    buffer.write('-' * maxWidth + '\n');

    buffer.write(boldOn);
    buffer.write(doubleHeight);
    buffer.write('\n\nOrder no: #$orderNumber\n\n');
    buffer.write(normalHeight);
    buffer.write(boldOff);

    buffer.write(feed);
    buffer.write(cut);

    return buffer.toString();
  }

  /// Print directly to thermal printer using raw socket
  Future<void> printToThermalPrinter(BuildContext context) async {
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

      // For direct printing, we'll use plain text with ESC/POS commands
      final String textToPrint = _generatePlainTextTicket();

      // Connect to the printer via socket using the saved IP and port
      final socket = await Socket.connect(ipAddress, port);

      // Send the data to the printer
      socket.add(utf8.encode(textToPrint));

      // Wait for the data to be sent
      await socket.flush();

      // Close the socket
      socket.close();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully sent to printer"),
        ),
      );
      print("Data successfully sent to thermal printer at $serverAddress");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Printing error: $e"),
          backgroundColor: Colors.red,
        ),
      );
      print("Error printing to thermal printer: $e");
    }
  }

  /// Alternative method that sends PDF data directly to printer
  Future<void> printPdfToThermalPrinter(BuildContext context) async {
    try {
      final pdfData = await _generatePdfTicket();

      // Connect to the printer via socket
      final socket = await Socket.connect('192.168.1.251', 9100);

      // Send the PDF data to the printer
      socket.add(pdfData);

      // Wait for the data to be sent
      await socket.flush();

      // Close the socket
      socket.close();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully sent PDF to printer"),
        ),
      );
      print("PDF successfully sent to thermal printer");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Printing error: $e"),
          backgroundColor: Colors.red,
        ),
      );
      print("Error printing to thermal printer: $e");
    }
  }

  // Keep this method if you still want the option to save locally
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
      print("Failed to save PDF locally: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save PDF: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
