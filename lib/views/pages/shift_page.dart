import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/hold_order_bloc/bloc/hold_order_bloc.dart';
import 'package:pos_system_legphel/models/Menu%20Model/hold_order_model.dart';
import 'package:pos_system_legphel/views/widgets/drawer_widget.dart';

class ShiftPage extends StatefulWidget {
  const ShiftPage({super.key});

  @override
  State<ShiftPage> createState() => _ShiftPageState();
}

class _ShiftPageState extends State<ShiftPage> {
  HoldOrderModel? selectedOrder;

  @override
  void initState() {
    super.initState();
    context.read<HoldOrderBloc>().add(LoadHoldOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("POS System")),
        drawer: const DrawerWidget(),
        body: Row(
          children: [
            // Left Side: List of Orders
            Expanded(
              flex: 2, // Adjusts width ratio
              child: BlocBuilder<HoldOrderBloc, HoldOrderState>(
                builder: (context, state) {
                  if (state is HoldOrderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is HoldOrderLoaded) {
                    if (state.holdOrders.isEmpty) {
                      return const Center(
                          child: Text("No Hold Orders Available"));
                    }

                    return ListView.builder(
                      itemCount: state.holdOrders.length,
                      itemBuilder: (context, index) {
                        final item = state.holdOrders[index];

                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  selectedOrder = item;
                                });
                              },
                              child: ListTile(
                                title: Text(item.customerName),
                                subtitle: Text("Order ID: ${item.holdOrderId}"),
                                trailing: Text("Table: ${item.tableNumber}"),
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    );
                  } else if (state is HoldOrderError) {
                    return Center(child: Text("Error: ${state.message}"));
                  }

                  return const Center(child: Text("Nothing to Show"));
                },
              ),
            ),

            // Right Side: Selected Order Details
            Expanded(
              flex: 3,
              child: selectedOrder != null
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Order Details",
                          ),
                          const SizedBox(height: 10),
                          Text("Customer Name: ${selectedOrder!.customerName}"),
                          Text("Table Number: ${selectedOrder!.tableNumber}"),
                          Text("Contact: ${selectedOrder!.customerContact}"),
                          Text("Order Date: ${selectedOrder!.orderDateTime}"),
                          const SizedBox(height: 10),
                          const Text("Menu Items:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  : const Center(
                      child: Text("Select an order to view details")),
            ),
          ],
        ));
  }
}
