import 'package:flutter/material.dart';
import 'package:pos_system_legphel/views/widgets/drawer_menu_widget.dart';

class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0, left: 0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Container(
                  height: 60,
                  padding: const EdgeInsets.only(left: 0, right: 10, bottom: 0),
                  color: const Color.fromARGB(255, 3, 27, 48),
                  child: _mainTopMenu(action: _search()),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
                    child: ListView(
                      children: [
                        _buildReceiptItem(
                          'Friday, 7 February, 2025',
                          'Refund #3-1201',
                          isRefund: true,
                        ),
                        const Divider(),
                        _buildReceiptItem(
                          'Friday, 7 February, 2025',
                          'Refund #3-1201',
                          isRefund: true,
                        ),
                        const Divider(),
                        _buildReceiptItem(
                          'Friday, 7 February, 2025',
                          'Refund #3-1201',
                          isRefund: true,
                        ),
                        const Divider(),
                        _buildReceiptItem(
                          'Friday, 24 January, 2025',
                          '1,590.00Nu #3-1201',
                          time: '5:21 pm',
                        ),
                        const Divider(),
                        _buildReceiptItem(
                          'Friday, 24 January, 2025',
                          '420.00Nu #3-1200',
                          time: '5:00 pm',
                        ),
                        const Divider(),
                        _buildReceiptItem(
                          'Thursday, 23 January, 2025',
                          '330.00Nu #3-1199',
                          time: '8:38 pm',
                        ),
                        const Divider(),
                        _buildReceiptItem(
                          'Thursday, 23 January, 2025',
                          '310.00Nu #3-1198',
                          time: '8:30 pm',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  height: 60,
                  color: Colors.grey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "All Items",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.person_add),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.more_vert,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.grey[200],
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('150.00Nu',
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                        'Total',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Divider(),
                              Text('Employee: Owner'),
                              Text('POS: POS 3'),
                              SizedBox(height: 8),
                              Text('Dine in',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              ListTile(
                                title: Text('Special Courier 180ml'),
                                trailing: Text('150.00Nu'),
                                subtitle: Text('1 x 150.00Nu'),
                              ),
                              Divider(),
                              Text('Total',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Cash'),
                                  Text('1,000.00Nu'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainTopMenu({
    required Widget action,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            flex: 0,
            child: DrawerMenuWidget(),
          ),
          Expanded(
            flex: 5,
            child: Container(),
          ),
          Expanded(flex: 5, child: action),
        ],
      ),
    );
  }

  Widget _search() {
    return TextField(
      style: const TextStyle(),
      decoration: InputDecoration(
        filled: true,
        prefixIcon: const Icon(
          Icons.search,
        ),
        hintText: 'Search menu here...',
        hintStyle: const TextStyle(fontSize: 11),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  //  BUild a receipt File out of it
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
