import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
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
  bool _isSubmitting = false;

  // Apple-themed color palette
  final Color _primaryColor = const Color(0xFF4CAF50); // Apple green
  final Color _secondaryColor = const Color(0xFF8BC34A); // Light apple green
  final Color _accentColor = const Color(0xFFCDDC39); // Lime accent
  final Color _backgroundColor = const Color(0xFFF1F8E9); // Very light green
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF2E7D32); // Dark green
  final Color _errorColor = const Color(0xFFC62828); // Red for errors

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

      if (_selectedSubMenuType != null && _selectedSubMenuType!.isEmpty) {
        _selectedSubMenuType = null;
      }
    }
  }

  Future<void> _pickImage() async {
    var status = await Permission.photos.request();
    if (status.isGranted) {
      try {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          final directory = await getApplicationDocumentsDirectory();
          final fileName = path.basename(pickedFile.path);
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
        _showSnackBar("Failed to pick image: ${e.toString()}", isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? _errorColor : _primaryColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _saveProduct(BuildContext context) {
    if (!_formKey.currentState!.validate() || _selectedMenuType == null) {
      _showSnackBar("Please fill all fields and select a menu type.",
          isError: true);
      return;
    }

    if (_menuIdController.text.isEmpty) {
      _showSnackBar("Please enter a product ID", isError: true);
      return;
    }

    if (_nameController.text.isEmpty) {
      _showSnackBar("Please enter a product name", isError: true);
      return;
    }

    if (_priceController.text.isEmpty) {
      _showSnackBar("Please enter a price", isError: true);
      return;
    }

    if (double.tryParse(_priceController.text) == null) {
      _showSnackBar("Please enter a valid price", isError: true);
      return;
    }

    if (double.parse(_priceController.text) <= 0) {
      _showSnackBar("Price must be greater than 0", isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    _imagePath ??= "assets/icons/logo.png";

    var uuid = const Uuid();
    final product = MenuModel(
      uuid: widget.product?.uuid ?? uuid.v4(),
      menuName: _nameController.text.trim(),
      price: _priceController.text.trim(),
      availability: _selectedAvailability,
      description: _descriptionController.text.trim(),
      menuType: _selectedMenuType!,
      dishImage: _imagePath!,
      subMenuType: _selectedSubMenuType ?? '',
      menuId: _menuIdController.text.trim(),
    );

    print('Attempting to save product: ${product.toJson()}');

    if (widget.product == null) {
      context.read<MenuApiBloc>().add(AddMenuApiItem(product));
    } else {
      context.read<MenuApiBloc>().add(UpdateMenuApiItem(product));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.product == null ? "Add New Item" : "Edit Item",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            const Color.fromARGB(255, 3, 27, 48), // Kept original nav bar color
        foregroundColor: Colors.white,
      ),
      body: BlocListener<MenuApiBloc, MenuApiState>(
        listener: (context, state) {
          if (state is MenuApiLoading) {
            setState(() {
              _isSubmitting = true;
            });
          } else {
            setState(() {
              _isSubmitting = false;
            });

            if (state is MenuApiError) {
              _showSnackBar("Error: ${state.message}", isError: true);
            } else if (state is MenuApiLoaded) {
              _showSnackBar(
                widget.product == null
                    ? "Product added successfully!"
                    : "Product updated successfully!",
                isError: false,
              );

              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  Navigator.pop(context);
                }
              });
            }
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: _cardColor,
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
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                        ),
                        const SizedBox(height: 15),

                        TextFormField(
                          controller: _menuIdController,
                          decoration: InputDecoration(
                            labelText: 'Product ID',
                            labelStyle: TextStyle(color: _textColor),
                            prefixIcon: Icon(Icons.tag, color: _primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: _primaryColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: _primaryColor, width: 2),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter product ID' : null,
                        ),
                        const SizedBox(height: 15),

                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Product Name',
                            labelStyle: TextStyle(color: _textColor),
                            prefixIcon:
                                Icon(Icons.shopping_cart, color: _primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: _primaryColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: _primaryColor, width: 2),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter product name' : null,
                        ),
                        const SizedBox(height: 15),

                        TextFormField(
                          controller: _priceController,
                          decoration: InputDecoration(
                            labelText: 'Price',
                            labelStyle: TextStyle(color: _textColor),
                            prefixIcon: Icon(Icons.money, color: _primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: _primaryColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: _primaryColor, width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value!.isEmpty ? 'Enter price' : null,
                        ),
                        const SizedBox(height: 15),

                        DropdownButtonFormField<bool>(
                          decoration: InputDecoration(
                            labelText: 'Availability (1 = Yes, 0 = No)',
                            labelStyle: TextStyle(color: _textColor),
                            prefixIcon:
                                Icon(Icons.check_circle, color: _primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: _primaryColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: _primaryColor, width: 2),
                            ),
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
                                        value ? "Available" : "Not Available",
                                        style: TextStyle(color: _textColor)),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 15),

                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Product Description',
                            labelStyle: TextStyle(color: _textColor),
                            prefixIcon:
                                Icon(Icons.description, color: _primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: _primaryColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: _primaryColor, width: 2),
                            ),
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
                              final categories = state.categories;

                              return DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Menu Type',
                                  labelStyle: TextStyle(color: _textColor),
                                  prefixIcon: Icon(Icons.restaurant_menu,
                                      color: _primaryColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: _primaryColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: _primaryColor, width: 2),
                                  ),
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
                                          child: Text(category.categoryName,
                                              style:
                                                  TextStyle(color: _textColor)),
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

                              bool valueExists = false;
                              if (_selectedSubMenuType != null) {
                                valueExists = subcategories.any((category) =>
                                    category.subcategoryName ==
                                    _selectedSubMenuType);
                                if (!valueExists) {
                                  _selectedSubMenuType = null;
                                }
                              }

                              return DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Sub Menu Type',
                                  labelStyle: TextStyle(color: _textColor),
                                  prefixIcon: Icon(Icons.restaurant_menu,
                                      color: _primaryColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: _primaryColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: _primaryColor, width: 2),
                                  ),
                                ),
                                value: _selectedSubMenuType,
                                hint: Text('Select a sub menu type (optional)',
                                    style: TextStyle(
                                        color: _textColor.withOpacity(0.6))),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedSubMenuType = newValue;
                                  });
                                },
                                items: subcategories
                                    .map((category) => DropdownMenuItem(
                                          value: category.subcategoryName,
                                          child: Text(category.subcategoryName,
                                              style:
                                                  TextStyle(color: _textColor)),
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
                                          image: _imagePath!
                                                  .startsWith('assets/')
                                              ? AssetImage(_imagePath!)
                                                  as ImageProvider
                                              : FileImage(File(_imagePath!)),
                                          fit: BoxFit.cover,
                                        ),
                                        border: Border.all(
                                          color: _primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextButton.icon(
                                    icon:
                                        Icon(Icons.cancel, color: _errorColor),
                                    label: Text("Remove Image",
                                        style: TextStyle(color: _errorColor)),
                                    onPressed: () {
                                      setState(() {
                                        _imagePath = null;
                                      });
                                    },
                                  ),
                                ],
                              )
                            : Text('No image selected',
                                style: TextStyle(
                                    color: _textColor.withOpacity(0.6))),

                        const SizedBox(height: 10),

                        TextButton.icon(
                          icon: Icon(Icons.image, color: _primaryColor),
                          label: Text("Pick Image",
                              style: TextStyle(color: _primaryColor)),
                          onPressed: _pickImage,
                        ),

                        /// Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => _saveProduct(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    widget.product == null
                                        ? "Add Product"
                                        : "Save Changes",
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.white),
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
      ),
    );
  }
}
