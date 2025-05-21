import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/destination/bloc/destination_bloc.dart';
import 'package:pos_system_legphel/models/destination_model.dart';
import 'package:pos_system_legphel/services/database_helper.dart';
import 'package:pos_system_legphel/views/pages/Add Items/add_new_destination.dart';

class ItemDestinationList extends StatefulWidget {
  const ItemDestinationList({super.key});

  @override
  State<ItemDestinationList> createState() => _ItemDestinationListState();
}

class _ItemDestinationListState extends State<ItemDestinationList> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content of the screen
        BlocBuilder<DestinationBloc, DestinationState>(
          builder: (context, state) {
            if (state is DestinationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DestinationLoaded) {
              return ListView.builder(
                itemCount: state.destinations.length,
                itemBuilder: (context, index) {
                  final destination = state.destinations[index];
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: context.read<DestinationBloc>(),
                                child: AddDestinationPage(
                                  destination: destination,
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                destination.name.toLowerCase().contains('bar')
                                    ? Icons.local_bar
                                    : Icons.restaurant,
                                color: Colors.blue,
                              ),
                            ),
                            title: Text(destination.name),
                            trailing: IconButton(
                              onPressed: () {
                                _confirmDeleteDestination(
                                    context, destination.id!, destination.name);
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ),
                        ),
                      ),
                      const Divider(), // Divider between items
                    ],
                  );
                },
              );
            } else if (state is DestinationError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('No Destinations Available'));
          },
        ),
        // Custom Floating Action Button
        Positioned(
          bottom: 20,
          right: 20,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<DestinationBloc>(),
                    child: const AddDestinationPage(),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 3, 27, 48),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDeleteDestination(
      BuildContext context, int destinationId, String destinationName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Destination"),
          content:
              const Text("Are you sure you want to delete this destination?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<DestinationBloc>()
                  ..add(DeleteDestination(id: destinationId))
                  ..add(LoadDestinations());
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
