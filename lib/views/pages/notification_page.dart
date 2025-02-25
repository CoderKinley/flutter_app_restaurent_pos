import 'package:flutter/material.dart';
import 'package:pos_system_legphel/views/widgets/drawer_widget.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification")),
      body: const Center(
        child: Text("No Notification!"),
      ),
      drawer: const DrawerWidget(),
    );
  }
}
