import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos_system_legphel/bloc/proceed_order_bloc/bloc/proceed_order_bloc.dart';
import 'package:pos_system_legphel/views/widgets/drawer_menu_widget.dart';
import 'package:pos_system_legphel/models/Menu%20Model/proceed_order_model.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  _ReceiptPageState createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> with WidgetsBindingObserver {
  ProceedOrderModel? selectedReceiptItem;
  final int _orderNumberCounter = 1;
  DateTime? startDate;
  DateTime? endDate;
  DateTime selectedDate = DateTime.now();
  final ScrollController scrollController = ScrollController();
  Timer? _autoReloadTimer;
  final FocusNode _focusNode = FocusNode();
  bool _isFirstLoad = true;
  List<ProceedOrderModel> _allOrders = [];

  // Add pagination variables
  static const int _pageSize = 30;
  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupAutoReload();
    _focusNode.addListener(_onFocusChange);

    // Add scroll listener
    scrollController.addListener(_scrollListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      // Reset pagination before loading
      _resetPagination();
      // Trigger initial load
      context.read<ProceedOrderBloc>().add(LoadProceedOrders());
    }
  }

  @override
  void dispose() {
    _autoReloadTimer?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    scrollController.removeListener(_scrollListener);
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

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Calculate next page
    final nextPage = _currentPage + 1;
    final startIndex = nextPage * _pageSize;

    // Check if we have more data to load
    if (startIndex >= _allOrders.length) {
      setState(() {
        _hasMoreData = false;
        _isLoadingMore = false;
      });
      return;
    }

    // Simulate loading delay (remove this in production)
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _currentPage = nextPage;
      _isLoadingMore = false;
    });
  }

  void _resetPagination() {
    setState(() {
      _currentPage = 0;
      _isLoadingMore = false;
      _hasMoreData = _allOrders.length > _pageSize;
    });
  }

  void _processOrders(List<ProceedOrderModel> orders) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // Store all orders in reverse chronological order
        _allOrders = orders.reversed.toList();

        // Reset pagination state
        _resetPagination();

        // Set the selectedReceiptItem to the most recent order if not already set
        if (selectedReceiptItem == null && _allOrders.isNotEmpty) {
          selectedReceiptItem = _allOrders.first;
        }
      });
    });
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
    // Use _allOrders instead of orders parameter to ensure we export all data
    print('_exportToExcel called with ${_allOrders.length} orders');
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
    final filteredOrders = _allOrders.where((order) {
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
        padding: const EdgeInsets.all(0),
        child: Row(
          children: [
            // Left side (List of receipts)
            Expanded(
              flex: 3,
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
                      child: _buildTopNavigationBar(),
                    ),
                    // Date range and export buttons
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: Colors.grey[100],
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildDateRangeButton(),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Builder(
                              builder: (context) => _buildExportButton(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Receipt list
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
                              bloc.add(LoadProceedOrders());
                              return bloc;
                            },
                            child: BlocBuilder<ProceedOrderBloc,
                                ProceedOrderState>(
                              builder: (context, state) {
                                if (state is ProceedOrderLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (state is ProceedOrderError) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Error: ${state.message}',
                                          style: const TextStyle(
                                              color: Colors.red),
                                        ),
                                        const SizedBox(height: 16),
                                        _buildRetryButton(context),
                                      ],
                                    ),
                                  );
                                }

                                if (state is ProceedOrderLoaded) {
                                  if (_allOrders != state.proceedOrders) {
                                    _processOrders(state.proceedOrders);
                                  }

                                  if (_allOrders.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.receipt_long,
                                              size: 48,
                                              color: Colors.grey[400]),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'No orders found',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  final groupedOrders = _groupOrdersByDate();

                                  return CustomScrollView(
                                    controller: scrollController,
                                    slivers: [
                                      _buildDateHeader(groupedOrders),
                                      _buildOrderList(groupedOrders),
                                      _buildLoadingIndicator(),
                                      _buildNoMoreDataIndicator(),
                                    ],
                                  );
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
            ),
            // Right side (Detailed view)
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  _buildDetailHeader(),
                  Expanded(
                    child: Container(
                      color: Colors.grey[200],
                      child: selectedReceiptItem == null
                          ? _buildEmptyDetailView()
                          : _buildReceiptDetailView(),
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

  // Widget building methods
  Widget _buildTopNavigationBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          const Spacer(),
          const Text(
            'Order History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance the row
        ],
      ),
    );
  }

  Widget _buildDateRangeButton() {
    return ElevatedButton.icon(
      onPressed: () => _selectDateRange(context),
      icon: const Icon(Icons.date_range, size: 18),
      label: Text(
        startDate != null && endDate != null
            ? '${DateFormat('MMM d').format(startDate!)} - ${DateFormat('MMM d').format(endDate!)}'
            : 'Select Date',
        style: const TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _handleExport(context),
      icon: const Icon(Icons.file_download, size: 18),
      label: const Text(
        'Export to Excel',
        style: TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<ProceedOrderBloc>().add(LoadProceedOrders());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text('Retry'),
    );
  }

  Map<String, List<ProceedOrderModel>> _groupOrdersByDate() {
    Map<String, List<ProceedOrderModel>> groupedOrders = {};
    final paginatedOrders =
        _allOrders.take((_currentPage + 1) * _pageSize).toList();

    for (var order in paginatedOrders) {
      String dateKey = order.orderDateTime.toLocal().toString().split(' ')[0];
      if (!groupedOrders.containsKey(dateKey)) {
        groupedOrders[dateKey] = [];
      }
      groupedOrders[dateKey]!.add(order);
    }

    var reversedGroupedOrders = Map.fromEntries(
        groupedOrders.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));

    reversedGroupedOrders.updateAll((key, value) {
      value.sort((a, b) => b.orderDateTime.compareTo(a.orderDateTime));
      return value;
    });

    return reversedGroupedOrders;
  }

  Widget _buildDateHeader(Map<String, List<ProceedOrderModel>> groupedOrders) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 3, 27, 48),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
        child: Text(
          groupedOrders.isEmpty ? 'No Orders' : groupedOrders.keys.first,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(Map<String, List<ProceedOrderModel>> groupedOrders) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final entry = groupedOrders.entries.toList()[index];
          return Column(
            children: [
              if (index > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    // heading in each start of new dataed items
                    color: const Color.fromARGB(255, 3, 27, 48),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              Column(
                children: entry.value.map((proceedOrder) {
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedReceiptItem = proceedOrder;
                          });
                        },
                        child: _buildReceiptListItem(proceedOrder),
                      ),
                      const Divider(height: 1, color: Colors.black12),
                    ],
                  );
                }).toList(),
              ),
            ],
          );
        },
        childCount: groupedOrders.length,
      ),
    );
  }

  Widget _buildReceiptListItem(ProceedOrderModel proceedOrder) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: selectedReceiptItem?.holdOrderId == proceedOrder.holdOrderId
            ? Colors.blue.shade50
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.receipt, color: Colors.blue),
        ),
        title: Text(
          'Order #${proceedOrder.orderNumber.split('-')[2]}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          DateFormat('MMMM d, y – h:mm a').format(proceedOrder.orderDateTime),
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (String value) {
            if (value == 'delete') {
              _showDeleteConfirmationDialog(context, () {
                context.read<ProceedOrderBloc>().add(
                      DeleteProceedOrder(proceedOrder.holdOrderId),
                    );
              });
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Delete Order'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return _isLoadingMore
        ? const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  Widget _buildNoMoreDataIndicator() {
    return !_hasMoreData && _allOrders.length > _pageSize
        ? const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No more orders to load',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          )
        : const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  Widget _buildDetailHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BlocBuilder<ProceedOrderBloc, ProceedOrderState>(
            builder: (context, state) {
              if (state is ProceedOrderLoaded) {
                final selectedDayOrders = state.proceedOrders.where((order) {
                  final orderDate = order.orderDateTime;
                  return orderDate.year == selectedDate.year &&
                      orderDate.month == selectedDate.month &&
                      orderDate.day == selectedDate.day;
                }).toList();

                final dayTotal = selectedDayOrders.fold<double>(
                  0,
                  (sum, order) => sum + order.totalPrice,
                );

                return Row(
                  children: [
                    _buildDateSelector(),
                    const SizedBox(width: 12),
                    _buildDayTotal(dayTotal, selectedDayOrders.length),
                    const SizedBox(width: 12),
                    _buildTotalOrders(state.proceedOrders.length),
                    if (state is ProceedOrderLoading) _buildLoadingIndicator(),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.person_add, color: Colors.white),
                tooltip: 'Add Customer',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert, color: Colors.white),
                tooltip: 'More Options',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              DateFormat('MMM d, yyyy').format(selectedDate),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTotal(double total, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${total.toStringAsFixed(2)} Nu',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($count)',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalOrders(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDetailView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Select an order to view details',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptDetailView() {
    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary header
              Center(
                child: Column(
                  children: [
                    Text(
                      '${selectedReceiptItem?.totalAmount ?? 0} Nu',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text(
                      'TOTAL AMOUNT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),

              // Order details
              _buildDetailRow(
                  'POS:', selectedReceiptItem?.restaurantBranchName ?? 'N/A'),
              _buildDetailRow(
                  'Order Number:', selectedReceiptItem?.orderNumber ?? 'N/A'),
              const SizedBox(height: 16),

              // Order type
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'DINE IN',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Order items
              if (selectedReceiptItem?.menuItems != null)
                ...selectedReceiptItem!.menuItems
                    .map((item) => _buildOrderItem(item))
                    .toList(),

              const Divider(),
              const SizedBox(height: 8),

              // Payment summary
              _buildPaymentSummary(),
              const Divider(),

              // Order timestamp
              Text(
                selectedReceiptItem?.orderDateTime != null
                    ? DateFormat('EEEE, MMMM d yyyy – h:mm a')
                        .format(selectedReceiptItem!.orderDateTime.toLocal())
                    : 'N/A',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildOrderItem(item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.menuName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${item.quantity} x ${item.product.price} Nu',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          Text(
            '${item.totalPrice} Nu',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('100 Nu', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tax', style: TextStyle(color: Colors.grey.shade600)),
            Text('10 Nu', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('TOTAL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )),
            Text(
              '${selectedReceiptItem?.totalPrice ?? 0} Nu',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleExport(BuildContext context) {
    final blocState = context.read<ProceedOrderBloc>().state;

    if (blocState is ProceedOrderLoaded) {
      if (blocState.proceedOrders.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No orders available to export'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(8),
          ),
        );
        return;
      }
      _exportToExcel(blocState.proceedOrders);
    } else if (blocState is ProceedOrderLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading orders, please wait...'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(8),
        ),
      );
    } else {
      context.read<ProceedOrderBloc>().add(LoadProceedOrders());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reloading orders...'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(8),
        ),
      );
    }
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
