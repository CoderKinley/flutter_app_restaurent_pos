import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/tables%20and%20names/bloc/customer_info_bloc.dart';

class CustomerOrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customer Orders')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Button to fetch all orders
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<CustomerInfoBloc>(context)
                      .add(FetchCustomerOrders()); // Fetch all orders
                },
                child: Text('Fetch All Orders'),
              ),
              SizedBox(height: 20),
              // BlocBuilder to handle the UI based on the state
              BlocBuilder<CustomerInfoBloc, CustomerInfoState>(
                builder: (context, state) {
                  if (state is CustomerInfoLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is CustomerInfoLoaded) {
                    final orders = state.orders;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text('Order ID: ${order.orderId}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Customer: ${order.customerName}'),
                                Text('Table: ${order.tableNumber}'),
                                Text('Order Date: ${order.orderDateTime}'),
                                Text('Menu Items: ${order.orderedItems}'),
                                // Display more order details here as needed
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Show a confirmation dialog before deleting
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Delete Order'),
                                    content: Text(
                                      'Are you sure you want to delete this order?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Trigger the delete event
                                          BlocProvider.of<CustomerInfoBloc>(
                                                  context)
                                              .add(DeleteCustomerOrder(
                                                  order.orderId));
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is CustomerInfoError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else {
                    return Center(child: Text('No data available'));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
