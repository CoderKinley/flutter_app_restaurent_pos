import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/navigation_bloc/bloc/navigation_bloc.dart';
import 'package:pos_system_legphel/views/pages/items_page.dart';
import 'package:pos_system_legphel/views/pages/notification_page.dart';
import 'package:pos_system_legphel/views/pages/receipt_page.dart';
import 'package:pos_system_legphel/views/pages/sales_page.dart';
import 'package:pos_system_legphel/views/pages/setting_page.dart';
import 'package:pos_system_legphel/views/pages/shift_page.dart';
import 'package:pos_system_legphel/views/widgets/drawer_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerWidget(),
      body: SafeArea(
        child: Stack(
          children: [
            BlocBuilder<NavigationBloc, NavigationState>(
              builder: (context, state) {
                if (state is SalesPageState) {
                  return const SalesPage();
                } else if (state is ReceiptPageState) {
                  return const ReceiptPage();
                } else if (state is ItemsPageState) {
                  return ItemsPage();
                } else if (state is NotificationPageState) {
                  return const NotificationPage();
                } else if (state is SettingsPageState) {
                  return const SettingPage();
                } else if (state is ShiftPageState) {
                  return const ShiftPage();
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}


// https://developer.mescius.com/componentone/winforms-ui-controls