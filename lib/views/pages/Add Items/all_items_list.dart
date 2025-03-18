import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_from_api/bloc/menu_from_api_bloc.dart';
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
          BlocBuilder<MenuBlocApi, MenuApiState>(
            builder: (context, state) {
              if (state is MenuApiLoading) {
                return const CircularProgressIndicator();
              } else if (state is MenuApiLoaded) {
                return ListView.builder(
                  itemCount: state.menuItems.length,
                  itemBuilder: (context, index) {
                    final items = state.menuItems[index];
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return AddNewItemPage(
                                  product: items,
                                );
                              },
                            ));
                          },
                          child: Container(
                            margin:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ListTile(
                              leading: (items.dishImage != null &&
                                      items.dishImage!.isNotEmpty &&
                                      items.dishImage != "No Image" &&
                                      File(items.dishImage!).existsSync())
                                  ? Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        image: DecorationImage(
                                          image:
                                              FileImage(File(items.dishImage!)),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 255, 231, 224),
                                        borderRadius: BorderRadius.circular(50),
                                        image: const DecorationImage(
                                          image: AssetImage(
                                              'assets/icons/logo.png'), // Default image
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                              title: Text(items.menuName),
                              subtitle: Text(
                                'Nu. ${items.price}',
                                style: const TextStyle(
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                );
              }
              return Container();
            },
          ),
          // Custom Floating Action Button ------------------------------->
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const AddNewItemPage();
                  },
                ));
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 3, 27, 48),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
