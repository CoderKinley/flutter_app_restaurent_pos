import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/add_item_menu_navigation/bloc/add_item_navigation_bloc.dart';
import 'package:pos_system_legphel/views/pages/Add%20Items/add_new_table.dart';
import 'package:pos_system_legphel/views/pages/Add%20Items/all_items_list.dart';
import 'package:pos_system_legphel/views/pages/Add%20Items/ip_address_page.dart';
import 'package:pos_system_legphel/views/pages/Add%20Items/items_category_list.dart';
import 'package:pos_system_legphel/views/pages/Add%20Items/sub_category_list.dart';
import 'package:pos_system_legphel/views/widgets/drawer_menu_widget.dart';

class ItemsPage extends StatelessWidget {
  final List<Widget> rightScreens = [
    const AllItemsList(),
    const ItemsCategoryList(),
    const AddNewTable(),
    const SubCategoryList(),
    const IpAddressPage(),
  ];

  ItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 0,
        left: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // header ---------------------------------------------------->
                  Container(
                    padding: const EdgeInsets.only(right: 10),
                    height: 60,
                    color: const Color.fromARGB(255, 3, 27, 48),
                    child: _mainTopMenu(
                      action: Container(),
                    ),
                  ),
                  // contaier for The menu item list
                  Container(
                    height: 500,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 10, right: 0),
                    child: ListView(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.list,
                                ),
                                title: const Text("Items"),
                                onTap: () {
                                  return context
                                      .read<AddItemNavigationBloc>()
                                      .add(const SelectScreen(0));
                                },
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(
                                  Icons.edit,
                                ),
                                title: const Text("Categories"),
                                onTap: () {
                                  return context
                                      .read<AddItemNavigationBloc>()
                                      .add(const SelectScreen(1));
                                },
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(
                                  Icons.table_bar,
                                ),
                                title: const Text("Tables"),
                                onTap: () {
                                  return context
                                      .read<AddItemNavigationBloc>()
                                      .add(const SelectScreen(2));
                                },
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(
                                  Icons.category,
                                ),
                                title: const Text("Sub Categories"),
                                onTap: () {
                                  return context
                                      .read<AddItemNavigationBloc>()
                                      .add(const SelectScreen(3));
                                },
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(
                                  Icons.computer,
                                ),
                                title: const Text("Server IP"),
                                onTap: () {
                                  return context
                                      .read<AddItemNavigationBloc>()
                                      .add(const SelectScreen(4));
                                },
                              ),
                              const Divider(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // next item the right side menu -------------------------------------->
          Expanded(
            flex: 14,
            child: Column(
              children: [
                // Custom Top Navigation
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  height: 60,
                  color: Colors.grey,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "All Items",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Food Items List
                Expanded(
                  child: BlocBuilder<AddItemNavigationBloc,
                      AddItemNavigationState>(
                    builder: (context, state) {
                      return rightScreens[state.selectedIndex];
                    },
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
}
