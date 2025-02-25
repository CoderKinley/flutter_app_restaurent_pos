import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/counter_bloc/bloc/counter_bloc.dart';
import 'package:pos_system_legphel/views/widgets/drawer_widget.dart';

class ShiftPage extends StatelessWidget {
  const ShiftPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shift"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder<CounterBloc, CounterState>(
            builder: (context, state) {
              return Center(
                child: Text(
                  state.counter.toString(),
                  style: const TextStyle(
                    fontSize: 60,
                  ),
                ),
              );
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<CounterBloc>().add(
                        IncrementCounter(),
                      );
                },
                child: const Text("+"),
              ),
              const SizedBox(
                width: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<CounterBloc>().add(
                        DecrementCounter(),
                      );
                },
                child: const Text("-"),
              ),
            ],
          )
        ],
      ),
      drawer: const DrawerWidget(),
    );
  }
}
