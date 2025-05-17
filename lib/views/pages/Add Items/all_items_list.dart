import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_from_api/bloc/menu_from_api_bloc.dart';
import 'package:pos_system_legphel/models/settings/app_settings.dart';
import 'package:pos_system_legphel/views/pages/Add%20Items/add_new_item_page.dart';

class AllItemsList extends StatefulWidget {
  const AllItemsList({super.key});

  @override
  State<AllItemsList> createState() => _AllItemsListState();
}

class _AllItemsListState extends State<AllItemsList> {
  bool _showFetchButton = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final showFetchButton = await AppSettings.getShowFetchButton();
    setState(() {
      _showFetchButton = showFetchButton;
    });
  }

  void _showDeleteConfirmation(
      BuildContext context, String menuId, String menuName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text('Are you sure you want to delete "$menuName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<MenuApiBloc>().add(RemoveMenuApiItem(menuId));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$menuName deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          BlocBuilder<MenuApiBloc, MenuApiState>(
            builder: (context, state) {
              if (state is MenuApiLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is MenuApiLoaded) {
                return ListView.builder(
                  itemCount: state.menuItems.length,
                  itemBuilder: (context, index) {
                    final items = state.menuItems[index];
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return AddNewItemPage(
                                  product: items,
                                );
                              },
                            ));
                          },
                          child: Container(
                            margin:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ListTile(
                              leading: (items.dishImage != null &&
                                      items.dishImage!.isNotEmpty &&
                                      items.dishImage != "No Image" &&
                                      File(items.dishImage!).existsSync())
                                  ? Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        image: DecorationImage(
                                          image:
                                              FileImage(File(items.dishImage!)),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 255, 231, 224),
                                        borderRadius: BorderRadius.circular(50),
                                        image: const DecorationImage(
                                          image: AssetImage(
                                              'assets/icons/logo.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                              title: Text(items.menuName),
                              subtitle: Text(
                                'Nu. ${items.price}',
                                style: const TextStyle(
                                  color: Colors.green,
                                ),
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _showDeleteConfirmation(
                                  context,
                                  items.menuId,
                                  items.menuName,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                );
              }
              return Container();
            },
          ),
          // Custom Floating Action Buttons
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_showFetchButton)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        context.read<MenuApiBloc>().add(FetchMenuFromApi());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fetching menu from API...'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.sync,
                            color: Colors.white, size: 32),
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const AddNewItemPage();
                      },
                    ));
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
