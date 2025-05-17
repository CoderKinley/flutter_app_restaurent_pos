import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_system_legphel/bloc/navigation_bloc/bloc/navigation_bloc.dart";

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

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
                    title: "Items Setting",
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
                    title: "Main Settings",
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
