import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/category_bloc/bloc/cetagory_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_from_api/bloc/menu_from_api_bloc.dart';
import 'package:pos_system_legphel/bloc/sub_category_bloc/bloc/sub_category_bloc.dart';
import 'package:pos_system_legphel/models/others/new_menu_model.dart';
import 'package:uuid/uuid.dart';

class AddNewItemPage extends StatefulWidget {
  final MenuModel? product;

  const AddNewItemPage({super.key, this.product});

  @override
  State<AddNewItemPage> createState() => _AddNewItemPageState();
}

class _AddNewItemPageState extends State<AddNewItemPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _menuIdController = TextEditingController();

  String? _imagePath;
  bool _selectedAvailability = true;
  String? _selectedMenuType;
  String? _selectedSubMenuType;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.menuName;
      _menuIdController.text = widget.product!.menuId;
      _priceController.text = widget.product!.price.toString();
      _descriptionController.text = widget.product!.description;
      _imagePath = (widget.product!.dishImage != null &&
              widget.product!.dishImage!.isNotEmpty &&
              widget.product!.dishImage! != "No Image")
          ? widget.product!.dishImage
          : "assets/icons/logo.png";

      _selectedAvailability = widget.product!.availability;
      _selectedMenuType = widget.product!.menuType;
      _selectedSubMenuType = widget.product!.subMenuType;

      // If subMenuType is empty string, set it to null to avoid dropdown error
      if (_selectedSubMenuType != null && _selectedSubMenuType!.isEmpty) {
        _selectedSubMenuType = null;
      }
    }
  }

  // for picking up the image from the gallery for the purpose of adding the image file to the data base
  Future<void> _pickImage() async {
    var status = await Permission.photos.request();
    if (status.isGranted) {
      try {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          final directory = await getApplicationDocumentsDirectory();
          final fileName = basename(pickedFile.path);
          final savedImage =
              await File(pickedFile.path).copy('${directory.path}/$fileName');
          if (mounted) {
            setState(() {
              _imagePath = savedImage.path;
            });
          }
        }
      } catch (e) {
        print(e);
      }
    }
  }

  // save the product to the local database that i have created earlier
  void _saveProduct(BuildContext context) {
    if (_formKey.currentState!.validate() && _selectedMenuType != null) {
      _imagePath ??= "assets/icons/logo.png";

      var uuid = const Uuid();
      final product = MenuModel(
        uuid: widget.product?.uuid ?? uuid.v4(),
        menuName: _nameController.text,
        price: _priceController.text,
        availability: _selectedAvailability,
        description: _descriptionController.text,
        menuType: _selectedMenuType!,
        dishImage: _imagePath!,
        subMenuType:
            _selectedSubMenuType ?? '', // Provide a default empty string
        menuId: _menuIdController.text,
      );

      if (widget.product == null) {
        context.read<MenuBlocApi>().add(AddMenuApiItem(product));
      } else {
        context.read<MenuBlocApi>().add(UpdateMenuApiItem(product));
      }

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and select a menu type."),
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
          widget.product == null ? "Add New Item" : "Edit Item",
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
              elevation: 5, // Adds shadow
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
                        widget.product == null
                            ? "Product Details"
                            : "Edit Product Details",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 3, 27, 48),
                        ),
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: _menuIdController,
                        decoration: InputDecoration(
                          labelText: 'Product ID',
                          prefixIcon: const Icon(Icons.tag),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Enter product ID' : null,
                      ),
                      const SizedBox(height: 15),

                      /// Product Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                          prefixIcon: const Icon(Icons.shopping_cart),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Enter product name' : null,
                      ),
                      const SizedBox(height: 15),

                      /// Price
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          prefixIcon: const Icon(Icons.money),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter price' : null,
                      ),
                      const SizedBox(height: 15),

                      /// Availability
                      DropdownButtonFormField<bool>(
                        decoration: InputDecoration(
                          labelText: 'Availability (1 = Yes, 0 = No)',
                          prefixIcon: const Icon(Icons.check_circle),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        value: _selectedAvailability,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _selectedAvailability = newValue!;
                          });
                        },
                        items: [true, false]
                            .map((value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                      value ? "Available" : "Not Available"),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 15),

                      /// Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Product Description',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        maxLines: 3,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter description' : null,
                      ),
                      const SizedBox(height: 15),

                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (state is CategoryError) {
                            return Center(child: Text(state.errorMessage));
                          } else if (state is CategoryLoaded) {
                            // Use the fetched categories to populate the dropdown
                            final categories = state.categories;

                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Menu Type',
                                prefixIcon: const Icon(Icons.restaurant_menu),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              value: _selectedMenuType,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedMenuType = newValue;
                                });
                              },
                              items: categories
                                  .map((category) => DropdownMenuItem(
                                        value: category.categoryName,
                                        child: Text(category.categoryName),
                                      ))
                                  .toList(),
                              validator: (value) =>
                                  value == null ? 'Select a menu type' : null,
                            );
                          } else {
                            return const Center(
                                child: Text('No categories found'));
                          }
                        },
                      ),

                      const SizedBox(height: 15.0),
                      BlocBuilder<SubcategoryBloc, SubcategoryState>(
                        builder: (context, state) {
                          if (state is CategoryLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (state is CategoryError) {
                            return const Center(child: Text("Error Loading"));
                          } else if (state is SubcategoryLoaded) {
                            final subcategories = state.subcategories;

                            // Check if selected subMenuType exists in the list
                            bool valueExists = false;
                            if (_selectedSubMenuType != null) {
                              valueExists = subcategories.any((category) =>
                                  category.subcategoryName ==
                                  _selectedSubMenuType);
                              if (!valueExists) {
                                // If not found in list, set to null to avoid dropdown error
                                _selectedSubMenuType = null;
                              }
                            }

                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Sub Menu Type',
                                prefixIcon: const Icon(Icons.restaurant_menu),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              value: _selectedSubMenuType,
                              hint: const Text(
                                  'Select a sub menu type (optional)'),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedSubMenuType = newValue;
                                });
                              },
                              items: subcategories
                                  .map((category) => DropdownMenuItem(
                                        value: category.subcategoryName,
                                        child: Text(category.subcategoryName),
                                      ))
                                  .toList(),
                            );
                          } else {
                            return const Center(
                                child: Text('No sub categories found'));
                          }
                        },
                      ),
                      const SizedBox(height: 15.0),

                      /// Image Picker
                      _imagePath != null
                          ? Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: _imagePath!.startsWith('assets/')
                                            ? AssetImage(_imagePath!)
                                                as ImageProvider
                                            : FileImage(File(_imagePath!)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextButton.icon(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.red),
                                  label: const Text("Remove Image",
                                      style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    setState(() {
                                      _imagePath =
                                          null; // Clear the selected image
                                    });
                                  },
                                ),
                              ],
                            )
                          : const Text('No image selected',
                              style: TextStyle(color: Colors.grey)),

                      const SizedBox(height: 10),

                      TextButton.icon(
                        icon: const Icon(Icons.image,
                            color: Color.fromARGB(255, 3, 27, 48)),
                        label: const Text("Pick Image",
                            style: TextStyle(
                                color: Color.fromARGB(255, 3, 27, 48))),
                        onPressed: _pickImage,
                      ),

                      /// Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _saveProduct(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            widget.product == null
                                ? "Add Product"
                                : "Save Changes",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
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
