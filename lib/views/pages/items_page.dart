import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/add_item_menu_navigation/bloc/add_item_navigation_bloc.dart';
import 'package:pos_system_legphel/views/pages/Add Items/all_items_list.dart';
import 'package:pos_system_legphel/views/pages/Add Items/ip_address_page.dart';
import 'package:pos_system_legphel/views/pages/Add Items/items_category_list.dart';
import 'package:pos_system_legphel/views/pages/Add Items/sub_category_list.dart';
import 'package:pos_system_legphel/views/pages/Add Items/branch_settings_page.dart';
import 'package:pos_system_legphel/views/pages/Add Items/tax_settings_page.dart';
import 'package:pos_system_legphel/views/widgets/drawer_menu_widget.dart';

class ItemsPage extends StatelessWidget {
  final List<Widget> rightScreens = [
    const AllItemsList(),
    const ItemsCategoryList(),
    const SubCategoryList(),
    const IpAddressPage(),
    const TaxSettingsPage(),
    const BranchSettingsPage(),
  ];

  ItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 0,
        left: 0,
        top: 0,
        bottom: 0,
      ),
      child: Row(
        children: [
          // Left side menu -------------------------------------->
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Top menu
                    Container(
                      height: 60,
                      color: Colors.grey,
                      child: _mainTopMenu(
                        action: Container(),
                      ),
                    ),
                    // contaier for The menu item list
                    Container(
                      height: 600,
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
                                    Icons.category,
                                  ),
                                  title: const Text("Sub Categories"),
                                  onTap: () {
                                    return context
                                        .read<AddItemNavigationBloc>()
                                        .add(const SelectScreen(2));
                                  },
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(
                                    Icons.request_quote,
                                  ),
                                  title: const Text("Tax Settings"),
                                  onTap: () {
                                    return context
                                        .read<AddItemNavigationBloc>()
                                        .add(const SelectScreen(4));
                                  },
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(
                                    Icons.business,
                                  ),
                                  title: const Text("Branch Settings"),
                                  onTap: () {
                                    return context
                                        .read<AddItemNavigationBloc>()
                                        .add(const SelectScreen(5));
                                  },
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(
                                    Icons.computer,
                                  ),
                                  title: const Text("Printer IP"),
                                  onTap: () {
                                    return context
                                        .read<AddItemNavigationBloc>()
                                        .add(const SelectScreen(3));
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
