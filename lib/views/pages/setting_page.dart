import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_from_api/bloc/menu_from_api_bloc.dart';
import 'package:pos_system_legphel/models/others/new_menu_model.dart';
import 'package:pos_system_legphel/views/widgets/drawer_widget.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  void initState() {
    super.initState();
    context.read<MenuBlocApi>().add(FetchMenuApi());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menu Settings")),
      body: BlocBuilder<MenuBlocApi, MenuApiState>(
        builder: (context, state) {
          if (state is MenuApiLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MenuApiLoaded) {
            return ListView.builder(
              itemCount: state.menuItems.length,
              itemBuilder: (context, index) {
                MenuModel item = state.menuItems[index];
                return ListTile(
                  title: Text(item.menuName),
                  subtitle: Text('${item.price} Nu'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context
                          .read<MenuBlocApi>()
                          .add(RemoveMenuApiItem(item.menuId));
                    },
                  ),
                );
              },
            );
          } else if (state is MenuApiError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return Container(); // Default empty container
        },
      ),
      drawer: const DrawerWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create a new menu item
          // final newItem = MenuModel(
          //   menuId: "12345",
          //   menuName: "New Dish",
          //   menuType: "Main Course",
          //   subMenuType: "Veg",
          //   price: "10.99",
          //   description: "Delicious new dish",
          //   availability: true,
          //   dishImage: null,
          //   uuid: "random-uuid",
          // );
          // context.read<MenuBlocApi>().add(AddMenuApiItem(newItem));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
