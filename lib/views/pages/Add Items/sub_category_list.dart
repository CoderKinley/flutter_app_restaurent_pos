import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/sub_category_bloc/bloc/sub_category_bloc.dart';
import 'package:pos_system_legphel/views/pages/Add%20Items/add_new_sub_category.dart';

class SubCategoryList extends StatefulWidget {
  const SubCategoryList({super.key});

  @override
  State<SubCategoryList> createState() => _AllItemsListState();
}

class _AllItemsListState extends State<SubCategoryList> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<SubcategoryBloc>().add(LoadAllSubcategory());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          BlocBuilder<SubcategoryBloc, SubcategoryState>(
              builder: (context, state) {
            if (state is SubcategoryLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is SubcategoryLoaded) {
              return ListView.builder(
                itemCount: state.subcategories.length,
                itemBuilder: (context, index) {
                  final subcategory = state.subcategories[index];
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return AddNewSubCategory(
                                subcategory: subcategory,
                              );
                            },
                          ));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 8.0, right: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            title: Text(subcategory.subcategoryName),
                            trailing: IconButton(
                              onPressed: () {
                                context.read<SubcategoryBloc>().add(
                                    DeleteSubcategory(
                                        subcategoryId:
                                            subcategory.subcategoryId,
                                        categoryId: subcategory.categoryId));
                              },
                              icon: const Icon(Icons.delete),
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
          }),
          // Custom Floating Action Button ------------------------------->
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const AddNewSubCategory();
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
