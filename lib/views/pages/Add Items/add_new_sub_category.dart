import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/category_bloc/bloc/cetagory_bloc.dart';
import 'package:pos_system_legphel/bloc/sub_category_bloc/bloc/sub_category_bloc.dart';
import 'package:pos_system_legphel/models/others/sub_category_model.dart';
import 'package:uuid/uuid.dart';

class AddNewSubCategory extends StatefulWidget {
  final SubcategoryModel? subcategory;

  const AddNewSubCategory({super.key, this.subcategory});

  @override
  State<AddNewSubCategory> createState() => _AddNewSubcategoryPageState();
}

class _AddNewSubcategoryPageState extends State<AddNewSubCategory> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  String? _selectedCategoryId;
  String _selectedAvailability = "1"; // Ensuring non-null initialization

  @override
  void initState() {
    super.initState();
    if (widget.subcategory != null) {
      _nameController.text = widget.subcategory!.subcategoryName;
      _selectedAvailability = widget.subcategory!.status;
      _selectedCategoryId = widget.subcategory!.categoryId;
    }
  }

  // Save the subcategory
  void _saveSubcategory(BuildContext context) {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      var uuid = const Uuid();

      final subcategory = SubcategoryModel(
        subcategoryId: widget.subcategory?.subcategoryId ?? uuid.v4(),
        subcategoryName: _nameController.text,
        categoryId: _selectedCategoryId!,
        status: _selectedAvailability,
      );

      if (widget.subcategory == null) {
        context.read<SubcategoryBloc>().add(
              AddSubcategory(subcategorylist: subcategory),
            );
      } else {
        context
            .read<SubcategoryBloc>()
            .add(UpdateSubcategory(subcategory: subcategory));
      }

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Please fill all fields, select a category, and choose an image."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subcategory == null
              ? "Add New Subcategory"
              : "Edit Subcategory",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 3, 27, 48),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.subcategory == null
                            ? "Subcategory Details"
                            : "Edit Subcategory Details",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 3, 27, 48),
                        ),
                      ),
                      const SizedBox(height: 15),

                      /// Subcategory Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Subcategory Name',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Enter subcategory name' : null,
                      ),
                      const SizedBox(height: 15),

                      /// Availability
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Availability (1 = Yes, 0 = No)',
                          prefixIcon: const Icon(Icons.check_circle),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        value: _selectedAvailability,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedAvailability = newValue!;
                          });
                        },
                        items: ["1", "0"]
                            .map((value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value == "1"
                                      ? "Available"
                                      : "Not Available"),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 15),

                      /// Category Dropdown
                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (state is CategoryError) {
                            return Center(child: Text(state.errorMessage));
                          } else if (state is CategoryLoaded) {
                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Main Category',
                                prefixIcon: const Icon(Icons.category),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              value: _selectedCategoryId,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCategoryId = newValue;
                                });
                              },
                              items: state.categories
                                  .map((category) => DropdownMenuItem(
                                        value: category.categoryId,
                                        child: Text(category.categoryName),
                                      ))
                                  .toList(),
                              validator: (value) =>
                                  value == null ? 'Select a category' : null,
                            );
                          }
                          return const Center(
                              child: Text('No categories found'));
                        },
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () => _saveSubcategory(context),
                        child: Text(widget.subcategory == null
                            ? "Add Subcategory"
                            : "Save Changes"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
