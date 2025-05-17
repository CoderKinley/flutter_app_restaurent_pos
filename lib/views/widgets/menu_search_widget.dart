import 'package:flutter/material.dart';
import 'package:pos_system_legphel/models/others/new_menu_model.dart';

class MenuSearchWidget extends StatefulWidget {
  final List<MenuModel> menuItems;
  final Function(List<MenuModel>) onSearchResults;

  const MenuSearchWidget({
    super.key,
    required this.menuItems,
    required this.onSearchResults,
  });

  @override
  State<MenuSearchWidget> createState() => _MenuSearchWidgetState();
}

class _MenuSearchWidgetState extends State<MenuSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<MenuModel> _filteredItems = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.menuItems;
    _searchFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isSearching = _searchFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.menuItems;
      } else {
        _filteredItems = widget.menuItems
            .where((item) =>
                item.menuName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      widget.onSearchResults(_filteredItems);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterItems('');
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _filterItems,
            decoration: InputDecoration(
              hintText: 'Search menu items...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(
                Icons.search,
                color: _isSearching
                    ? Theme.of(context).primaryColor
                    : Colors.grey[500],
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[500]),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
