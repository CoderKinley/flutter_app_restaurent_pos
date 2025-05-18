import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/search_suggestion_bloc/bloc/search_suggestion_bloc.dart';
import 'package:pos_system_legphel/models/others/new_menu_model.dart';
import 'package:pos_system_legphel/models/search/search_suggestion_model.dart';

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
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

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
    if (_searchFocusNode.hasFocus) {
      _showSuggestions();
    } else {
      _hideSuggestions();
    }
  }

  void _showSuggestions() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSuggestions() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: BlocBuilder<SearchSuggestionBloc, SearchSuggestionState>(
              builder: (context, state) {
                if (state is SearchSuggestionLoading) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is SearchSuggestionLoaded) {
                  if (state.suggestions.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: state.suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = state.suggestions[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            suggestion.menuName,
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () {
                            _searchController.text = suggestion.menuName;
                            _filterItems(suggestion.menuName);
                            _hideSuggestions();
                            _searchFocusNode.unfocus();
                          },
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    _hideSuggestions();
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

      // Update suggestions based on current query
      context.read<SearchSuggestionBloc>().add(
            UpdateSearchSuggestions(
              query: query,
              menuItems: widget.menuItems,
            ),
          );
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterItems('');
    _searchFocusNode.unfocus();
    _hideSuggestions();
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
          child: CompositedTransformTarget(
            link: _layerLink,
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
      ),
    );
  }
}
