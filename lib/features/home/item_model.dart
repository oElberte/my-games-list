/// Item model representing a game or item in the list
class Item {
  const Item({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
  });

  /// Creates an Item from JSON map
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
  final String id;
  final String name;
  final String description;
  final String? imageUrl;

  /// Converts Item to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  /// Creates a copy of this Item with given fields replaced with new values
  Item copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Item &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ description.hashCode ^ imageUrl.hashCode;

  @override
  String toString() =>
      'Item(id: $id, name: $name, description: $description, imageUrl: $imageUrl)';
}
