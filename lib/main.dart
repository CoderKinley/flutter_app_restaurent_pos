import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/SQL/database_helper.dart';
import 'package:pos_system_legphel/SQL/menu_local_db.dart';
import 'package:pos_system_legphel/bloc/add_item_menu_navigation/bloc/add_item_navigation_bloc.dart';
import 'package:pos_system_legphel/bloc/category_bloc/bloc/cetagory_bloc.dart';
import 'package:pos_system_legphel/bloc/customer_info_order_bloc/bloc/customer_info_order_bloc.dart';
import 'package:pos_system_legphel/bloc/hold_order_bloc/bloc/hold_order_bloc.dart';
import 'package:pos_system_legphel/bloc/list_bloc/bloc/itemlist_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_from_api/bloc/menu_from_api_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_item_bloc/bloc/menu_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_item_local_bloc/bloc/menu_items_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_print_bloc/bloc/menu_print_bloc.dart';
import 'package:pos_system_legphel/bloc/navigation_bloc/bloc/navigation_bloc.dart';
import 'package:pos_system_legphel/bloc/proceed_order_bloc/bloc/proceed_order_bloc.dart';
import 'package:pos_system_legphel/bloc/sub_category_bloc/bloc/sub_category_bloc.dart';
import 'package:pos_system_legphel/bloc/table_bloc/bloc/add_table_bloc.dart';
import 'package:pos_system_legphel/bloc/tables%20and%20names/bloc/customer_info_bloc.dart';
import 'package:pos_system_legphel/data/menu_api_service.dart';
import 'package:pos_system_legphel/data/repositories/menu_repository.dart';
import 'package:pos_system_legphel/views/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NavigationBloc()),
        BlocProvider(create: (context) => ItemlistBloc()),
        BlocProvider(
            create: (context) =>
                ProductBloc(DatabaseHelper.instance)..add(LoadProducts())),
        BlocProvider(
          create: (context) => AddItemNavigationBloc(),
        ),
        BlocProvider(create: (context) => MenuBloc()),
        BlocProvider(create: (context) => HoldOrderBloc()),
        BlocProvider(create: (context) => ProceedOrderBloc()),
        BlocProvider(create: (context) => TableBloc()),
        BlocProvider(create: (context) => CustomerInfoBloc()),
        BlocProvider(create: (context) => CustomerInfoOrderBloc()),
        BlocProvider(create: (context) => MenuPrintBloc()),
        BlocProvider(
            create: (context) => SubcategoryBloc()..add(LoadAllSubcategory())),
        BlocProvider(
          create: (context) => MenuBlocApi(
            MenuRepository(
              MenuApiService(), // Create an instance
              MenuLocalDb(), // Create an instance
            ),
          ),
        ),
        BlocProvider(
            create: (context) => CategoryBloc()..add(LoadCategories())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.light,
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}
