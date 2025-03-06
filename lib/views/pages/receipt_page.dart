import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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

  final ScrollController scrollController = ScrollController();
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

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
                            // Group orders by date
                            Map<String, List<ProceedOrderModel>> groupedOrders =
                                {};
                            for (var order in state.proceedOrders) {
                              String dateKey = order.orderDateTime
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]; // Get the date part only
                              if (!groupedOrders.containsKey(dateKey)) {
                                groupedOrders[dateKey] = [];
                              }
                              groupedOrders[dateKey]!.add(order);
                            }

                            // Sort grouped orders by date in descending order
                            var reversedGroupedOrders = Map.fromEntries(
                                groupedOrders.entries.toList()
                                  ..sort((a, b) => b.key.compareTo(a.key)));

                            // Sort each day's orders by orderDateTime (time) in descending order
                            reversedGroupedOrders.updateAll((key, value) {
                              value.sort((a, b) =>
                                  b.orderDateTime.compareTo(a.orderDateTime));
                              return value;
                            });

                            return CustomScrollView(
                              controller: scrollController,
                              slivers: [
                                // Updating the header with dynamic date based on the first group
                                SliverPersistentHeader(
                                  pinned: true,
                                  delegate: _DateHeaderDelegate(
                                    reversedGroupedOrders,
                                    scrollController,
                                  ),
                                ),
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      final entry = reversedGroupedOrders
                                          .entries
                                          .toList()[index];
                                      return Column(
                                        children: [
                                          Column(
                                            children:
                                                entry.value.map((proceedOrder) {
                                              return Column(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedReceiptItem =
                                                            proceedOrder;
                                                      });
                                                    },
                                                    child: _buildReceiptItem(
                                                      DateFormat(
                                                              'yyyy-MM-dd HH:mm')
                                                          .format(proceedOrder
                                                              .orderDateTime)
                                                          .toString(),
                                                      'Name: ${proceedOrder.customerName}',
                                                      time: DateFormat('HH:mm')
                                                          .format(proceedOrder
                                                              .orderDateTime),
                                                      onDelete: () {
                                                        context
                                                            .read<
                                                                ProceedOrderBloc>()
                                                            .add(
                                                              DeleteProceedOrder(
                                                                  proceedOrder
                                                                      .holdOrderId),
                                                            );
                                                      },
                                                    ),
                                                  ),
                                                  const Divider(),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      );
                                    },
                                    childCount: reversedGroupedOrders.length,
                                  ),
                                ),
                              ],
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
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              const Text(
                                                'Total',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Text(
                                          'Customer Name: ${selectedReceiptItem!.customerName}'),
                                      Text(
                                          'Contace Number: ${selectedReceiptItem!.phoneNumber}'),
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
      {String? time, bool isRefund = false, required Function onDelete}) {
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
              // Add the PopupMenuButton for delete option
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (String value) {
                  if (value == 'delete') {
                    _showDeleteConfirmationDialog(context, onDelete);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ];
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Function onDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                onDelete(); // Call the onDelete function when confirming
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _DateHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Map<String, List<ProceedOrderModel>> groupedOrders;
  final ScrollController scrollController;

  _DateHeaderDelegate(this.groupedOrders, this.scrollController);

  @override
  double get minExtent => 49.0;

  @override
  double get maxExtent => 49.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    int currentIndex = (scrollController.offset / 50).floor();
    String currentDate = groupedOrders.keys.elementAt(currentIndex);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Colors.green,
      child: Text(
        currentDate, // Displaying the current date based on scroll
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
