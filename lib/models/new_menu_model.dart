class MenuModel {
  final String menuId;
  final String menuName;
  final String menuType;
  final String? subMenuType;
  final String price;
  final String description;
  final bool availability;
  final String? dishImage;
  final String uuid;

  MenuModel({
    required this.menuId,
    required this.menuName,
    required this.menuType,
    this.subMenuType,
    required this.price,
    required this.description,
    required this.availability,
    this.dishImage,
    required this.uuid,
  });

  factory MenuModel.fromMap(Map<String, dynamic> map) {
    return MenuModel(
      menuId: map['menu_id'],
      menuName: map['menu_name'],
      menuType: map['menu_type'],
      subMenuType: map['sub_menu_type'],
      price: map['price'],
      description: map['description'],
      availability: map['availability'] == 1,
      dishImage: map['dish_image'],
      uuid: map['uuid'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menu_id': menuId,
      'menu_name': menuName,
      'menu_type': menuType,
      'sub_menu_type': subMenuType,
      'price': price,
      'description': description,
      'availability': availability ? 1 : 0,
      'dish_image': dishImage,
      'uuid': uuid,
    };
  }

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      menuId: json['menu_id'],
      menuName: json['menu_name'],
      menuType: json['menu_type'],
      subMenuType: json['sub_menu_type'],
      price: json['price'],
      description: json['description'],
      availability: json['availability'] == true,
      dishImage: json['dish_image'],
      uuid: json['uuid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'menu_name': menuName,
      'menu_type': menuType,
      'sub_menu_type': subMenuType,
      'price': price,
      'description': description,
      'availability': availability,
      'dish_image': dishImage,
      'uuid': uuid,
    };
  }
}
