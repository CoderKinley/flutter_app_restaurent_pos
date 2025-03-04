import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/hold_order_bloc/bloc/hold_order_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_item_bloc/bloc/menu_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_item_local_bloc/bloc/menu_items_bloc.dart';
import 'package:pos_system_legphel/bloc/proceed_order_bloc/bloc/proceed_order_bloc.dart';
import 'package:pos_system_legphel/models/Menu%20Model/hold_order_model.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_bill_model.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_items_model_local_stg.dart';
import 'package:pos_system_legphel/models/Menu%20Model/proceed_order_model.dart';
import 'package:pos_system_legphel/views/pages/hold_order_page.dart';
import 'package:pos_system_legphel/views/pages/proceed_pages.dart';
import 'package:pos_system_legphel/views/widgets/cart_item_widget.dart';
import 'package:pos_system_legphel/views/widgets/drawer_menu_widget.dart';
import 'package:uuid/uuid.dart';

const List<String> list = <String>[
  'Takeout',
  'Dine in',
  'Delivery',
];

class SalesPage extends StatefulWidget {
  final HoldOrderModel? hold_order_model;

  const SalesPage({
    super.key,
    this.hold_order_model,
  });

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  @override
  void initState() {
    super.initState();
    context.read<MenuBloc>().add(LoadMenuItems());

    if (widget.hold_order_model != null) {
      print("I am not null!!!");
      print(widget.hold_order_model?.menuItems[0].product.name);
    } else {
      print("null product");
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
              flex: 10,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(right: 10),
                    height: 60,
                    color: const Color.fromARGB(255, 3, 27, 48),
                    child: _mainTopMenu(
                      action: _search(),
                    ),
                  ),
                  // contaier for The menu item list
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    height: 70,
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 10, right: 0),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _itemTab(
                          icon: 'assets/icons/icon-burger.png',
                          title: 'Burger',
                          isActive: true,
                        ),
                        _itemTab(
                          icon: 'assets/icons/icon-noodles.png',
                          title: 'Noodles',
                          isActive: false,
                        ),
                        _itemTab(
                          icon: 'assets/icons/icon-drinks.png',
                          title: 'Bevarages',
                          isActive: false,
                        ),
                        _itemTab(
                          icon: 'assets/icons/icon-desserts.png',
                          title: 'Desserts',
                          isActive: false,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, state) {
                        if (state is ProductLoading) {
                          return const Center(
                              child:
                                  CircularProgressIndicator()); // Show loader for MenuInitial & MenuLoading
                        } else if (state is ProductLoaded) {
                          return GridView.builder(
                            padding: const EdgeInsets.only(
                              top: 0,
                              left: 8,
                              right: 8,
                              bottom: 8,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: (1 / 1.4),
                            ),
                            itemCount: state.products.length,
                            itemBuilder: (context, index) {
                              final item = state.products[index];
                              return _item(
                                product: item, // Pass MenuItem directly
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
                  ),
                ],
              ),
            ),
            // next item the right side menu
            Expanded(
              flex: 6,
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
                          "Bill",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // const DropdownButtonExample(),
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
                  // Food Items List-------------------------------------------------------------------------------------->
                  Expanded(
                    flex: 1,
                    child: BlocBuilder<MenuBloc, MenuState>(
                      builder: (context, state) {
                        // Wehat if I UPdate the MenuBLoc TO have onley the items that i want to have and let
                        // load the only item there in the MenuBLoC
                        // The Code below is to load the Data on the Page Loading
                        if (widget.hold_order_model != null) {
                          // Load Hold Order Data - it does have the MenubillModel in it
                          // what if I fetch data from the local database into here
                          // so it should be matching the ID when fetching a particular data
                          // and then i can update the data
                          return Container(
                            padding: const EdgeInsets.only(left: 10, top: 15),
                            color: Colors.grey[200],
                            child: Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: widget.hold_order_model
                                            ?.menuItems.length ??
                                        0,
                                    itemBuilder: (context, index) {
                                      final cartItem = widget
                                          .hold_order_model?.menuItems[index];
                                      return cartItem != null
                                          ? CartItemWidget(cartItem: cartItem)
                                          : SizedBox();
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),
                                summarySection(
                                    context,
                                    widget.hold_order_model!.totalPrice,
                                    widget.hold_order_model!.menuItems),
                              ],
                            ),
                          );
                        } else if (state is MenuLoaded) {
                          return Container(
                            padding: const EdgeInsets.only(left: 10, top: 15),
                            color: Colors.grey[200],
                            child: Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: state.cartItems.length,
                                    itemBuilder: (context, index) {
                                      final cartItem = state.cartItems[index];
                                      return CartItemWidget(cartItem: cartItem);
                                    },
                                  ),
                                ),
                                const SizedBox(
                                    height: 10), // Spacing for better UI
                                summarySection(context, state.totalAmount,
                                    state.cartItems),
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

  Widget _item({
    // required MenuItem item, // Accept a MenuItem instead of Map<String, dynamic>
    required Product product,
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
                      height: 100,
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: product.image.isNotEmpty
                              ? FileImage(File(
                                  product.image)) // Load the image if available
                              : const AssetImage(
                                  'assets/placeholder_image.png'), // Use a placeholder if no image
                          fit: BoxFit
                              .cover, // Optionally, control how the image fits
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.name, // Use MenuItem's name
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
                    'Nu. ${product.price.toStringAsFixed(2)}', // Use MenuItem's price
                    style: const TextStyle(
                      fontSize: 12,
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

  // widget for the item list tab
  Widget _itemTab({
    required String icon,
    required String title,
    required bool isActive,
  }) {
    return Card(
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: isActive
              ? Border.all(color: Colors.deepOrangeAccent, width: 3)
              : Border.all(color: Colors.transparent, width: 3),
        ),
        child: Row(
          children: [
            Image.asset(
              icon,
              width: 38,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
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
    double? tax = 45,
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

  // widget for the summary section
  // add to hold order the menubill model list you know
  // how to achieve that dumbass??
  Widget summarySection(
    BuildContext context,
    double totalAmount,
    List<MenuBillModel> cartItems, {
    double? tax = 45,
  }) {
    double payableAmount = totalAmount + (tax ?? 0); // Add tax to total amount
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
              const Text("Tax"),
              Text("Nu. ${tax?.toStringAsFixed(2) ?? '0.00'}"), // Dynamic tax
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
              Expanded(
                child: orderButton(
                  "Hold Order",
                  Colors.orange,
                  HoldOrderPage(
                    menuItems: cartItems,
                  ),
                  () {
                    final uuid = Uuid();
                    final holdItems = HoldOrderModel(
                      holdOrderId: uuid.v4(), // Generates a unique UUID
                      tableNumber: Random().nextInt(100).toString(),
                      customerName: "Customer ${Random().nextInt(100)}",
                      orderDateTime: DateTime.now(),
                      menuItems: cartItems,
                    );
                    return context
                        .read<HoldOrderBloc>()
                        .add(AddHoldOrder(holdItems));
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: orderButton(
                    "Proceed", Colors.green, ProceedPages(items: cartItems),
                    () {
                  final uuid = Uuid();
                  final proceed_order_items = ProceedOrderModel(
                    holdOrderId: uuid.v4(), // Generates a unique UUID
                    tableNumber: Random().nextInt(100).toString(),
                    customerName: "Customer ${Random().nextInt(100)}",
                    phoneNumber:
                        "+975${Random().nextInt(9000000) + 1000000}", // Generates a random phone number
                    restaurantBranchName: "Branch ${Random().nextInt(10)}",
                    orderDateTime: DateTime.now(),
                    menuItems: cartItems,
                  );
                  return context
                      .read<ProceedOrderBloc>()
                      .add(AddProceedOrder(proceed_order_items));
                }),
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
