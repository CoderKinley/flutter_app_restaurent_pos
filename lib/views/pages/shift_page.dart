import 'package:flutter/material.dart';
import 'package:pos_system_legphel/views/widgets/drawer_widget.dart';

class ShiftPage extends StatefulWidget {
  const ShiftPage({super.key});

  @override
  State<ShiftPage> createState() => _ShiftPageState();
}

class PanelItem {
  final String title;
  final String content;
  bool isExpanded;

  PanelItem(
      {required this.title, required this.content, this.isExpanded = false});
}

class _ShiftPageState extends State<ShiftPage> {
  final List<PanelItem> _items = List.generate(
    3,
    (index) => PanelItem(
      title: "Tile ${index + 1}",
      content: "Content for tile ${index + 1}",
    ),
  );

  void _toggleExpansion(int index) {
    setState(() {
      for (int i = 0; i < _items.length; i++) {
        _items[i].isExpanded = i == index ? !_items[i].isExpanded : false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("POS System")),
      drawer: const DrawerWidget(),
      body: SingleChildScrollView(
        child: ExpansionPanelList(
          expansionCallback: (index, isExpanded) {
            _toggleExpansion(index);
          },
          children: _items.asMap().entries.map((entry) {
            int index = entry.key;
            PanelItem item = entry.value;
            return ExpansionPanel(
              headerBuilder: (context, isExpanded) {
                return InkWell(
                  onTap: () => _toggleExpansion(index),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(item.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                );
              },
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(item.content),
              ),
              isExpanded: item.isExpanded,
            );
          }).toList(),
        ),
      ),
    );
  }
}
