import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos_system_legphel/bloc/branch_bloc/bloc/branch_bloc.dart';
import 'package:pos_system_legphel/bloc/category_bloc/bloc/cetagory_bloc.dart';
import 'package:pos_system_legphel/bloc/customer_info_order_bloc/bloc/customer_info_order_bloc.dart';
import 'package:pos_system_legphel/bloc/hold_order_bloc/bloc/hold_order_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_from_api/bloc/menu_from_api_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_item_bloc/bloc/menu_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_print_bloc/bloc/menu_print_bloc.dart';
import 'package:pos_system_legphel/bloc/proceed_order_bloc/bloc/proceed_order_bloc.dart';
import 'package:pos_system_legphel/bloc/sub_category_bloc/bloc/sub_category_bloc.dart';
import 'package:pos_system_legphel/bloc/table_bloc/bloc/add_table_bloc.dart';
import 'package:pos_system_legphel/bloc/tables%20and%20names/bloc/customer_info_bloc.dart';
import 'package:pos_system_legphel/models/Menu%20Model/hold_order_model.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_bill_model.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_print_model.dart';
import 'package:pos_system_legphel/models/Menu%20Model/proceed_order_model.dart';
import 'package:pos_system_legphel/models/others/category_model.dart';
import 'package:pos_system_legphel/models/others/new_menu_model.dart';
import 'package:pos_system_legphel/models/tables%20and%20names/customer_info_model.dart';
import 'package:pos_system_legphel/views/pages/Hold%20Order/hold_order_page.dart';
import 'package:pos_system_legphel/views/pages/Hold%20Order/hold_order_ticket.dart';
import 'package:pos_system_legphel/views/pages/proceed%20page/proceed_pages.dart';
import 'package:pos_system_legphel/views/widgets/cart_item_widget.dart';
import 'package:pos_system_legphel/views/widgets/drawer_menu_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_system_legphel/bloc/tax_settings_bloc/bloc/tax_settings_bloc.dart';
import 'package:pos_system_legphel/views/widgets/menu_search_widget.dart';
import 'package:pos_system_legphel/services/category_order_service.dart';

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
  String? reSelectTableNumber = '';
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  String? _selectedCategory;
  String? _selectSubCategory;
  int _expandedIndex = -1; // Keep track of the expanded tile index
  int _selectedSubcategoryIndex = -1;
  // Get existing customer info if present, else default to empty values
  String existingName = '';
  String existingContact = '';
  static const int INITIAL_COUNTER = 1000;
  int _orderCounter = INITIAL_COUNTER;
  static const int PERMANENT_COUNTER_KEY =
      1000; // Initial value for permanent counter
  int _permanentOrderCounter = PERMANENT_COUNTER_KEY;
  String savedOrderNumber = '';

  // Add state variables for tax checkboxes
  bool _applyBst = true;
  bool _applyServiceCharge = true;
  static const String _applyBstKey = 'apply_bst';
  static const String _applyServiceChargeKey = 'apply_service_charge';
  static const String _enablePrintKey = 'enable_print';

  // Add state for filtered menu items
  List<MenuModel> _filteredMenuItems = [];

  bool _enablePrint = true;

  List<CategoryModel> _orderedCategories = [];
  bool _isDragging = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadTaxCheckboxStates();
    _loadPrintOptionState();
  }

  Future<void> _initializeData() async {
    await _loadOrderCounter();
    await _loadPermanentOrderCounter();
    await _loadCategoryOrder(); // Load category order first
    if (mounted) {
      context.read<MenuBloc>().add(LoadMenuItems());
      context.read<MenuPrintBloc>().add(const LoadMenuPrintItems());
      context.read<TableBloc>().add(LoadTables());
      context.read<CategoryBloc>().add(LoadCategories());
      context.read<MenuApiBloc>().add(FetchMenuApi());
      context.read<TaxSettingsBloc>().add(LoadTaxSettings());
      context.read<BranchBloc>().add(LoadBranch());
    }
  }

  Future<void> _loadOrderCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCounter = prefs.getInt('orderCounter');
      final savedOrderNumber = prefs.getString('orderNumberFinal');
      if (mounted) {
        setState(() {
          _orderCounter = savedCounter ?? INITIAL_COUNTER;
        });
        print('Loaded order counter: $_orderCounter');
      }
    } catch (e) {
      print('Error loading order counter: $e');
      if (mounted) {
        setState(() {
          _orderCounter = INITIAL_COUNTER;
        });
      }
    }
  }

  Future<void> _saveOrderCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('orderCounter', _orderCounter);
      await prefs.setString('orderNumberFinal', savedOrderNumber);
      print('Saved order counter: $_orderCounter');
      print('Saved order counter: $savedOrderNumber');
    } catch (e) {
      print('Error saving order counter: $e');
    }
  }

  Future<void> _incrementOrderCounter() async {
    setState(() {
      _orderCounter++;
    });
    await _saveOrderCounter();
  }

  Future<void> _loadPermanentOrderCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCounter = prefs.getInt('permanentOrderCounter');

      if (mounted) {
        setState(() {
          _permanentOrderCounter = savedCounter ?? PERMANENT_COUNTER_KEY;
        });
        print('Loaded permanent order counter: $_permanentOrderCounter');
      }
    } catch (e) {
      print('Error loading permanent order counter: $e');
      if (mounted) {
        setState(() {
          _permanentOrderCounter = PERMANENT_COUNTER_KEY;
        });
      }
    }
  }

  Future<void> _savePermanentOrderCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('permanentOrderCounter', _permanentOrderCounter);
      print('Saved permanent order counter: $_permanentOrderCounter');
    } catch (e) {
      print('Error saving permanent order counter: $e');
    }
  }

  Future<void> _incrementPermanentOrderCounter() async {
    setState(() {
      _permanentOrderCounter++;
    });
    await _savePermanentOrderCounter();
  }

  Future<void> _loadTaxCheckboxStates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _applyBst = prefs.getBool(_applyBstKey) ?? true;
      _applyServiceCharge = prefs.getBool(_applyServiceChargeKey) ?? true;
    });
  }

  Future<void> _saveTaxCheckboxStates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_applyBstKey, _applyBst);
    await prefs.setBool(_applyServiceChargeKey, _applyServiceCharge);
  }

  Future<void> _loadPrintOptionState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enablePrint = prefs.getBool(_enablePrintKey) ?? true;
    });
  }

  Future<void> _savePrintOptionState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enablePrintKey, _enablePrint);
  }

  // Used to see the change in dependencies automatically updating the UserInformation widget
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Add a listener to update local variables when CustomerInfoOrderBloc state changes
    final customerInfoBloc = context.read<CustomerInfoOrderBloc>();
    customerInfoBloc.stream.listen((state) {
      if (state is CustomerInfoOrderLoaded) {
        setState(() {
          existingName = state.customerInfo.name;
          existingContact = state.customerInfo.contact;
          if (state.customerInfo.tableNo.isNotEmpty) {
            reSelectTableNumber = state.customerInfo.tableNo;
            selectedTableNumber = state.customerInfo.tableNo;
          }
          // Make sure we update both table variables
          if (state.customerInfo.tableNo.isNotEmpty &&
              state.customerInfo.tableNo != 'Table') {
            reSelectTableNumber = state.customerInfo.tableNo;
            selectedTableNumber = state.customerInfo.tableNo;
          }
          // Update the controllers
          nameController.text = existingName;
          contactController.text = existingContact;

          // Handle order number
          if (state.customerInfo.orderNumber.isNotEmpty) {
            // _orderCounter = int.parse(state.customerInfo.orderNumber);
            List<String> parts = state.customerInfo.orderNumber.split('-');
            _orderCounter = int.parse(parts.last);
            savedOrderNumber = state.customerInfo.orderNumber;
          }
        });
      }
    });
  }

  Future<void> _loadCategoryOrder() async {
    final savedOrder = await CategoryOrderService.getCategoryOrder();
    if (mounted) {
      setState(() {
        if (savedOrder.isNotEmpty) {
          // Get the current categories from the bloc
          final categoryState = context.read<CategoryBloc>().state;
          if (categoryState is CategoryLoaded) {
            // Apply the saved order to the categories
            _orderedCategories = _applySavedOrder(
              List<CategoryModel>.from(categoryState.categories),
              savedOrder,
            );
          }
        }
        _isInitialized = true;
      });
    }
  }

  List<CategoryModel> _applySavedOrder(
      List<CategoryModel> categories, List<String> savedOrder) {
    if (savedOrder.isEmpty) return categories;

    // Create a map for quick lookup
    final categoryMap = {for (var c in categories) c.categoryId: c};

    // First add categories in saved order
    final orderedCategories = savedOrder
        .map((id) => categoryMap[id])
        .where((c) => c != null)
        .cast<CategoryModel>()
        .toList();

    // Then add any new categories that weren't in the saved order
    final newCategories =
        categories.where((c) => !savedOrder.contains(c.categoryId)).toList();

    return [...orderedCategories, ...newCategories];
  }

  Future<void> _saveCategoryOrder() async {
    if (_orderedCategories.isNotEmpty) {
      final categoryIds = _orderedCategories.map((c) => c.categoryId).toList();
      await CategoryOrderService.saveCategoryOrder(categoryIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    // listen to customerInfoOrderBLoc state changes
    final customerInfoState = context.watch<CustomerInfoOrderBloc>().state;

    // Update local variables if there's customer info
    if (customerInfoState is CustomerInfoOrderLoaded) {
      existingName = customerInfoState.customerInfo.name;
      existingContact = customerInfoState.customerInfo.contact;
      if (customerInfoState.customerInfo.tableNo.isNotEmpty) {
        reSelectTableNumber = customerInfoState.customerInfo.tableNo;
        selectedTableNumber = customerInfoState.customerInfo.tableNo;
      }
    }
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(0.00),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(right: 0),
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
                            } else if (state is CategoryLoaded) {
                              List<CategoryModel> categoriesToDisplay;

                              if (_isInitialized &&
                                  _orderedCategories.isNotEmpty) {
                                // Use the ordered categories if we have them
                                categoriesToDisplay = _orderedCategories;
                              } else {
                                // Use the default order for first load
                                categoriesToDisplay = List<CategoryModel>.from(
                                    state.categories)
                                  ..sort((a, b) =>
                                      a.categoryName.compareTo(b.categoryName));

                                // Initialize ordered categories
                                if (!_isInitialized) {
                                  _orderedCategories =
                                      List.from(categoriesToDisplay);
                                  _isInitialized = true;
                                }
                              }

                              return ReorderableListView.builder(
                                itemCount: categoriesToDisplay.length,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                onReorderStart: (index) {
                                  setState(() {
                                    _isDragging = true;
                                  });
                                },
                                onReorderEnd: (index) {
                                  setState(() {
                                    _isDragging = false;
                                    _orderedCategories =
                                        List.from(categoriesToDisplay);
                                    _saveCategoryOrder();
                                  });
                                },
                                onReorder: (oldIndex, newIndex) {
                                  setState(() {
                                    if (oldIndex < newIndex) {
                                      newIndex -= 1;
                                    }
                                    final item =
                                        categoriesToDisplay.removeAt(oldIndex);
                                    categoriesToDisplay.insert(newIndex, item);
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final category = categoriesToDisplay[index];
                                  final isSelected = _expandedIndex == index;

                                  return Padding(
                                    key: ValueKey(category.categoryId),
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.deepOrange.shade400
                                              : Colors.transparent,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
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
                                                trailing: _isDragging
                                                    ? const Icon(
                                                        Icons.drag_handle)
                                                    : null,
                                              );
                                            },
                                            body: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius:
                                                    const BorderRadius.only(
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
                                                              const EdgeInsets
                                                                  .all(16),
                                                          child:
                                                              CircularProgressIndicator(
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                        Color>(
                                                                    Colors
                                                                        .deepOrange
                                                                        .shade300),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    if (subcategoryState
                                                        is SubcategoryError) {
                                                      return Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16),
                                                          child: Text(
                                                            'Error: ${subcategoryState.errorMessage}',
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .red),
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
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          16),
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
                                                          const SizedBox(
                                                              height: 8),
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
                    child: Row(
                      children: [
                        Expanded(
                          child: BlocBuilder<MenuApiBloc, MenuApiState>(
                            builder: (context, state) {
                              if (state is MenuApiLoaded) {
                                return MenuSearchWidget(
                                  menuItems: state.menuItems,
                                  onSearchResults: (filteredItems) {
                                    setState(() {
                                      _filteredMenuItems = filteredItems;
                                    });
                                  },
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<MenuApiBloc, MenuApiState>(
                      builder: (context, state) {
                        if (state is MenuApiLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is MenuApiLoaded) {
                          final itemsToDisplay = _filteredMenuItems.isEmpty
                              ? state.menuItems
                              : _filteredMenuItems;

                          final filteredMenuItems = itemsToDisplay
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
                        } else if (state is MenuApiError) {
                          return Center(child: Text("Error: ${state.message}"));
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
            // Right side menu------------------------------------------->
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    height: 60,
                    color: Colors.green[200],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Bill",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Table Selection Dropdown
                            BlocBuilder<TableBloc, TableState>(
                              builder: (context, state) {
                                if (state is TableLoaded) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                      color:
                                          const Color.fromARGB(255, 3, 27, 48)
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color:
                                            const Color.fromARGB(255, 3, 27, 48)
                                                .withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: DropdownButton<String>(
                                      value: selectedTableNumber,
                                      underline: const SizedBox(),
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: selectedTableNumber == 'Table'
                                            ? const Color.fromARGB(
                                                255, 29, 29, 29)
                                            : const Color.fromARGB(
                                                255, 3, 27, 48),
                                        size: 20,
                                      ),
                                      style: TextStyle(
                                        color: selectedTableNumber == 'Table'
                                            ? const Color.fromARGB(
                                                255, 26, 26, 26)
                                            : const Color.fromARGB(
                                                255, 3, 27, 48),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      dropdownColor: const Color.fromARGB(
                                          255, 248, 248, 248),
                                      items: [
                                        DropdownMenuItem(
                                          value: 'Table',
                                          child: Text(
                                            'Select Table',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        ...state.tables.map((table) {
                                          return DropdownMenuItem(
                                            value: table.tableNumber,
                                            child: Text(
                                              table.tableName != null &&
                                                      table
                                                          .tableName!.isNotEmpty
                                                  ? '${table.tableNumber} - ${table.tableName}'
                                                  : 'Table ${table.tableNumber}',
                                              style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 3, 27, 48),
                                                fontSize: 13,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedTableNumber =
                                              newValue ?? 'Table';
                                          reSelectTableNumber = newValue ?? '';
                                        });
                                      },
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _showAddPersonDialog(context),
                              icon: const Icon(Icons.person_add),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'toggle_print') {
                                  setState(() {
                                    _enablePrint = !_enablePrint;
                                    _savePrintOptionState();
                                  });
                                } else if (value == 'view_orders') {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return const HoldOrderPage(menuItems: []);
                                    },
                                  ));
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'toggle_print',
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.print_rounded,
                                              size: 20,
                                              color: _enablePrint
                                                  ? const Color(0xFF4CAF50)
                                                  : Colors.grey[600],
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Enable Print',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: _enablePrint
                                                    ? const Color(0xFF4CAF50)
                                                    : Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Switch(
                                          value: _enablePrint,
                                          onChanged: (bool value) {
                                            setState(() {
                                              _enablePrint = value;
                                              _savePrintOptionState();
                                            });
                                            Navigator.pop(context);
                                          },
                                          activeColor: const Color(0xFF4CAF50),
                                          activeTrackColor:
                                              const Color(0xFF4CAF50)
                                                  .withOpacity(0.4),
                                          inactiveThumbColor: Colors.grey[400],
                                          inactiveTrackColor: Colors.grey[300],
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const PopupMenuDivider(),
                                PopupMenuItem(
                                  value: 'view_orders',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.receipt_long_rounded,
                                        size: 20,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'View Orders',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
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
                      builder: (context, menuState) {
                        if (menuState is MenuLoaded) {
                          final reversedCartItems =
                              menuState.cartItems.reversed.toList();

                          return BlocBuilder<MenuPrintBloc, MenuPrintState>(
                            builder: (context, menuPrintState) {
                              if (menuPrintState is MenuPrintLoaded) {
                                return Container(
                                  padding:
                                      const EdgeInsets.only(left: 10, top: 15),
                                  color: Colors.grey[200],
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: reversedCartItems.length,
                                          itemBuilder: (context, index) {
                                            final cartItem =
                                                reversedCartItems[index];

                                            final matchedPrintItem =
                                                menuPrintState.printItems
                                                    .firstWhere(
                                              (item) =>
                                                  item.product.menuId ==
                                                  cartItem.product.menuId,
                                              orElse: () => MenuPrintModel(
                                                  product: cartItem
                                                      .product), // ✅ Valid default
                                            );

                                            return CartItemWidget(
                                              cartItem: cartItem,
                                              cartItemPrint: matchedPrintItem,
                                            );
                                          },
                                        ),
                                      ),
                                      // Summary section with keyboard handling
                                      SafeArea(
                                        child: Container(
                                          color: Colors.grey[200],
                                          child: summarySection(
                                            context,
                                            menuState.totalAmount,
                                            menuState.cartItems,
                                            selectedTableNumber!,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                            },
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

  void _showAddPersonDialog(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    // Fetch the current state from the Bloc
    final currentState = context.read<CustomerInfoOrderBloc>().state;

    if (currentState is CustomerInfoOrderLoaded) {
      existingName = currentState.customerInfo.name;
      existingContact = currentState.customerInfo.contact;
      reSelectTableNumber = currentState.customerInfo.tableNo;
    }

    nameController.text = existingName;
    contactController.text = existingContact;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Person"),
          content: Scrollbar(
            thumbVisibility: true, // Makes the scrollbar always visible
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Name is required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: contactController,
                      decoration:
                          const InputDecoration(labelText: "Contact Number"),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Contact Number is required";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                }
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
        // First, add to MenuBloc
        context.read<MenuBloc>().add(AddToCart(product, ""));

        try {
          context.read<MenuPrintBloc>().add(AddToPrint(product, ""));
        } catch (e) {
          print("Error adding to MenuPrintBloc: $e");
        }
      },
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(8),
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
                        borderRadius: BorderRadius.circular(16),
                        image: (product.dishImage != null &&
                                product.dishImage!.isNotEmpty &&
                                product.dishImage != "No Image" &&
                                File(product.dishImage!).existsSync())
                            ? DecorationImage(
                                image: FileImage(File(product.dishImage!)),
                                fit: BoxFit.cover,
                              )
                            : const DecorationImage(
                                image: AssetImage('assets/icons/logo.png'),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.menuName.length > 28
                          ? '${product.menuName.substring(0, 28)}...'
                          : product.menuName,
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
                    'Nu. ${product.price}',
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Color.fromARGB(255, 0, 29, 57),
                    ),
                    onPressed: () => _showItemDetails(context, product),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

// items details popup page you know what and you know who
  void _showItemDetails(BuildContext context, MenuModel product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.4, // Reduced width
            child: Dialog(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                          child: (product.dishImage != null &&
                                  product.dishImage!.isNotEmpty &&
                                  product.dishImage != "No Image" &&
                                  File(product.dishImage!).existsSync())
                              ? Image.file(
                                  File(product.dishImage!),
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/icons/logo.png',
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title and Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              product.menuName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 3, 27, 48),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 3, 27, 48)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color.fromARGB(255, 3, 27, 48)
                                    .withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Nu. ${product.price}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 3, 27, 48),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Divider
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      if (product.description != null &&
                          product.description!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 3, 27, 48),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),

                      // Close button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 3, 27, 48),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
            child: Center(
              child: Container(
                child: Text(
                  "Sales Page",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Expanded(flex: 5, child: action),
        ],
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
    String tableNumber,
  ) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final prefs = snapshot.data!;
        final bst = prefs.getDouble(TaxSettingsBloc.bstKey) ?? 0.0;
        final serviceCharge =
            prefs.getDouble(TaxSettingsBloc.serviceChargeKey) ?? 0.0;

        // Calculate tax amounts based on checkbox states
        final bstAmount = _applyBst ? totalAmount * (bst / 100) : 0.0;
        final serviceChargeAmount =
            _applyServiceCharge ? totalAmount * (serviceCharge / 100) : 0.0;
        final payableAmount = totalAmount + bstAmount + serviceChargeAmount;

        return Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.only(top: 2, bottom: 2),
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
                  Text(
                      "Nu. ${totalAmount.toStringAsFixed(2)}"), // Dynamic subtotal
                ],
              ),
              // BST Row with refined checkbox
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor: Colors.grey[400],
                        ),
                        child: Checkbox(
                          value: _applyBst,
                          onChanged: (bool? value) {
                            setState(() {
                              _applyBst = value ?? true;
                              _saveTaxCheckboxStates();
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          fillColor: MaterialStateProperty.resolveWith<Color>(
                              (states) {
                            return states.contains(MaterialState.selected)
                                ? const Color(0xFF4CAF50) // Apple green
                                : Colors.transparent;
                          }),
                          side: BorderSide(
                            color: _applyBst
                                ? const Color(0xFF4CAF50)
                                : Colors.grey[400]!,
                            width: 1.5,
                          ),
                          checkColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "B.S.T ${bst.toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: _applyBst
                              ? const Color(0xFF2E7D32)
                              : Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Nu. ${bstAmount.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: _applyBst
                          ? const Color(0xFF2E7D32)
                          : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Service Charge Row with refined checkbox
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor: Colors.grey[400],
                        ),
                        child: Checkbox(
                          value: _applyServiceCharge,
                          onChanged: (bool? value) {
                            setState(() {
                              _applyServiceCharge = value ?? true;
                              _saveTaxCheckboxStates();
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          fillColor: MaterialStateProperty.resolveWith<Color>(
                              (states) {
                            return states.contains(MaterialState.selected)
                                ? const Color(0xFF8BC34A) // Light apple green
                                : Colors.transparent;
                          }),
                          side: BorderSide(
                            color: _applyServiceCharge
                                ? const Color(0xFF8BC34A)
                                : Colors.grey[400]!,
                            width: 1.5,
                          ),
                          checkColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Service ${serviceCharge.toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: _applyServiceCharge
                              ? const Color(0xFF2E7D32)
                              : Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Nu. ${serviceChargeAmount.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: _applyServiceCharge
                          ? const Color(0xFF2E7D32)
                          : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                    "Nu. ${payableAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  BlocBuilder<MenuBloc, MenuState>(
                    builder: (context, state) {
                      if (state is MenuLoaded && state.cartItems.isNotEmpty) {
                        return Expanded(
                          child: orderButton(
                            "Save",
                            const Color(0xFFFFDAB9),
                            HoldOrderPage(menuItems: state.cartItems),
                            () async {
                              setState(() {
                                reSelectTableNumber = '';
                                selectedTableNumber = 'Table';
                              });

                              const uuid = Uuid();
                              final holdOrderId = uuid.v4();

                              // Get customer info from CustomerInfoOrderBloc
                              final customerInfoState =
                                  context.read<CustomerInfoOrderBloc>().state;

                              // Use CustomerInfoOrderBloc's order number if present, otherwise use _orderCounter
                              int currentOrderNumber = _orderCounter;

                              // Inside your widget or function
                              final now = DateTime.now();
                              final formattedDateTime =
                                  DateFormat('yyyyMMddHHmmss').format(now);
                              final branchState =
                                  context.read<BranchBloc>().state;
                              final branchCode = branchState is BranchLoaded
                                  ? branchState.branchCode
                                  : '';

                              if (customerInfoState
                                  is CustomerInfoOrderRemoved) {
                                _orderCounter = _permanentOrderCounter;
                              }

                              if (customerInfoState
                                      is CustomerInfoOrderLoaded &&
                                  customerInfoState
                                      .customerInfo.orderNumber.isNotEmpty) {
                                currentOrderNumber = int.parse(customerInfoState
                                    .customerInfo.orderNumber
                                    .split('-')
                                    .last);
                              }

                              final formatedOrderNumber =
                                  '$formattedDateTime-$branchCode-$_orderCounter';

                              final holdItems = HoldOrderModel(
                                holdOrderId: holdOrderId,
                                tableNumber: tableNumber,
                                orderNumber: formatedOrderNumber,
                                customerName: nameController.text,
                                customerContact: contactController.text,
                                orderDateTime: DateTime.now(),
                                menuItems: state.cartItems,
                              );

                              // increment only when there is not customerInfoOrderLoaded
                              if (customerInfoState
                                  is! CustomerInfoOrderLoaded) {
                                await _incrementOrderCounter();
                                await _incrementPermanentOrderCounter();
                              }

                              final customerInfo = CustomerInfoModel(
                                orderId: holdOrderId,
                                orderNumber: formatedOrderNumber,
                                tableNumber: tableNumber,
                                customerName: (state.cartItems.isNotEmpty &&
                                        state.cartItems[0].customerName != null)
                                    ? state.cartItems[0].customerName!
                                    : nameController.text,
                                customerContact: contactController.text,
                                orderDateTime: DateTime.now(),
                                orderedItems: state.cartItems,
                              );

                              context
                                  .read<HoldOrderBloc>()
                                  .add(AddHoldOrder(holdItems));
                              context.read<MenuBloc>().add(RemoveAllFromCart());
                              context
                                  .read<CustomerInfoBloc>()
                                  .add(AddCustomerOrder(customerInfo));

                              final menuPrintState =
                                  context.read<MenuPrintBloc>().state;

                              final ticket = HoldOrderTicket(
                                id: holdOrderId,
                                date: DateFormat('yyyy-MM-dd')
                                    .format(holdItems.orderDateTime),
                                time: DateFormat('hh:mm a')
                                    .format(holdItems.orderDateTime),
                                user: holdItems.customerName,
                                tableNumber: holdItems.tableNumber,
                                orderNumber: formatedOrderNumber,
                                items: (menuPrintState as MenuPrintLoaded)
                                    .printItems,
                                contact: holdItems.customerContact,
                              );

                              existingContact = '';
                              existingName = '';
                              nameController.text = '';
                              contactController.text = '';

                              context
                                  .read<CustomerInfoOrderBloc>()
                                  .add(RemoveCustomerInfoOrder());

                              context
                                  .read<MenuPrintBloc>()
                                  .add(const RemoveAllFromPrint());

                              if (_enablePrint) {
                                await ticket.printToThermalPrinter(context);
                              }
                            },
                          ),
                        );
                      } else {
                        return Expanded(
                          child: orderButton(
                            "View Orders",
                            const Color.fromARGB(255, 3, 27, 48),
                            const HoldOrderPage(menuItems: []), // Empty cart
                            () {
                              setState(() {
                                selectedTableNumber = 'Table';
                                reSelectTableNumber = '';
                              });
                            },
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

                        // All logic inside Expanded
                        final branchState = context.read<BranchBloc>().state;
                        final now = DateTime.now();
                        final formattedDateTime =
                            DateFormat('yyyyMMddHHmmss').format(now);
                        final branchCode = branchState is BranchLoaded
                            ? branchState.branchCode
                            : '';
                        final branchName = branchState is BranchLoaded
                            ? branchState.branchName
                            : '';
                        final generatedOrderNumber =
                            '$formattedDateTime-$branchCode-$_orderCounter';

                        return Opacity(
                          opacity: isEnabled ? 1.0 : 0.4,
                          child: AbsorbPointer(
                            absorbing: !isEnabled,
                            child: orderButton(
                              "Proceed",
                              const Color.fromARGB(255, 101, 221, 159),

                              // Goes to the Proceed page with the following input in the mind
                              ProceedPages(
                                items: isEnabled ? state.cartItems : [],
                                branchName: branchName,
                                customername: nameController.text,
                                bst: bst,
                                serviceTax: serviceCharge,
                                tableNumber: tableNumber,
                                phoneNumber: "+975-${contactController.text}",
                                orderID: const Uuid().v4(),
                                subTotal: totalAmount,
                                //must include the tax you know what and what ever is who
                                totalCost: double.parse(
                                    payableAmount.toStringAsFixed(2)),
                                orderNumber: generatedOrderNumber,
                              ),

                              () async {
                                const uuid = Uuid();

                                // Get customer info from bloc
                                final customerInfoState =
                                    context.read<CustomerInfoOrderBloc>().state;

                                int currentOrderNumber = _orderCounter;

                                if (customerInfoState
                                        is CustomerInfoOrderLoaded &&
                                    customerInfoState
                                        .customerInfo.orderNumber.isNotEmpty) {
                                  currentOrderNumber = int.tryParse(
                                          customerInfoState
                                              .customerInfo.orderNumber
                                              .split('-')
                                              .last) ??
                                      _orderCounter;
                                }

                                await _incrementOrderCounter();
                                await _incrementPermanentOrderCounter();

                                existingContact = '';
                                existingName = '';
                                nameController.text = '';
                                contactController.text = '';

                                setState(() {
                                  reSelectTableNumber = '';
                                  selectedTableNumber = 'Table';
                                });

                                context
                                    .read<CustomerInfoOrderBloc>()
                                    .add(RemoveCustomerInfoOrder());
                                context
                                    .read<MenuPrintBloc>()
                                    .add(const RemoveAllFromPrint());
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
      },
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
