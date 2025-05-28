import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/allergic_items_bloc/bloc/allergic_items_bloc.dart';
import 'package:pos_system_legphel/models/Menu Model/allergic_item_model.dart';
import 'package:uuid/uuid.dart';

class AllergicItemsList extends StatefulWidget {
  const AllergicItemsList({super.key});

  @override
  State<AllergicItemsList> createState() => _AllergicItemsListState();
}

class _AllergicItemsListState extends State<AllergicItemsList> {
  late final AllergicItemsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<AllergicItemsBloc>();
    _bloc.add(LoadAllergicItems());
  }

  void _showAddEditDialog([AllergicItemModel? item]) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final descriptionController =
        TextEditingController(text: item?.description ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item == null ? 'Add Allergic Item' : 'Edit Allergic Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newItem = AllergicItemModel(
                id: item?.id ?? const Uuid().v4(),
                name: nameController.text,
                description: descriptionController.text,
                createdAt: item?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              if (item == null) {
                _bloc.add(AddAllergicItem(newItem));
              } else {
                _bloc.add(UpdateAllergicItem(newItem));
              }

              Navigator.pop(dialogContext);
            },
            child: Text(item == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllergicItemsBloc, AllergicItemsState>(
      builder: (context, state) {
        if (state is AllergicItemsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AllergicItemsError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is AllergicItemsLoaded) {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Allergic Items',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add New'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: state.items.isEmpty
                        ? const Center(
                            child: Text(
                              'No allergic items added yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.items.length,
                            itemBuilder: (context, index) {
                              final item = state.items[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.warning,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(item.description),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () =>
                                            _showAddEditDialog(item),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (dialogContext) =>
                                                AlertDialog(
                                              title: const Text('Delete Item'),
                                              content: Text(
                                                  'Are you sure you want to delete ${item.name}?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          dialogContext),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    _bloc.add(
                                                        DeleteAllergicItem(
                                                            item.id));
                                                    Navigator.pop(
                                                        dialogContext);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
