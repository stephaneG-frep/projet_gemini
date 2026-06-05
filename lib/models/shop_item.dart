import 'package:flutter/material.dart';

class ShopItem {
  const ShopItem({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.iconName,
    this.isPurchased = false,
    this.isEquipped = false,
  });

  factory ShopItem.fromMap(Map<dynamic, dynamic> map) => ShopItem(
        id: map['id'] as String,
        name: map['name'] as String,
        price: map['price'] as int,
        description: map['description'] as String,
        iconName: map['iconName'] as String? ?? 'sparkle',
        isPurchased: map['isPurchased'] as bool? ?? false,
        isEquipped: map['isEquipped'] as bool? ?? false,
      );

  final String id;
  final String name;
  final int price;
  final String description;
  final String iconName;
  final bool isPurchased;
  final bool isEquipped;

  IconData get icon {
    return switch (iconName) {
      'school' => Icons.school,
      'sparkle' => Icons.auto_awesome,
      'shield' => Icons.shield,
      'timer' => Icons.timer,
      _ => Icons.auto_awesome,
    };
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'iconName': iconName,
        'isPurchased': isPurchased,
        'isEquipped': isEquipped,
      };

  ShopItem copyWith({bool? isPurchased, bool? isEquipped}) => ShopItem(
        id: id,
        name: name,
        price: price,
        description: description,
        iconName: iconName,
        isPurchased: isPurchased ?? this.isPurchased,
        isEquipped: isEquipped ?? this.isEquipped,
      );
}
