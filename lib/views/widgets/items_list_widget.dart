import 'package:flutter/material.dart';

class ItemsListWidget extends StatelessWidget {
  const ItemsListWidget({
    super.key,
    required this.item,
    required this.page,
    required this.icon,
  });

  final String item;
  final Icon icon;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: Text(item),
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
