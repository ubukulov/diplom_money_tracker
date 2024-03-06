class Category{
  String name;
  String color;

  Category({required this.name, required this.color});


  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name:  json['name'] as String,
      color: json['color'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color,
    };
  }
}