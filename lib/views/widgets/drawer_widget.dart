import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_system_legphel/bloc/navigation_bloc/bloc/navigation_bloc.dart";

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Legphel Hotel"),
            accountEmail: const Text("hotel.legphel@gamil.com"),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset(
                  'assets/icons/logo.png',
                  width: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.deepOrange,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.add_shopping_cart_outlined),
                  title: const Text(
                    "Sales",
                  ),
                  onTap: () {
                    context.read<NavigationBloc>().add(NavigateToSales());
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt),
                  title: const Text(
                    "Receipt",
                  ),
                  onTap: () {
                    context.read<NavigationBloc>().add(NavigateToReceipt());
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_card),
                  title: const Text(
                    "Items",
                  ),
                  onTap: () {
                    context.read<NavigationBloc>().add(NavigateToItems());
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notification_add),
                  title: const Text(
                    "Notification",
                  ),
                  onTap: () {
                    context
                        .read<NavigationBloc>()
                        .add(NavigateToNotification());
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_add_rounded),
                  title: const Text(
                    "Shift",
                  ),
                  onTap: () {
                    context.read<NavigationBloc>().add(NavigateToShift());
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text(
                    "Settings",
                  ),
                  onTap: () {
                    context.read<NavigationBloc>().add(NavigateToSettings());
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text(
                    "Exit",
                  ),
                  onTap: () {
                    SystemNavigator.pop();
                  },
                )
              ],
            ),
          ),
        ],
      ),
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
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel")),
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
            )
          ],
        );
      },
    );
  }
}
