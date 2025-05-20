import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pos_system_legphel/services/database_helper.dart';
import 'package:pos_system_legphel/SQL/menu_local_db.dart';
import 'package:pos_system_legphel/bloc/add_item_menu_navigation/bloc/add_item_navigation_bloc.dart';
import 'package:pos_system_legphel/bloc/bill_bloc/bill_bloc.dart';
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
import 'package:pos_system_legphel/bloc/ip_address_bloc/bloc/ip_address_bloc.dart';
import 'package:pos_system_legphel/bloc/branch_bloc/bloc/branch_bloc.dart';
import 'package:pos_system_legphel/services/network_service.dart';
import 'package:pos_system_legphel/services/sync_service.dart';
import 'package:pos_system_legphel/bloc/tax_settings_bloc/bloc/tax_settings_bloc.dart';
import 'package:pos_system_legphel/services/ImmersiveModeHelper.dart';
import 'package:pos_system_legphel/bloc/search_suggestion_bloc/bloc/search_suggestion_bloc.dart';
import 'package:pos_system_legphel/providers/theme_provider.dart';
import 'package:pos_system_legphel/bloc/destination/bloc/destination_bloc.dart';
import 'package:pos_system_legphel/SQL/database_helper.dart' as sql;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  await _requestImageAndStoragePermissions();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
  ]);

  await ImmersiveModeHelper.enterFullImmersiveMode();
  ImmersiveModeHelper.setupImmersiveModeListener();

  // Initialize database helpers
  final databaseHelper = DatabaseHelper();
  final menuLocalDb = MenuLocalDb.instance;
  final menuApiService = MenuApiService();
  final categoryBloc = CategoryBloc()..add(LoadCategories());
  final subcategoryBloc = SubcategoryBloc()..add(LoadAllSubcategory());
  final menuRepository = MenuRepository(
    menuLocalDb,
    menuApiService,
    categoryBloc,
    subcategoryBloc,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(
        prefs: prefs,
        databaseHelper: databaseHelper,
        menuRepository: menuRepository,
        categoryBloc: categoryBloc,
        subcategoryBloc: subcategoryBloc,
      ),
    ),
  );
}

Future<void> _requestImageAndStoragePermissions() async {
  if (Platform.isAndroid) {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = deviceInfo.version.sdkInt;

    if (sdkInt >= 33) {
      // Android 13 and above
      await Permission.photos.request(); // For image picker
    } else {
      // Android 12 and below
      await Permission.storage.request();
    }
  } else if (Platform.isIOS) {
    await Permission.photos.request(); // iOS image picker
  }
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final DatabaseHelper databaseHelper;
  final MenuRepository menuRepository;
  final CategoryBloc categoryBloc;
  final SubcategoryBloc subcategoryBloc;

  const MyApp({
    super.key,
    required this.prefs,
    required this.databaseHelper,
    required this.menuRepository,
    required this.categoryBloc,
    required this.subcategoryBloc,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Initialize services
        final networkService =
            NetworkService(baseUrl: 'http://119.2.105.142:3800');
        final syncService = SyncService(
          networkService,
          baseUrl: 'http://119.2.105.142:3800',
        );

        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => NavigationBloc()),
            BlocProvider(create: (context) => ItemlistBloc()),
            BlocProvider(
                create: (context) => ProductBloc(sql.DatabaseHelper.instance)
                  ..add(LoadProducts())),
            BlocProvider(create: (context) => AddItemNavigationBloc()),
            BlocProvider(create: (context) => MenuBloc()),
            BlocProvider(create: (context) => HoldOrderBloc()),
            BlocProvider(create: (context) => ProceedOrderBloc()),
            BlocProvider(create: (context) => TableBloc()),
            BlocProvider(create: (context) => CustomerInfoBloc()),
            BlocProvider(create: (context) => CustomerInfoOrderBloc()),
            BlocProvider(create: (context) => MenuPrintBloc()),
            BlocProvider(
              create: (context) => BillBloc(networkService, syncService),
            ),
            BlocProvider<SubcategoryBloc>.value(value: subcategoryBloc),
            BlocProvider(
              create: (context) => MenuApiBloc(menuRepository),
            ),
            BlocProvider<CategoryBloc>.value(value: categoryBloc),
            BlocProvider(
              create: (context) => IpAddressBloc(prefs),
            ),
            BlocProvider(
              create: (context) => BranchBloc(prefs),
            ),
            BlocProvider(
              create: (context) =>
                  TaxSettingsBloc(prefs)..add(LoadTaxSettings()),
            ),
            BlocProvider(
              create: (context) => SearchSuggestionBloc(),
            ),
            BlocProvider(
              create: (context) =>
                  DestinationBloc(databaseHelper)..add(LoadDestinations()),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            home: const HomePage(),
          ),
        );
      },
    );
  }
}
