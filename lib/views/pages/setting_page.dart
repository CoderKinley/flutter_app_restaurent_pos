import 'package:flutter/material.dart';
import 'package:pos_system_legphel/views/widgets/drawer_widget.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setting Page")),
      body: const Center(
        child: Text("Setting Page Still Under Development!"),
      ),
      drawer: const DrawerWidget(),
    );
  }
}
