import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/navigation_bloc/bloc/navigation_bloc.dart';
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
                return state.page;
              },
            ),
          ],
        ),
      ),
    );
  }
}
