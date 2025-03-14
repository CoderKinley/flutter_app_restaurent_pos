import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/category_bloc/bloc/cetagory_bloc.dart';
import 'package:pos_system_legphel/bloc/hold_order_bloc/bloc/hold_order_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_from_api/bloc/menu_from_api_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_item_bloc/bloc/menu_bloc.dart';
import 'package:pos_system_legphel/bloc/proceed_order_bloc/bloc/proceed_order_bloc.dart';
import 'package:pos_system_legphel/bloc/sub_category_bloc/bloc/sub_category_bloc.dart';
import 'package:pos_system_legphel/bloc/table_bloc/bloc/add_table_bloc.dart';
import 'package:pos_system_legphel/models/Menu%20Model/hold_order_model.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_bill_model.dart';
import 'package:pos_system_legphel/models/Menu%20Model/proceed_order_model.dart';
import 'package:pos_system_legphel/models/category_model.dart';
import 'package:pos_system_legphel/models/new_menu_model.dart';
import 'package:pos_system_legphel/views/pages/hold_order_page.dart';
import 'package:pos_system_legphel/views/pages/proceed%20page/proceed_pages.dart';
import 'package:pos_system_legphel/views/widgets/cart_item_widget.dart';
import 'package:pos_system_legphel/views/widgets/drawer_menu_widget.dart';
import 'package:uuid/uuid.dart';

// https://mobipos.com.au/resources/guide/cash-register/ordering-menu/

const List<String> list = <String>[
  'Takeout',
  'Dine in',
  'Delivery',
];

class SalesPage extends StatefulWidget {
  const SalesPage({
    super.key,
  });

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  String? selectedTableNumber = 'Table';
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  String? _selectedCategory;
  String? _selectSubCategory;
  int _expandedIndex = -1; // Keep track of the expanded tile index
  int _selectedSubcategoryIndex = -1;

  @override
  void initState() {
    super.initState();
    context.read<MenuBloc>().add(LoadMenuItems());
    context.read<TableBloc>().add(LoadTables());
    context.read<CategoryBloc>().add(LoadCategories());
    context.read<MenuBlocApi>().add(FetchMenuApi());
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.deepOrange;
      case 'pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
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
                  Container(
                    padding: const EdgeInsets.only(right: 2),
                    height: 60,
                    color: const Color.fromARGB(255, 3, 27, 48),
                    child: _mainTopMenu(action: Container()),
                  ),
                  Expanded(
                    // ← This is crucial for scrolling!
                    child: Container(
                      color: Colors.grey[200],
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: BlocBuilder<CategoryBloc, CategoryState>(
                          builder: (context, state) {
                            if (state is CategoryLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            // else if (state is CategoryLoaded) {
                            //   return ListView.separated(
                            //     physics:
                            //         const AlwaysScrollableScrollPhysics(), // Ensures scrolling
                            //     itemCount: state.categories.length + 1,
                            //     separatorBuilder: (_, __) =>
                            //         const SizedBox(height: 0),
                            //     itemBuilder: (context, index) {
                            //       if (index == 0) {
                            //         return _itemTab(
                            //           title: "All Categories",
                            //           isActive: _selectedCategory == null,
                            //           onTap: () {
                            //             setState(
                            //                 () => _selectedCategory = null);
                            //             context
                            //                 .read<ProductBloc>()
                            //                 .add(LoadProducts());
                            //           },
                            //         );
                            //       }

                            //       final category = state.categories[index - 1];
                            //       return Column(
                            //         children: [
                            //           InkWell(
                            //             onTap: () {
                            //               setState(() {
                            //                 if (_selectedCategory ==
                            //                     category.categoryName) {
                            //                   _selectedCategory =
                            //                       null; // Deactivate if same category
                            //                 } else {
                            //                   _selectedCategory = category
                            //                       .categoryName; // Activate category
                            //                 }
                            //               });
                            //               context.read<SubcategoryBloc>().add(
                            //                     LoadSubcategories(
                            //                         categoryId:
                            //                             category.categoryId),
                            //                   );
                            //             },
                            //             child: _itemTab(
                            //               title: category.categoryName,
                            //               isActive: _selectedCategory ==
                            //                   category.categoryName,
                            //               onTap: () {
                            //                 setState(() {
                            //                   _selectedCategory = category
                            //                       .categoryName; // Update selected category on tap
                            //                 });
                            //                 context.read<SubcategoryBloc>().add(
                            //                       LoadSubcategories(
                            //                           categoryId:
                            //                               category.categoryId),
                            //                     );
                            //               },
                            //             ),
                            //           ),
                            //           if (_selectedCategory ==
                            //               category.categoryName)
                            //             BlocBuilder<SubcategoryBloc,
                            //                 SubcategoryState>(
                            //               builder: (context, subcategoryState) {
                            //                 if (subcategoryState
                            //                     is SubcategoryLoading) {
                            //                   return const Center(
                            //                       child:
                            //                           CircularProgressIndicator());
                            //                 } else if (subcategoryState
                            //                     is SubcategoryLoaded) {
                            //                   return Padding(
                            //                     padding: const EdgeInsets.only(
                            //                         left:
                            //                             15.0), // Indentation for subcategories
                            //                     child: SingleChildScrollView(
                            //                       child: ExpansionPanelList(
                            //                         elevation: 1,
                            //                         expandedHeaderPadding:
                            //                             EdgeInsets.zero,
                            //                         children: subcategoryState
                            //                             .subcategories
                            //                             .map<ExpansionPanel>(
                            //                                 (subcategory) {
                            //                           return ExpansionPanel(
                            //                             headerBuilder: (context,
                            //                                 isExpanded) {
                            //                               return Padding(
                            //                                 padding:
                            //                                     const EdgeInsets
                            //                                         .all(16.0),
                            //                                 child: Text(
                            //                                   subcategory
                            //                                       .subcategoryName,
                            //                                   style:
                            //                                       const TextStyle(
                            //                                           fontSize:
                            //                                               14),
                            //                                 ),
                            //                               );
                            //                             },
                            //                             body: Padding(
                            //                               padding:
                            //                                   const EdgeInsets
                            //                                       .all(16.0),
                            //                               child: Text(
                            //                                   "Content for ${subcategory.subcategoryName}"), // Adjust with actual subcategory content
                            //                             ),
                            //                             isExpanded:
                            //                                 false, // Always collapsed (can toggle if needed)
                            //                           );
                            //                         }).toList(),
                            //                       ),
                            //                     ),
                            //                   );
                            //                 } else {
                            //                   return const Center(
                            //                       child: Text(
                            //                           "No subcategories available"));
                            //                 }
                            //               },
                            //             ),
                            //         ],
                            //       );
                            //     },
                            //   );
                            // }

                            else if (state is CategoryLoaded) {
                              final sortedCategories = List<CategoryModel>.from(
                                  state.categories)
                                ..sort((a, b) =>
                                    a.categoryName.compareTo(b.categoryName));

                              return ListView.builder(
                                itemCount: sortedCategories.length,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                itemBuilder: (context, index) {
                                  final category = sortedCategories[index];
                                  final isSelected = _expandedIndex == index;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.deepOrange.shade400
                                              : Colors.transparent,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ExpansionPanelList(
                                        elevation: 1,
                                        expandedHeaderPadding: EdgeInsets.zero,
                                        animationDuration:
                                            const Duration(milliseconds: 300),
                                        expansionCallback: (_, isExpanded) {
                                          setState(() {
                                            _selectSubCategory = null;
                                            _expandedIndex =
                                                _expandedIndex == index
                                                    ? -1
                                                    : index;
                                            _selectedCategory =
                                                category.categoryName;
                                            if (_expandedIndex == -1) {
                                              _selectedSubcategoryIndex = -1;
                                              _selectedCategory = null;
                                              _selectSubCategory = null;
                                            }

                                            if (category.categoryName ==
                                                "All") {
                                              _selectedCategory = null;
                                              _selectSubCategory = null;
                                            }
                                          });
                                        },
                                        children: [
                                          ExpansionPanel(
                                            isExpanded: isSelected,
                                            canTapOnHeader: true,
                                            backgroundColor: Colors.white,
                                            headerBuilder:
                                                (context, isExpanded) {
                                              return ListTile(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                leading: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Icon(
                                                    Icons.food_bank_rounded,
                                                    color: isSelected
                                                        ? Colors
                                                            .deepOrange.shade600
                                                        : Colors.deepOrange
                                                            .shade400,
                                                  ),
                                                ),
                                                title: Text(
                                                  category.categoryName,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: isSelected
                                                        ? Colors
                                                            .deepOrange.shade800
                                                        : null,
                                                  ),
                                                ),
                                              );
                                            },
                                            body: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(6),
                                                  bottomRight:
                                                      Radius.circular(6),
                                                ),
                                              ),
                                              child: BlocProvider(
                                                create: (_) => SubcategoryBloc()
                                                  ..add(LoadSubcategories(
                                                      categoryId:
                                                          category.categoryId)),
                                                child: BlocBuilder<
                                                    SubcategoryBloc,
                                                    SubcategoryState>(
                                                  builder: (context,
                                                      subcategoryState) {
                                                    if (subcategoryState
                                                        is SubcategoryLoading) {
                                                      return Center(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  16),
                                                          child:
                                                              CircularProgressIndicator(
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                    Color>(
                                                              Colors.deepOrange
                                                                  .shade300,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    if (subcategoryState
                                                        is SubcategoryError) {
                                                      return Center(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  16),
                                                          child: Text(
                                                            'Error: ${subcategoryState.errorMessage}',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    if (subcategoryState
                                                        is SubcategoryLoaded) {
                                                      final sortedSubcategories =
                                                          List<dynamic>.from(
                                                              subcategoryState
                                                                  .subcategories)
                                                            ..sort((a, b) => a
                                                                .subcategoryName
                                                                .compareTo(b
                                                                    .subcategoryName));

                                                      return Column(
                                                        children: [
                                                          for (int subIndex = 0;
                                                              subIndex <
                                                                  sortedSubcategories
                                                                      .length;
                                                              subIndex++)
                                                            ListTile(
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 16,
                                                              ),
                                                              leading: Icon(
                                                                Icons
                                                                    .subdirectory_arrow_right,
                                                                color: _selectedSubcategoryIndex ==
                                                                            subIndex &&
                                                                        _expandedIndex ==
                                                                            index
                                                                    ? Colors
                                                                        .deepOrange
                                                                        .shade500
                                                                    : Colors
                                                                        .deepOrange
                                                                        .shade300,
                                                                size: 20,
                                                              ),
                                                              title: Text(
                                                                sortedSubcategories[
                                                                        subIndex]
                                                                    .subcategoryName,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14,
                                                                  decoration: _selectedSubcategoryIndex ==
                                                                              subIndex &&
                                                                          _expandedIndex ==
                                                                              index
                                                                      ? TextDecoration
                                                                          .none
                                                                      : TextDecoration
                                                                          .none,
                                                                  decorationColor: Colors
                                                                      .deepOrange
                                                                      .shade400,
                                                                  decorationThickness:
                                                                      2,
                                                                  color: _selectedSubcategoryIndex ==
                                                                              subIndex &&
                                                                          _expandedIndex ==
                                                                              index
                                                                      ? Colors
                                                                          .deepOrange
                                                                          .shade700
                                                                      : null,
                                                                ),
                                                              ),
                                                              trailing: Icon(
                                                                Icons
                                                                    .chevron_right,
                                                                size: 20,
                                                                color: _selectedSubcategoryIndex ==
                                                                            subIndex &&
                                                                        _expandedIndex ==
                                                                            index
                                                                    ? Colors
                                                                        .deepOrange
                                                                        .shade400
                                                                    : null,
                                                              ),
                                                              onTap: () {
                                                                setState(() {
                                                                  _selectedSubcategoryIndex =
                                                                      subIndex;
                                                                  _selectSubCategory =
                                                                      sortedSubcategories[
                                                                              subIndex]
                                                                          .subcategoryName;
                                                                });
                                                              },
                                                            ),
                                                          SizedBox(height: 8),
                                                        ],
                                                      );
                                                    }
                                                    return Container();
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return const Center(
                                  child: Text("No categories available 🎈"));
                            }
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 10,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                        right: 10, left: 10, top: 5, bottom: 5),
                    height: 60,
                    color: const Color.fromARGB(255, 3, 27, 48),
                    child: Expanded(flex: 5, child: Container()),
                  ),
                  Expanded(
                    child: BlocBuilder<MenuBlocApi, MenuApiState>(
                      builder: (context, state) {
                        if (state is MenuApiLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is MenuApiLoaded) {
                          final filteredMenuItems = state.menuItems
                              .where((menuItem) =>
                                  _selectedCategory == null ||
                                  menuItem.menuType == _selectedCategory)
                              .where((menuItem) =>
                                  _selectSubCategory == null ||
                                  menuItem.subMenuType == _selectSubCategory)
                              .toList();

                          return GridView.builder(
                            padding: const EdgeInsets.only(
                              top: 0,
                              left: 8,
                              right: 8,
                              bottom: 8,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: (1 / 1.4),
                            ),
                            itemCount: filteredMenuItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredMenuItems[index];
                              return _item(
                                product: item,
                                context: context,
                              );
                            },
                          );
                        } else {
                          return const Center(
                              child: Text("Something went wrong!"));
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
            // next item the right side menu------------------------------------------->
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    height: 60,
                    color: Colors.grey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Bill",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // const DropdownButtonExample(),
                        Row(
                          children: [
                            BlocBuilder<TableBloc, TableState>(
                              builder: (context, state) {
                                if (state is TableLoading) {
                                  return const CircularProgressIndicator();
                                } else if (state is TableError) {
                                  return Text('Error: ${state.errorMessage}');
                                } else if (state is TableLoaded) {
                                  return DropdownButton<String>(
                                    value: selectedTableNumber ?? 'Table',
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          selectedTableNumber = newValue;
                                        });
                                      }
                                    },
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: 'Table',
                                        child: Text('Table'),
                                      ),
                                      ...state.tables
                                          .map<DropdownMenuItem<String>>(
                                              (table) {
                                        return DropdownMenuItem<String>(
                                          value: table.tableNumber.toString(),
                                          child: Text(
                                            'Table ${table.tableNumber}',
                                          ),
                                        );
                                      }),
                                    ],
                                    underline:
                                        Container(), // Remove the underline
                                  );
                                }
                                return Container();
                              },
                            ),
                            IconButton(
                              onPressed: () {
                                return _showAddPersonDialog();
                              },
                              icon: const Icon(Icons.person_add),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return const HoldOrderPage(menuItems: []);
                                  },
                                ));
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'View Hold Order',
                                  child: Text('View Hold Order'),
                                ),
                              ],
                              child: const IconButton(
                                onPressed: null,
                                icon: Icon(Icons.more_vert),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  // Food Items List-------------------------------------------------------------------------------------->
                  Expanded(
                    flex: 1,
                    child: BlocBuilder<MenuBloc, MenuState>(
                      builder: (context, state) {
                        if (state is MenuLoaded) {
                          // Reverse the list to show the latest added item at the top
                          final reversedCartItems =
                              state.cartItems.reversed.toList();

                          return Container(
                            padding: const EdgeInsets.only(left: 10, top: 15),
                            color: Colors.grey[200],
                            child: Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: reversedCartItems
                                        .length, // Use the reversed list
                                    itemBuilder: (context, index) {
                                      final cartItem = reversedCartItems[index];
                                      return CartItemWidget(cartItem: cartItem);
                                    },
                                  ),
                                ),
                                const SizedBox(
                                    height: 10), // Spacing for better UI
                                summarySection(
                                  context,
                                  state.totalAmount,
                                  state.cartItems,
                                  selectedTableNumber!,
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPersonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Person"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contactController,
                  decoration:
                      const InputDecoration(labelText: "Contact Number"),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                String name = nameController.text;
                String contact = contactController.text;

                print("Added: Name - $name, Contact - $contact");

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _item({
    required MenuModel product,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: () {
        context
            .read<MenuBloc>()
            .add(AddToCart(product)); // Use the MenuItem object
      },
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      width: 120,
                      decoration: BoxDecoration(
                        // Optional: Add a border radius if needed
                        borderRadius: BorderRadius.circular(16),

                        // Use the asset image directly
                        image: const DecorationImage(
                          image: AssetImage(
                              'assets/icons/logo.png'), // Directly use the logo image from assets
                          fit: BoxFit
                              .cover, // Adjust the box fit (you can change this as needed)
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.menuName.length > 28
                          ? '${product.menuName.substring(0, 28)}...'
                          : product.menuName, // Use MenuItem's name
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nu. ${product.price}', // Use MenuItem's price
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // widght for the main top menu bar
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

  // widget for the Search bar at the top
  Widget _search() {
    return TextField(
      style: const TextStyle(),
      decoration: InputDecoration(
        filled: true,
        prefixIcon: const Icon(
          Icons.search,
        ),
        hintText: 'Search menu here...',
        hintStyle: const TextStyle(fontSize: 11),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Widget for a food item
  Widget foodItem(
    String qty,
    String name,
    double price,
    double? oldPrice, {
    double? tax = 20,
    String? subtitle,
    bool showDiscount = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(right: 10, bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  qty,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Nu. $price",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (oldPrice != null)
                      Text(
                        "Nu. $oldPrice",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                const Icon(Icons.close),
              ],
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            if (showDiscount) quantityDiscountInput(),
          ],
        ),
      ),
    );
  }

  // Widget for Quantity & Discount Input Fields
  Widget quantityDiscountInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: Row(
          children: [
            SizedBox(
              width: 150, // Set width
              height: 40, // Set height
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Quantity",
                  labelStyle: const TextStyle(
                    fontSize: 10,
                  ), // Change text size
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 10,
                ), // Change input text size
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 150, // Set width
              height: 40, // Set height
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Discount (%)",
                  labelStyle: const TextStyle(
                    fontSize: 10,
                  ), // Change text size
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 10,
                ), // Change input text size
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget summarySection(
    BuildContext context,
    double totalAmount,
    List<MenuBillModel> cartItems,
    String tableNumber, {
    num? tax = 0.2,
  }) {
    double payableAmount =
        totalAmount + ((totalAmount * tax!)); // Add tax to total amount
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtotal Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Subtotal"),
              Text("Nu. ${totalAmount.toStringAsFixed(2)}"), // Dynamic subtotal
            ],
          ),
          // Tax Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("B.S.T 10%"),
              Text(
                  "Nu. ${(totalAmount * 0.1).toStringAsFixed(2)}"), // Dynamic tax
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Service 10%"),
              Text(
                  "Nu. ${(totalAmount * 0.1).toStringAsFixed(2)}"), // Dynamic tax
            ],
          ),

          const Divider(),
          // Payable Amount Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Payable Amount",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                "Nu. ${payableAmount.toStringAsFixed(2)}", // Updated payable amount
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Buttons Row for Hold Order and Proceed
          Row(
            children: [
              BlocBuilder<MenuBloc, MenuState>(
                builder: (context, state) {
                  if (state is MenuLoaded && state.cartItems.isNotEmpty) {
                    // If cart has items, show "Hold Order" button
                    return Expanded(
                      child: orderButton(
                        "Hold Order",
                        const Color(0xFFFFDAB9), // Peach,
                        HoldOrderPage(menuItems: state.cartItems),
                        () {
                          const uuid = Uuid();
                          final holdItems = HoldOrderModel(
                            holdOrderId: uuid.v4(),
                            tableNumber: tableNumber,
                            customerName: nameController.text,
                            orderDateTime: DateTime.now(),
                            menuItems: state.cartItems,
                          );

                          context
                              .read<HoldOrderBloc>()
                              .add(AddHoldOrder(holdItems));
                          context.read<MenuBloc>().add(RemoveAllFromCart());
                        },
                      ),
                    );
                  } else {
                    return Expanded(
                      child: orderButton(
                        "View Hold Order",
                        const Color.fromARGB(255, 3, 27, 48),
                        const HoldOrderPage(menuItems: []), // Empty cart
                        () {},
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BlocBuilder<MenuBloc, MenuState>(
                  builder: (context, state) {
                    bool isEnabled =
                        state is MenuLoaded && state.cartItems.isNotEmpty;

                    return Opacity(
                      opacity: isEnabled ? 1.0 : 0.4,
                      child: AbsorbPointer(
                        absorbing:
                            !isEnabled, // Disable button clicks if no items
                        child: orderButton(
                          "Proceed",
                          const Color.fromARGB(
                              255, 101, 221, 159), // Seafoam Green

                          ProceedPages(
                            items: isEnabled ? state.cartItems : [],
                            branchName: "Legphel Hotel",
                            customername: nameController.text,
                            tableNumber: tableNumber,
                            phoneNumber: "+975-${contactController.text}",
                            orderID: const Uuid().v4(),
                            totalCostWithTax:
                                (totalAmount + (totalAmount * 0.2)),
                          ),
                          () {
                            const uuid = Uuid();
                            final proceedOrderItems = ProceedOrderModel(
                              holdOrderId: uuid.v4().toString(),
                              tableNumber: tableNumber,
                              customerName: nameController.text.toString(),
                              phoneNumber:
                                  "+975-${contactController.text.toString()}",
                              restaurantBranchName:
                                  "Branch ${Random().nextInt(10)}",
                              orderDateTime: DateTime.now(),
                              menuItems: cartItems,
                            );

                            // aDD THE PROCESSED ORDR TO THE WHATEVER PAGE IT IS THERE
                            context
                                .read<ProceedOrderBloc>()
                                .add(AddProceedOrder(proceedOrderItems));

                            // removed the menu items form the previous page
                            context.read<MenuBloc>().add(RemoveAllFromCart());
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Button Widget
  Widget orderButton(
      String text, Color color, Widget newPage, Function onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.deepOrange,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        onPressed();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return newPage;
            },
          ),
        );
      },
      child: Text(text, style: const TextStyle(fontSize: 10)),
    );
  }
}
