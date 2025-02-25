// Model Class
class Product {
  String? id;
  String name;
  String description;
  String menutype;
  int price;
  String image;
  int availiability;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.menutype,
    required this.price,
    required this.image,
    required this.availiability,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'menutype': menutype,
      'availiability': availiability,
      'image': image,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      description: map['description'],
      menutype: map['menutype'],
      name: map['name'],
      price: map['price'],
      availiability: map['availiability'],
      image: map['image'],
    );
  }
}
