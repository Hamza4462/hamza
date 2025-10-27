class Treatment {
  int? id;
  final String name;
  final String? description;
  final double price;

  Treatment({this.id, required this.name, this.description, required this.price});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
    };
  }

  factory Treatment.fromMap(Map<String, dynamic> map) {
    return Treatment(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: (map['price'] is int) ? (map['price'] as int).toDouble() : (map['price'] as double),
    );
  }
}
