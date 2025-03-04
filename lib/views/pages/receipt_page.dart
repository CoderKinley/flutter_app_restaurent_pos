import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/proceed_order_bloc/bloc/proceed_order_bloc.dart';
import 'package:pos_system_legphel/views/widgets/drawer_menu_widget.dart';
import 'package:pos_system_legphel/models/Menu%20Model/proceed_order_model.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  _ReceiptPageState createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  ProceedOrderModel? selectedReceiptItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0, left: 0),
      child: Row(
        children: [
          // Left side (List of receipts)
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
                    child: BlocProvider(
                      create: (_) =>
                          ProceedOrderBloc()..add(LoadProceedOrders()),
                      child: BlocBuilder<ProceedOrderBloc, ProceedOrderState>(
                        builder: (context, state) {
                          if (state is ProceedOrderLoading) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (state is ProceedOrderLoaded) {
                            return ListView(
                              children: state.proceedOrders.map((proceedOrder) {
                                return Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedReceiptItem = proceedOrder;
                                        });
                                      },
                                      child: _buildReceiptItem(
                                        proceedOrder.orderDateTime.toString(),
                                        'Name: ${proceedOrder.customerName}',
                                        time: proceedOrder.orderDateTime
                                            .toString(),
                                      ),
                                    ),
                                    const Divider(),
                                  ],
                                );
                              }).toList(),
                            );
                          }
                          if (state is ProceedOrderError) {
                            return Center(child: Text(state.message));
                          }
                          return Container();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Right side (Detailed view of selected receipt item)
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
                    child: selectedReceiptItem == null
                        ? const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Center(
                              child: Text(
                                'Select an item to view details',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SingleChildScrollView(
                              child: Card(
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${selectedReceiptItem!.totalPrice}Nu',
                                                style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const Text(
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
                                      const Divider(),
                                      Text(
                                          'Employee: ${selectedReceiptItem!.customerName}'),
                                      Text(
                                          'POS: ${selectedReceiptItem!.restaurantBranchName}'),
                                      const SizedBox(height: 8),
                                      const Text('Dine in',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),

                                      // List of menu items
                                      for (var item
                                          in selectedReceiptItem!.menuItems)
                                        ListTile(
                                          title: Text(item.product.name),
                                          trailing:
                                              Text('${item.totalPrice}Nu'),
                                          subtitle: Text(
                                              '${item.quantity} x ${item.product.price}Nu'),
                                        ),
                                      const Divider(),
                                      const Text('Total',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Cash'),
                                          Text(
                                              '${selectedReceiptItem!.totalPrice}Nu'),
                                        ],
                                      ),
                                      const Divider(),
                                      Text(
                                          '${selectedReceiptItem!.orderDateTime.toLocal()}'),
                                    ],
                                  ),
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
                  Text(title),
                ],
              ),
              // if (time != null)
              //   Text(time, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
