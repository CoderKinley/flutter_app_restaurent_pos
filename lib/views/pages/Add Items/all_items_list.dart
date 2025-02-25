import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_item_local_bloc/bloc/menu_items_bloc.dart';
import 'package:pos_system_legphel/views/pages/Add%20Items/add_new_item_page.dart';

class AllItemsList extends StatefulWidget {
  const AllItemsList({super.key});

  @override
  State<AllItemsList> createState() => _AllItemsListState();
}

class _AllItemsListState extends State<AllItemsList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          BlocBuilder<ProductBloc, ProductState>(builder: (context, state) {
            if (state is ProductLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is ProductLoaded) {
              return ListView.builder(
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return AddNewItemPage(product: product);
                            },
                          ));
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 8.0, right: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            leading: product.image.isNotEmpty
                                ? Image.file(
                                    File(product.image),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.green,
                                  ),
                            title: Text(product.name),
                            subtitle: Text(
                              'Nu.${product.price.toString()}',
                              style: TextStyle(
                                color: Colors.green,
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                context
                                    .read<ProductBloc>()
                                    .add(DeleteProduct(product.id!));
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ),
                        ),
                      ),
                      // Divider added here between list items
                      Divider(),
                    ],
                  );
                },
              );
            }
            return Container();
          }),
          // Custom Floating Action Button ------------------------------->
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return AddNewItemPage();
                  },
                ));
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 3, 27, 48),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
