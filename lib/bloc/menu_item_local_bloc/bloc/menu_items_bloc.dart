import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/SQL/database_helper.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_items_model_local_stg.dart';

part 'menu_items_event.dart';
part 'menu_items_state.dart';

// Bloc Implementation
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final DatabaseHelper dbHelper;

  ProductBloc(this.dbHelper) : super(ProductLoading()) {
    on<LoadProducts>((event, emit) async {
      final products = await dbHelper.fetchProducts();
      emit(ProductLoaded(products));
    });

    on<AddProduct>((event, emit) async {
      await dbHelper.insertProduct(event.product);
      add(LoadProducts());
    });

    on<UpdateProduct>((event, emit) async {
      await dbHelper.updateProduct(event.product);
      add(LoadProducts());
    });

    on<DeleteProduct>((event, emit) async {
      await dbHelper.deleteProduct(event.id);
      add(LoadProducts());
    });

    on<DeleteAllProducts>((event, emit) async {
      await dbHelper.deleteAllProducts();
      add(LoadProducts());
    });
  }
}
