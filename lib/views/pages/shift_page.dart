import 'package:flutter/material.dart';
import 'package:pos_system_legphel/views/widgets/drawer_widget.dart';

class ShiftPage extends StatelessWidget {
  const ShiftPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shift Page")),
      body: const Center(
        child: Text("No Shift Still Under Development!"),
      ),
      drawer: const DrawerWidget(),
    );
  }
}
