import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos_system_legphel/bloc/proceed_order_bloc/bloc/proceed_order_bloc.dart';
import 'package:pos_system_legphel/views/widgets/drawer_menu_widget.dart';
import 'package:pos_system_legphel/models/Menu%20Model/proceed_order_model.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  _ReceiptPageState createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> with WidgetsBindingObserver {
  ProceedOrderModel? selectedReceiptItem;
  int _orderNumberCounter = 1;
  DateTime? startDate;
  DateTime? endDate;
  DateTime selectedDate = DateTime.now();
  final ScrollController scrollController = ScrollController();
  Timer? _autoReloadTimer;
  final FocusNode _focusNode = FocusNode();
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupAutoReload();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      // Trigger initial load
      context.read<ProceedOrderBloc>().add(LoadProceedOrders());
    }
  }

  @override
  void dispose() {
    _autoReloadTimer?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload when app comes back to foreground
      context.read<ProceedOrderBloc>().add(LoadProceedOrders());
    }
  }

  void _setupAutoReload() {
    // Cancel any existing timer
    _autoReloadTimer?.cancel();

    // Create a new timer that reloads every 30 seconds
    _autoReloadTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        context.read<ProceedOrderBloc>().add(LoadProceedOrders());
      }
    });
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Reload data when the page comes into focus
      context.read<ProceedOrderBloc>().add(LoadProceedOrders());
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _exportToExcel(List<ProceedOrderModel> orders) async {
    print('_exportToExcel called with ${orders.length} orders'); // Debug print
    print('startDate: $startDate, endDate: $endDate'); // Debug print

    if (startDate == null || endDate == null) {
      print('Date range not selected'); // Debug print
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a date range first'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(8),
          ),
        );
      }
      return;
    }

    // Filter orders based on date range
    final filteredOrders = orders.where((order) {
      final isAfterStart = order.orderDateTime.isAfter(startDate!);
      final isBeforeEnd =
          order.orderDateTime.isBefore(endDate!.add(const Duration(days: 1)));
      print(
          'Order ${order.orderNumber}: isAfterStart=$isAfterStart, isBeforeEnd=$isBeforeEnd'); // Debug print
      return isAfterStart && isBeforeEnd;
    }).toList();

    print('Filtered orders count: ${filteredOrders.length}'); // Debug print

    if (filteredOrders.isEmpty) {
      print('No orders in date range'); // Debug print
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No orders found in the selected date range'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(8),
          ),
        );
      }
      return;
    }

    try {
      print('Requesting storage permission'); // Debug print
      // Request storage permissions first
      if (await Permission.manageExternalStorage.request().isGranted) {
        print('Storage permission granted'); // Debug print
        // Create Excel file
        var excel = Excel.createExcel();
        Sheet sheetObject = excel['Orders'];

        // Add headers
        sheetObject.appendRow([
          'Order Number',
          'Date',
          'Time',
          'Customer Name',
          'Phone Number',
          'Total Amount',
          'Items'
        ]);

        // Add data
        for (var order in filteredOrders) {
          String items = order.menuItems
              .map((item) =>
                  '${item.product.menuName} (${item.quantity}x${item.product.price})')
              .join(', ');

          sheetObject.appendRow([
            order.orderNumber,
            DateFormat('yyyy-MM-dd').format(order.orderDateTime),
            DateFormat('HH:mm').format(order.orderDateTime),
            order.customerName,
            order.phoneNumber,
            order.totalPrice.toString(),
            items
          ]);
        }

        // Create directory in root storage
        final excelDirectory = Directory('/storage/emulated/0/Excel Reports');

        // Create the directory if it doesn't exist
        if (!await excelDirectory.exists()) {
          await excelDirectory.create(recursive: true);
        }

        // Create and save the file
        final String fileName =
            'orders_${DateFormat('yyyyMMdd').format(startDate!)}_to_${DateFormat('yyyyMMdd').format(endDate!)}.xlsx';
        final file = File('${excelDirectory.path}/$fileName');

        final fileBytes = excel.encode();
        if (fileBytes != null) {
          await file.writeAsBytes(fileBytes);

          // Open the file after saving
          await OpenFilex.open(file.path);

          // Show success message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Excel file saved to ${file.path}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(8),
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission denied'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(8),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save Excel file: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerMenuWidget(),
      body: Padding(
        padding: const EdgeInsets.only(right: 0, left: 0),
        child: Row(
          children: [
            // Left side (List of receipts)
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Container(
                    height: 60,
                    padding:
                        const EdgeInsets.only(left: 0, right: 10, bottom: 0),
                    color: const Color.fromARGB(255, 3, 27, 48),
                    child: _mainTopMenu(action: _search()),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectDateRange(context),
                            icon: const Icon(Icons.date_range, size: 18),
                            label: Text(
                              startDate != null && endDate != null
                                  ? '${DateFormat('MMM d').format(startDate!)} - ${DateFormat('MMM d').format(endDate!)}'
                                  : 'Select Date',
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Builder(
                            builder: (context) => ElevatedButton.icon(
                              onPressed: () {
                                print('Export button pressed'); // Debug print
                                final blocState =
                                    context.read<ProceedOrderBloc>().state;
                                print(
                                    'Current bloc state: $blocState'); // Debug print

                                if (blocState is ProceedOrderLoaded) {
                                  final state = blocState as ProceedOrderLoaded;
                                  print(
                                      'State loaded, orders count: ${state.proceedOrders.length}'); // Debug print
                                  if (state.proceedOrders.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'No orders available to export'),
                                        backgroundColor: Colors.orange,
                                        duration: Duration(seconds: 3),
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(8),
                                      ),
                                    );
                                    return;
                                  }
                                  _exportToExcel(state.proceedOrders);
                                } else if (blocState is ProceedOrderLoading) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Loading orders, please wait...'),
                                      backgroundColor: Colors.blue,
                                      duration: Duration(seconds: 3),
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(8),
                                    ),
                                  );
                                } else if (blocState is ProceedOrderError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Error: ${blocState.message}'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(8),
                                    ),
                                  );
                                } else {
                                  // Reload orders if state is not loaded
                                  context
                                      .read<ProceedOrderBloc>()
                                      .add(LoadProceedOrders());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Reloading orders...'),
                                      backgroundColor: Colors.blue,
                                      duration: Duration(seconds: 3),
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(8),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.file_download, size: 18),
                              label: const Text(
                                'Export to Excel',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Container(
                  //   padding:
                  //       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  //   color: Colors.grey[100],
                  //   child: Row(
                  //     children: [
                  //       const Icon(Icons.calendar_today,
                  //           size: 16, color: Colors.grey),
                  //       const SizedBox(width: 8),
                  //       Text(
                  //         startDate != null && endDate != null
                  //             ? '${DateFormat('MMM d, yyyy').format(startDate!)} - ${DateFormat('MMM d, yyyy').format(endDate!)}'
                  //             : 'Select date range to export',
                  //         style: const TextStyle(
                  //           color: Colors.grey,
                  //           fontSize: 14,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Expanded(
                    child: Container(
                      padding:
                          const EdgeInsets.only(left: 5, right: 5, top: 10),
                      child: Focus(
                        focusNode: _focusNode,
                        autofocus: true,
                        child: BlocProvider(
                          create: (context) {
                            final bloc = ProceedOrderBloc();
                            // Trigger initial load
                            bloc.add(LoadProceedOrders());
                            return bloc;
                          },
                          child:
                              BlocBuilder<ProceedOrderBloc, ProceedOrderState>(
                            builder: (context, state) {
                              print(
                                  'Current ProceedOrderState: $state'); // Debug print
                              if (state is ProceedOrderLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (state is ProceedOrderLoaded) {
                                print(
                                    'Orders loaded: ${state.proceedOrders.length}'); // Debug print
                                // Group orders by date
                                Map<String, List<ProceedOrderModel>>
                                    groupedOrders = {};
                                for (var order in state.proceedOrders) {
                                  String dateKey = order.orderDateTime
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0]; // Get the date part only
                                  if (!groupedOrders.containsKey(dateKey)) {
                                    groupedOrders[dateKey] = [];
                                  }
                                  groupedOrders[dateKey]!.add(order);
                                }

                                // Sort grouped orders by date in descending order
                                var reversedGroupedOrders = Map.fromEntries(
                                    groupedOrders.entries.toList()
                                      ..sort((a, b) => b.key.compareTo(a.key)));

                                // Sort each day's orders by orderDateTime (time) in descending order
                                reversedGroupedOrders.updateAll((key, value) {
                                  value.sort((a, b) => b.orderDateTime
                                      .compareTo(a.orderDateTime));
                                  return value;
                                });

                                // Set the selectedReceiptItem to the most recent order if not already set
                                if (selectedReceiptItem == null &&
                                    reversedGroupedOrders.isNotEmpty) {
                                  final firstDate =
                                      reversedGroupedOrders.keys.first;
                                  final firstOrders =
                                      reversedGroupedOrders[firstDate]!;
                                  if (firstOrders.isNotEmpty) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      setState(() {
                                        selectedReceiptItem = firstOrders.first;
                                      });
                                    });
                                  }
                                }

                                return CustomScrollView(
                                  controller: scrollController,
                                  slivers: [
                                    // Updating the header with dynamic date based on the first group
                                    SliverPersistentHeader(
                                      pinned: true,
                                      delegate: _DateHeaderDelegate(
                                        reversedGroupedOrders,
                                        scrollController,
                                      ),
                                    ),
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                          final entry = reversedGroupedOrders
                                              .entries
                                              .toList()[index];
                                          return Column(
                                            children: [
                                              Column(
                                                children: entry.value
                                                    .map((proceedOrder) {
                                                  return Column(
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            selectedReceiptItem =
                                                                proceedOrder;
                                                          });
                                                        },
                                                        child:
                                                            _buildReceiptItem(
                                                          DateFormat(
                                                                  'yyyy-MM-dd HH:mm')
                                                              .format(proceedOrder
                                                                  .orderDateTime)
                                                              .toString(),
                                                          'Order Number: ${proceedOrder.orderNumber}',
                                                          time: DateFormat(
                                                                  'HH:mm')
                                                              .format(proceedOrder
                                                                  .orderDateTime),
                                                          onDelete: () {
                                                            context
                                                                .read<
                                                                    ProceedOrderBloc>()
                                                                .add(
                                                                  DeleteProceedOrder(
                                                                      proceedOrder
                                                                          .holdOrderId),
                                                                );
                                                          },
                                                        ),
                                                      ),
                                                      const Divider(),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          );
                                        },
                                        childCount:
                                            reversedGroupedOrders.length,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              if (state is ProceedOrderError) {
                                return Center(child: Text(state.message));
                              }
                              return Container();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Right side (Detailed view)
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 60,
                    color: Colors.grey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "All Items",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            BlocBuilder<ProceedOrderBloc, ProceedOrderState>(
                              builder: (context, state) {
                                if (state is ProceedOrderLoaded) {
                                  // Calculate selected day's total
                                  final selectedDayOrders =
                                      state.proceedOrders.where((order) {
                                    final orderDate = order.orderDateTime;
                                    return orderDate.year ==
                                            selectedDate.year &&
                                        orderDate.month == selectedDate.month &&
                                        orderDate.day == selectedDate.day;
                                  }).toList();

                                  final dayTotal =
                                      selectedDayOrders.fold<double>(
                                    0,
                                    (sum, order) => sum + order.totalPrice,
                                  );

                                  return Row(
                                    children: [
                                      // Date Selector
                                      InkWell(
                                        onTap: () => _selectDate(context),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.calendar_today,
                                                  size: 16,
                                                  color: Colors.white),
                                              const SizedBox(width: 4),
                                              Text(
                                                DateFormat('MMM d, yyyy')
                                                    .format(selectedDate),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Daily Total
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${dayTotal.toStringAsFixed(2)} Nu',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '(${selectedDayOrders.length})',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Total Orders
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.receipt_long,
                                                size: 14, color: Colors.white),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${state.proceedOrders.length}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Auto-reload indicator
                                      if (state is ProceedOrderLoading)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: 12,
                                                height: 12,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Updating...',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
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
                              onPressed: () {},
                              icon: const Icon(Icons.person_add,
                                  color: Colors.white),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.grey[200],
                      child: selectedReceiptItem == null
                          ? const Center(
                              child: Text(
                                'Select an item to view details',
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Card(
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${selectedReceiptItem?.totalPrice ?? 0}Nu',
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              const Text(
                                                'Total',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Text(
                                          'Customer Name: ${selectedReceiptItem?.customerName ?? 'N/A'}'),
                                      Text(
                                          'Contact Number: ${selectedReceiptItem?.phoneNumber ?? 'N/A'}'),
                                      Text(
                                          'POS: ${selectedReceiptItem?.restaurantBranchName ?? 'N/A'}'),
                                      const SizedBox(height: 8),
                                      const Text('Dine in',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      if (selectedReceiptItem?.menuItems !=
                                          null)
                                        for (var item
                                            in selectedReceiptItem!.menuItems)
                                          ListTile(
                                            title: Text(item.product.menuName),
                                            trailing:
                                                Text('${item.totalPrice}Nu'),
                                            subtitle: Text(
                                                '${item.quantity} x ${item.product.price}Nu'),
                                          ),
                                      const Divider(),
                                      const Text('Total',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Cash'),
                                          Text(
                                              '${selectedReceiptItem?.totalPrice ?? 0}Nu'),
                                        ],
                                      ),
                                      const Divider(),
                                      Text(
                                          '${selectedReceiptItem?.orderDateTime.toLocal() ?? 'N/A'}'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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

  Widget _mainTopMenu({
    required Widget action,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
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

  Widget _buildReceiptItem(String date, String title,
      {String? time, required Function onDelete}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.green)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.receipt, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (String value) {
                  if (value == 'delete') {
                    _showDeleteConfirmationDialog(context, onDelete);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ];
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Function onDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                onDelete(); // Call the onDelete function when confirming
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _DateHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Map<String, List<ProceedOrderModel>> groupedOrders;
  final ScrollController scrollController;

  _DateHeaderDelegate(this.groupedOrders, this.scrollController);

  @override
  double get minExtent => 49.0;

  @override
  double get maxExtent => 49.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    if (groupedOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        color: Colors.green,
        child: const Text(
          'No Orders',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
      );
    }

    int currentIndex = (scrollController.offset / 50).floor();
    currentIndex = currentIndex.clamp(0, groupedOrders.keys.length - 1);
    String currentDate = groupedOrders.keys.elementAt(currentIndex);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Colors.green,
      child: Text(
        currentDate,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
