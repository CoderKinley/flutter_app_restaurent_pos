class SearchSuggestionModel {
  final String menuId;
  final String menuName;

  SearchSuggestionModel({
    required this.menuId,
    required this.menuName,
  });

  Map<String, dynamic> toJson() {
    return {
      'menuId': menuId,
      'menuName': menuName,
    };
  }

  factory SearchSuggestionModel.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionModel(
      menuId: json['menuId'],
      menuName: json['menuName'],
    );
  }
}
