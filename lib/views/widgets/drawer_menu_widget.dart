import 'package:flutter/material.dart';

class DrawerMenuWidget extends StatelessWidget {
  const DrawerMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => IconButton(
        icon: const Icon(
          Icons.menu,
          size: 30,
          color: Colors.deepOrange,
        ),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
    );
  }
}
