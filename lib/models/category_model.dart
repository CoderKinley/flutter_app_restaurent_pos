class CategoryModel {
  final String categoryId;
  final String categoryName;
  final String status; // active or inactive from the category
  final int sortOrder;

  CategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.status,
    required this.sortOrder,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'status': status,
      'sortOrder': sortOrder,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      categoryId: map['categoryId'],
      categoryName: map['categoryName'],
      status: map['status'],
      sortOrder: map['sortOrder'],
    );
  }
}
