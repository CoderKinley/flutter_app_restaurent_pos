import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/hold_order_bloc/bloc/hold_order_bloc.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_bill_model.dart';
import 'package:pos_system_legphel/views/pages/sales_page.dart';

class HoldOrderPage extends StatefulWidget {
  final List<MenuBillModel> menuItems;

  const HoldOrderPage({
    super.key,
    required this.menuItems,
  });

  @override
  State<HoldOrderPage> createState() => _HoldOrderPageState();
}

class _HoldOrderPageState extends State<HoldOrderPage> {
  @override
  void initState() {
    super.initState();
    context.read<HoldOrderBloc>().add(LoadHoldOrders());
  }

  // Example list of tables, each with a list of on-hold items
  // final List<Map<String, dynamic>> tables = [
  //   {
  //     'tableNumber': 1,
  //     'items': [
  //       {'name': 'Burger', 'quantity': 2, 'price': 5.00},
  //       {'name': 'Fries', 'quantity': 1, 'price': 2.50},
  //     ],
  //   },
  //   {
  //     'tableNumber': 2,
  //     'items': [
  //       {'name': 'Pizza', 'quantity': 1, 'price': 8.00},
  //       {'name': 'Soda', 'quantity': 3, 'price': 1.20},
  //     ],
  //   },
  //   {
  //     'tableNumber': 3,
  //     'items': [
  //       {'name': 'Pasta', 'quantity': 2, 'price': 6.50},
  //       {'name': 'Water', 'quantity': 4, 'price': 0.80},
  //     ],
  //   },
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hold Order Items'),
        centerTitle: true,
      ),
      // body: Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //   child: ListView.builder(
      //     itemCount: menuItems.length,
      //     itemBuilder: (context, tableIndex) {
      //       final menuItem = menuItems[tableIndex];
      //       final table = tables[tableIndex];
      //       final tableNumber = table['tableNumber'];
      //       final items = table['items'];
      //       final total = items.fold(
      //           0, (sum, item) => sum + item['price'] * item['quantity']);

      //       return Card(
      //         margin: EdgeInsets.symmetric(vertical: 4),
      //         shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(10)),
      //         elevation: 3,
      //         child: ExpansionTile(
      //           tilePadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      //           title: Text(
      //             '${menuItem.product.name}',
      //             style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      //           ),
      //           trailing: Row(
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               Text('Total: \$${total}',
      //                   style: TextStyle(
      //                       fontWeight: FontWeight.bold, fontSize: 14)),
      //               SizedBox(width: 8),
      //               OutlinedButton(
      //                 onPressed: () {},
      //                 style: OutlinedButton.styleFrom(
      //                   padding:
      //                       EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      //                   shape: RoundedRectangleBorder(
      //                       borderRadius: BorderRadius.circular(6)),
      //                 ),
      //                 child: Text('Pay', style: TextStyle(fontSize: 12)),
      //               ),
      //               SizedBox(width: 4),
      //               OutlinedButton(
      //                 onPressed: () {},
      //                 style: OutlinedButton.styleFrom(
      //                   padding:
      //                       EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      //                   shape: RoundedRectangleBorder(
      //                       borderRadius: BorderRadius.circular(6)),
      //                 ),
      //                 child: Text('Cancel', style: TextStyle(fontSize: 12)),
      //               ),
      //             ],
      //           ),
      //           children: [
      //             Padding(
      //               padding: const EdgeInsets.symmetric(
      //                   horizontal: 16.0, vertical: 4),
      //               child: Column(
      //                 children: [
      //                   for (int i = 0; i < items.length; i++) ...[
      //                     Padding(
      //                       padding: const EdgeInsets.symmetric(vertical: 6),
      //                       child: Row(
      //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                         children: [
      //                           Text(items[i]['name'],
      //                               style: TextStyle(fontSize: 12)),
      //                           Text('× ${items[i]['quantity']}',
      //                               style: TextStyle(fontSize: 12)),
      //                           Text('\$${items[i]['price']}',
      //                               style: TextStyle(
      //                                   fontSize: 12,
      //                                   fontWeight: FontWeight.bold)),
      //                         ],
      //                       ),
      //                     ),
      //                     if (i != items.length - 1)
      //                       Divider(height: 1, thickness: 0.5),
      //                   ],
      //                 ],
      //               ),
      //             )
      //           ],
      //         ),
      //       );
      //     },
      //   ),
      // ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: BlocBuilder<HoldOrderBloc, HoldOrderState>(
          builder: (context, state) {
            if (state is HoldOrderLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HoldOrderLoaded) {
              return ListView.builder(
                itemCount: state.holdOrders.length,
                itemBuilder: (context, index) {
                  final holdOrderItem = state.holdOrders[index];
                  final items = holdOrderItem.menuItems;
                  final total =
                      items.fold(0.0, (sum, item) => sum + item.totalPrice);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      title: Text(
                        'Order ID: #${holdOrderItem.holdOrderId}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Total: Nu.${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.green,
                              )),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () {
                              // Navigator.pop(context, holdOrderItem);
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return SalesPage(
                                    hold_order_model: holdOrderItem,
                                  );
                                },
                              ));
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                            child: const Text('Confirm',
                                style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () {
                              context.read<HoldOrderBloc>().add(
                                  DeleteHoldOrder(holdOrderItem.holdOrderId));
                            },
                            icon: const Icon(Icons.delete, size: 20),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 4,
                          ),
                          child: Column(
                            children: [
                              for (int i = 0; i < items.length; i++) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(items[i].product.name,
                                          style: const TextStyle(fontSize: 12)),
                                      Text('× ${items[i].quantity}',
                                          style: const TextStyle(fontSize: 12)),
                                      Text(
                                          '\$${items[i].product.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                if (i != items.length - 1)
                                  Divider(height: 1, thickness: 0.5),
                              ],
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            }
            return Center(child: Text("Nothing"));
          },
        ),
      ),
    );
  }
}
