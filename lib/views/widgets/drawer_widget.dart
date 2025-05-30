import "dart:async";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_system_legphel/bloc/navigation_bloc/bloc/navigation_bloc.dart";
import "package:pos_system_legphel/services/network_service.dart";
import "package:connectivity_plus/connectivity_plus.dart";
import "dart:io";

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  bool _isServerAvailable = false;
  bool _isNetworkAvailable = false;
  final NetworkService _networkService =
      NetworkService(baseUrl: 'http://119.2.105.142:3800');
  Timer? _statusTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    // Check status every 30 seconds
    _statusTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkStatus();
    });

    // Listen to connectivity changes
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _checkStatus();
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    try {
      // Check basic connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      bool hasConnectivity = connectivityResult != ConnectivityResult.none;

      // If there's basic connectivity, check internet access
      bool hasInternetAccess = false;
      if (hasConnectivity) {
        try {
          final result = await InternetAddress.lookup('google.com');
          hasInternetAccess =
              result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        } on SocketException catch (_) {
          hasInternetAccess = false;
        }
      }

      // Check server availability
      final isServerAvailable = await _networkService.isServerAvailable();

      if (mounted) {
        setState(() {
          _isNetworkAvailable = hasConnectivity && hasInternetAccess;
          _isServerAvailable = isServerAvailable;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isNetworkAvailable = false;
          _isServerAvailable = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.pink.shade50, // Keeping the pink tone
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text(
                "Legphel Hotel",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: const Text(
                "hotel.legphel@gmail.com",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    'assets/icons/logo.png',
                    width: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFD62D20), // Apple red
                    Color(0xFFFF7F7F), // Lighter red/pink
                  ],
                ),
              ),
            ),
            // Status Indicators
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatusIndicator(
                      icon: Icons.cloud_done,
                      label: 'Server',
                      isAvailable: _isServerAvailable,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatusIndicator(
                      icon: Icons.wifi,
                      label: 'Network',
                      isAvailable: _isNetworkAvailable,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.black12),
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.add_shopping_cart_outlined,
                    title: "Sales",
                    color: Color(0xFF34C759), // Apple green
                    navigationEvent: NavigateToSales(),
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.receipt,
                    title: "Receipt",
                    color: Color(0xFF5856D6), // Apple purple
                    navigationEvent: NavigateToReceipt(),
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.add_card,
                    title: "Edit Items",
                    color: Color(0xFF007AFF), // Apple blue
                    navigationEvent: NavigateToItems(),
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.notification_add,
                    title: "Notification",
                    color: Color(0xFFFF9500), // Apple orange
                    navigationEvent: NavigateToNotification(),
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.person_add_rounded,
                    title: "Shift",
                    color: Color(0xFFAF52DE), // Apple pink
                    navigationEvent: NavigateToShift(),
                  ),
                  const Divider(
                    color: Colors.black12,
                    thickness: 1,
                    height: 20,
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.settings,
                    title: "Settings",
                    color: Colors.grey.shade700,
                    navigationEvent: NavigateToSettings(),
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.exit_to_app,
                    title: "Exit",
                    color: Color(0xFFFF3B30), // Apple red
                    onTap: () => _confirmExit(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator({
    required IconData icon,
    required String label,
    required bool isAvailable,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isAvailable
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAvailable
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isAvailable ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                isAvailable ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isAvailable ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    dynamic navigationEvent,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade800,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap ??
          () {
            if (navigationEvent != null) {
              context.read<NavigationBloc>().add(navigationEvent);
            }
            Navigator.pop(context);
          },
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Exit App"),
          content: const Text("Are you sure you want to exit the app?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                SystemNavigator.pop();
              },
              child: const Text(
                "Exit",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
