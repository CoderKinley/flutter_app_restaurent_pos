import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.grey[200],
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildReceiptItem(
                          'Friday, 7 February, 2025', 'Refund #3-1201',
                          isRefund: true),
                      _buildReceiptItem(
                          'Friday, 24 January, 2025', '1,590.00Nu #3-1201',
                          time: '5:21 pm'),
                      _buildReceiptItem(
                          'Friday, 24 January, 2025', '420.00Nu #3-1200',
                          time: '5:00 pm'),
                      _buildReceiptItem(
                          'Thursday, 23 January, 2025', '330.00Nu #3-1199',
                          time: '8:38 pm'),
                      _buildReceiptItem(
                          'Thursday, 23 January, 2025', '310.00Nu #3-1198',
                          time: '8:30 pm'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('150.00Nu',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Total', style: TextStyle(color: Colors.grey)),
                    Divider(),
                    Text('Employee: Owner'),
                    Text('POS: POS 3'),
                    SizedBox(height: 8),
                    Text('Dine in',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ListTile(
                      title: Text('Special Courier 180ml'),
                      trailing: Text('150.00Nu'),
                      subtitle: Text('1 x 150.00Nu'),
                    ),
                    Divider(),
                    Text('Total',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Cash'),
                        Text('1,000.00Nu'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Change'),
                        Text('850.00Nu'),
                      ],
                    ),
                    Divider(),
                    Text('07/02/25 1:20 am'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptItem(String date, String title,
      {String? time, bool isRefund = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.green)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(title,
                      style: TextStyle(
                          color: isRefund ? Colors.red : Colors.black)),
                ],
              ),
              if (time != null)
                Text(time, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
