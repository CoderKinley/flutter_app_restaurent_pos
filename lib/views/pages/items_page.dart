import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/add_item_menu_navigation/bloc/add_item_navigation_bloc.dart';
import 'package:pos_system_legphel/views/pages/Add Items/all_items_list.dart';
import 'package:pos_system_legphel/views/pages/Add Items/ip_address_page.dart';
import 'package:pos_system_legphel/views/pages/Add Items/items_category_list.dart';
import 'package:pos_system_legphel/views/pages/Add Items/sub_category_list.dart';
import 'package:pos_system_legphel/views/pages/Add Items/branch_settings_page.dart';
import 'package:pos_system_legphel/views/pages/Add Items/tax_settings_page.dart';
import 'package:pos_system_legphel/views/pages/Add Items/item_destination_list.dart';
import 'package:pos_system_legphel/views/pages/Add Items/database_management_page.dart';
import 'package:pos_system_legphel/views/widgets/drawer_menu_widget.dart';
import 'package:pos_system_legphel/models/settings/app_settings.dart';

class ItemsPage extends StatelessWidget {
  final List<Widget> rightScreens = [
    const AllItemsList(),
    const ItemsCategoryList(),
    const SubCategoryList(),
    const ItemDestinationList(),
    const IpAddressPage(),
    const TaxSettingsPage(),
    const BranchSettingsPage(),
    const DatabaseManagementPage(),
  ];

  ItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Row(
        children: [
          // Left side menu -------------------------------------->
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(2, 0),
                  )
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Top menu
                    Container(
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 3, 27, 48),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: _mainTopMenu(
                        action: Container(),
                      ),
                    ),
                    // container for The menu item list
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
                                _buildMenuItem(
                                  context,
                                  icon: Icons.list_alt_rounded,
                                  title: "Items",
                                  iconColor: Colors.blue.shade700,
                                  index: 0,
                                ),
                                const Divider(height: 1, color: Colors.black12),
                                _buildMenuItem(
                                  context,
                                  icon: Icons.category_rounded,
                                  title: "Categories",
                                  iconColor: Colors.green.shade700,
                                  index: 1,
                                ),
                                const Divider(height: 1, color: Colors.black12),
                                _buildMenuItem(
                                  context,
                                  icon: Icons.subdirectory_arrow_right_rounded,
                                  title: "Sub Categories",
                                  iconColor: Colors.purple.shade700,
                                  index: 2,
                                ),
                                const Divider(height: 1, color: Colors.black12),
                                _buildMenuItem(
                                  context,
                                  icon: Icons.location_on_rounded,
                                  title: "Item Destinations",
                                  iconColor: Colors.red.shade700,
                                  index: 3,
                                ),
                                const Divider(height: 1, color: Colors.black12),
                                _buildMenuItem(
                                  context,
                                  icon: Icons.request_quote_rounded,
                                  title: "Tax Settings",
                                  iconColor: Colors.orange.shade700,
                                  index: 5,
                                ),
                                const Divider(height: 1, color: Colors.black12),
                                FutureBuilder<bool>(
                                  future:
                                      AppSettings.getShowDatabaseManagement(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data == true) {
                                      return Column(
                                        children: [
                                          _buildMenuItem(
                                            context,
                                            icon: Icons.storage_rounded,
                                            title: "Export Data",
                                            iconColor: Colors.teal.shade700,
                                            index: 7,
                                          ),
                                          const Divider(
                                              height: 1, color: Colors.black12),
                                        ],
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
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
          // Right side content -------------------------------------->
          Expanded(
            flex: 14,
            child: Column(
              children: [
                // Custom Top Navigation
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 3, 27, 48),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "All Items",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content Area
                Expanded(
                  child: BlocBuilder<AddItemNavigationBloc,
                      AddItemNavigationState>(
                    builder: (context, state) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                        ),
                        child: rightScreens[state.selectedIndex],
                      );
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

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color iconColor,
    required int index,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        context.read<AddItemNavigationBloc>().add(SelectScreen(index));
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      minLeadingWidth: 10,
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
