import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/SQL/database_helper.dart';
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
                                _confirmDeleteCategory(context,
                                    category.categoryId, category.categoryName);
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
            return const Center(child: Text('No Categories Available'));
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
                  return const AddCategoryPage();
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

// Function to show confirmation dialog
  void _confirmDeleteCategory(
      BuildContext context, String categoryId, String CategoryName) async {
    final isUsed = await DatabaseHelper.instance.isCategoryUsed(CategoryName);

    if (isUsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Cannot delete category: It is associated with products."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Category"),
          content: const Text("Are you sure you want to delete this category?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                context
                    .read<CategoryBloc>()
                    .add(DeleteCategory(categoryId)); // Delete the category
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
