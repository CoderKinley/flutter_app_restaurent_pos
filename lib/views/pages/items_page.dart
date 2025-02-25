import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/add_item_menu_navigation/bloc/add_item_navigation_bloc.dart';
import 'package:pos_system_legphel/views/pages/Add%20Items/all_items_list.dart';
import 'package:pos_system_legphel/views/pages/Add%20Items/items_category_list.dart';
import 'package:pos_system_legphel/views/widgets/drawer_menu_widget.dart';

class ItemsPage extends StatelessWidget {
  final List<Widget> rightScreens = [
    AllItemsList(),
    ItemsCategoryList(),
  ];

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
                  padding: const EdgeInsets.only(top: 10, bottom: 10, right: 0),
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
                                    .add(SelectScreen(0));
                              },
                            ),
                            Divider(),
                            ListTile(
                              leading: const Icon(
                                Icons.edit,
                              ),
                              title: const Text("Categories"),
                              onTap: () {
                                return context
                                    .read<AddItemNavigationBloc>()
                                    .add(SelectScreen(1));
                              },
                            ),
                            Divider(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

  Widget _topMenu({
    required String title,
    required String subTitle,
    required Widget action,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subTitle,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
          ],
        ),
        Expanded(flex: 1, child: Container(width: double.infinity)),
        Expanded(flex: 5, child: action),
      ],
    );
  }
}
// 
