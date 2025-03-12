import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/hold_order_bloc/bloc/hold_order_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_item_bloc/bloc/menu_bloc.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_bill_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hold Order Items'),
        centerTitle: true,
      ),
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      title: Row(
                        children: [
                          Text(
                            'Table No: ${holdOrderItem.tableNumber}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                              context.read<MenuBloc>().add(
                                    UpdateCartItemQuantity(items),
                                  );
                              Navigator.pop(context, holdOrderItem);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'Confirm',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () {
                              context.read<HoldOrderBloc>().add(
                                    DeleteHoldOrder(
                                      holdOrderItem.holdOrderId,
                                    ),
                                  );
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
                                      Text(
                                        items[i].product.menuName,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        '× ${items[i].quantity}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'Nu${(double.tryParse(items[i].product.price) ?? 0.0).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                if (i != items.length - 1)
                                  const Divider(height: 1, thickness: 0.5),
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
            return const Center(child: Text("Nothing"));
          },
        ),
      ),
    );
  }
}
