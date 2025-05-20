class Destination {
  final int? id;
  final String name;

  Destination({
    this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'],
      name: map['name'],
    );
  }
}
