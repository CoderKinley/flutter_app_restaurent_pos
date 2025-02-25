import 'package:flutter/material.dart';

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
        Center(child: Text("This is the main screen content")),

        // Custom Floating Action Button -------------------------------------->
        Positioned(
          bottom: 20,
          right: 20,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 3, 27, 48),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(Icons.add, color: Colors.white, size: 32),
            ),
          ),
        ),
      ],
    );
  }
}
