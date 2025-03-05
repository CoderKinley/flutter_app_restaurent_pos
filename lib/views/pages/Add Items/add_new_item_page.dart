import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_item_local_bloc/bloc/menu_items_bloc.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_items_model_local_stg.dart';
import 'package:uuid/uuid.dart';

class AddNewItemPage extends StatefulWidget {
  final Product? product;

  const AddNewItemPage({super.key, this.product});

  @override
  State<AddNewItemPage> createState() => _AddNewItemPageState();
}

class _AddNewItemPageState extends State<AddNewItemPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _imagePath;
  String? _selectedAvailability = "1";
  String? _selectedMenuType;

  //  fetch from the database of Local storage after fully calculating it
  final List<String> _menuTypes = [
    "Main Course",
    "Drinks",
    "Desserts",
    "Snacks",
    "Breakfast",
    "Combo Meal",
    "Starter",
    "Veg Thali",
    "Non-Veg Thali",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _descriptionController.text = widget.product!.description;
      _imagePath = widget.product!.image;
      _selectedAvailability = widget.product!.availiability.toString();
      _selectedMenuType = widget.product!.menutype;
    }
  }

  // for picking up the image from the gallery for the purpose of adding the image file to the data base
  Future<void> _pickImage() async {
    var status = await Permission.photos.request();
    if (status.isGranted) {
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
    }
  }

  // save the product to the local database that i have created earlier
  void _saveProduct(BuildContext context) {
    if (_formKey.currentState!.validate() &&
        _imagePath != null &&
        _selectedMenuType != null) {
      var uuid = const Uuid();

      final product = Product(
        id: widget.product?.id ?? uuid.v4(), // Assign UUID if new product
        name: _nameController.text,
        price: int.parse(_priceController.text),
        availiability: int.parse(_selectedAvailability!),
        description: _descriptionController.text,
        menutype: _selectedMenuType!,
        image: _imagePath!,
      );

      if (widget.product == null) {
        context.read<ProductBloc>().add(AddProduct(product));
      } else {
        context.read<ProductBloc>().add(UpdateProduct(product));
      }

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Please fill all fields, select a menu type, and choose an image."),
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
                            _selectedAvailability = newValue;
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

                      /// Menu Type
                      DropdownButtonFormField<String>(
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
                        items: _menuTypes
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        validator: (value) =>
                            value == null ? 'Select a menu type' : null,
                      ),

                      const SizedBox(height: 15.0),

                      /// Image Picker
                      _imagePath != null
                          ? Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(File(_imagePath!),
                                      height: 120, fit: BoxFit.cover),
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
