class SubcategoryModel {
  final String subcategoryId;
  final String subcategoryName;
  final String categoryId;
  final String status;

  SubcategoryModel({
    required this.subcategoryId,
    required this.subcategoryName,
    required this.categoryId,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'subcategoryId': subcategoryId,
      'subcategoryName': subcategoryName,
      'categoryId': categoryId,
      'status': status,
    };
  }

  factory SubcategoryModel.fromMap(Map<String, dynamic> map) {
    return SubcategoryModel(
      subcategoryId: map['subcategoryId'],
      subcategoryName: map['subcategoryName'],
      categoryId: map['categoryId'],
      status: map['status'],
    );
  }
}
