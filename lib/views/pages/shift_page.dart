import 'package:flutter/material.dart';
import 'package:pos_system_legphel/views/widgets/drawer_widget.dart';

// Dummy Data Models
class Category {
  final String name;
  final List<String> subcategories;
  final List<Item> items;

  Category(this.name, {this.subcategories = const [], this.items = const []});
}

class Item {
  final String name;
  final double price;
  final String? description;

  Item(this.name, this.price, {this.description});
}

class ShiftPage extends StatefulWidget {
  const ShiftPage({super.key});

  @override
  State<ShiftPage> createState() => _ShiftPageState();
}

class _ShiftPageState extends State<ShiftPage> {
  // Dummy Data
  final List<Category> _categories = [
    Category('Soup', items: [
      Item('Manchow Soup (veg)', 8.2),
      Item('Hot & Sour Soup (veg)', 4.6),
      Item('Sweet corn Soup (veg)', 29.1),
    ]),
    Category('Starter', subcategories: [
      'Indian-Tandoor',
      'ORIENTAL',
      'DUMPLING'
    ], items: [
      Item('Chilli Chicken', 74.4),
      Item('Paneer Tikka', 100.0),
      Item('Veg Momo', 42.1),
    ]),
    Category('Main Course', subcategories: [
      'Indian Gravies',
      'Rice',
      'Bread'
    ], items: [
      Item('Paneer Butter Masala', 150.4),
      Item('Jeera Rice', 30.0),
      Item('Garlic Naan', 16.9),
    ]),
  ];

  final List<Item> _selectedItems = [];
  final Map<Item, TextEditingController> _quantityControllers = {};

  @override
  void dispose() {
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addToSelectedItems(Item item) {
    setState(() {
      if (!_selectedItems.contains(item)) {
        _selectedItems.add(item);
        _quantityControllers[item] = TextEditingController(text: '1');
      }
    });
  }

  void _removeItem(Item item) {
    setState(() {
      _selectedItems.remove(item);
      _quantityControllers[item]?.dispose();
      _quantityControllers.remove(item);
    });
  }

  double _calculateTotal() {
    return _selectedItems.fold(0.0, (sum, item) {
      final qty = int.tryParse(_quantityControllers[item]?.text ?? '1') ?? 1;
      return sum + (item.price * qty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("POS System")),
      drawer: const DrawerWidget(),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return ExpansionTile(
                  title: Text(category.name),
                  children: [
                    ...category.items.map((item) => ListTile(
                          title: Text(item.name),
                          onTap: () => _addToSelectedItems(item),
                        )),
                  ],
                );
              },
            ),
          ),
          Expanded(
            flex: 4,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _categories.expand((c) => c.items).length,
              itemBuilder: (context, index) {
                final item = _categories.expand((c) => c.items).toList()[index];
                return Card(
                  child: InkWell(
                    onTap: () => _addToSelectedItems(item),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style: Theme.of(context).textTheme.titleMedium),
                          const Spacer(),
                          Text('Nu ${item.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _selectedItems.length,
                    itemBuilder: (context, index) {
                      final item = _selectedItems[index];
                      final qty = int.tryParse(
                              _quantityControllers[item]?.text ?? '1') ??
                          1;
                      return ListTile(
                        title: Text(item.name),
                        subtitle:
                            Text('Nu ${(item.price * qty).toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(item),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: Nu ${_calculateTotal().toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.payment),
                        label: const Text("Checkout"),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
