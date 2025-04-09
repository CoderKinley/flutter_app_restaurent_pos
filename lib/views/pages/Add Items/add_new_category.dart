import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/category_bloc/bloc/cetagory_bloc.dart';
import 'package:pos_system_legphel/models/others/category_model.dart';
import 'package:uuid/uuid.dart';

class AddCategoryPage extends StatefulWidget {
  final CategoryModel? categoryModel;

  const AddCategoryPage({
    super.key,
    this.categoryModel,
  });

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  String _status = 'active';
  String _categoryId = "noiD";

  final _categoryNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.categoryModel != null) {
      _categoryNameController.text = widget.categoryModel!.categoryName;
      _status = widget.categoryModel!.status;
      _categoryId = widget.categoryModel!.categoryId;
    }
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newCategory = CategoryModel(
        categoryId: const Uuid().v4().toString(),
        categoryName: _categoryNameController.text,
        status: _status,
      );

      context.read<CategoryBloc>().add(AddCategory(newCategory));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category Added Successfully!')),
      );

      Navigator.pop(context);
    }
  }

  void _editFrorm() {
    print("Category:::");
    print(_categoryNameController.text.toString());
    final newCategory = CategoryModel(
      categoryId: _categoryId,
      categoryName: _categoryNameController.text,
      status: _status,
    );

    context.read<CategoryBloc>().add(UpdateCategory(newCategory));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Editded Successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Category'),
      ),
      body: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _categoryNameController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _status,
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                  items: ['active', 'inactive']
                      .map((status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  decoration: const InputDecoration(labelText: 'Status'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a status';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed:
                        widget.categoryModel == null ? _submitForm : _editFrorm,
                    child: Text(
                      widget.categoryModel == null
                          ? 'Add Category'
                          : "Edit Category",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
