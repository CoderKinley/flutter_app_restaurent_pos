import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/category_bloc/bloc/cetagory_bloc.dart';
import 'package:pos_system_legphel/views/pages/Add%20Items/add_new_category.dart';

class ItemsCategoryList extends StatefulWidget {
  const ItemsCategoryList({super.key});

  @override
  State<ItemsCategoryList> createState() => _ItemsCategoryListState();
}

class _ItemsCategoryListState extends State<ItemsCategoryList> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content of the screen
        BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CategoryLoaded) {
              return ListView.builder(
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to AddCategoryPage or another page to edit category
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return AddCategoryPage(
                                  categoryModel: category,
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            title: Text(category.categoryName),
                            subtitle: Text('Status: ${category.status}'),
                            trailing: IconButton(
                              onPressed: () {
                                // Handle category deletion
                                context.read<CategoryBloc>().add(
                                      DeleteCategory(category.categoryId),
                                    );
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ),
                        ),
                      ),
                      const Divider(), // Divider between items
                    ],
                  );
                },
              );
            } else if (state is CategoryError) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            }
            return Center(child: Text('No Categories Available'));
          },
        ),
        // Custom Floating Action Button -------------------------------------->
        Positioned(
          bottom: 20,
          right: 20,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return AddCategoryPage();
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
    );
  }
}
