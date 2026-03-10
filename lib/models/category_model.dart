class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.order,
    this.userId,
  });

  final String id;
  final String name;
  final String type;
  final String? icon;
  final String? color;
  final int? order;
  final String? userId;

  factory CategoryModel.fromMap(String id, Map<String, dynamic> data) {
    return CategoryModel(
      id: id,
      name: data['name'] as String,
      type: data['type'] as String,
      icon: data['icon'] as String?,
      color: data['color'] as String?,
      order: data['order'] as int?,
      userId: data['userId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'order': order,
      'userId': userId,
    };
  }
}
