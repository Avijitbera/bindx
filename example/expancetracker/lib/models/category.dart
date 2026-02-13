import 'package:flutter/material.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double budgetLimit;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.budgetLimit = 0,
  });

  ExpenseCategory copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    double? budgetLimit,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      budgetLimit: budgetLimit ?? this.budgetLimit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'color': color.value,
      'budgetLimit': budgetLimit,
    };
  }

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'],
      name: json['name'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      budgetLimit: json['budgetLimit'] ?? 0,
    );
  }
}

// Predefined categories
class Categories {
  static const food = ExpenseCategory(
    id: 'food',
    name: 'Food',
    icon: Icons.restaurant,
    color: Colors.orange,
    budgetLimit: 5000,
  );

  static const transport = ExpenseCategory(
    id: 'transport',
    name: 'Transport',
    icon: Icons.directions_car,
    color: Colors.blue,
    budgetLimit: 3000,
  );

  static const shopping = ExpenseCategory(
    id: 'shopping',
    name: 'Shopping',
    icon: Icons.shopping_bag,
    color: Colors.pink,
    budgetLimit: 4000,
  );

  static const entertainment = ExpenseCategory(
    id: 'entertainment',
    name: 'Entertainment',
    icon: Icons.movie,
    color: Colors.purple,
    budgetLimit: 2000,
  );

  static const bills = ExpenseCategory(
    id: 'bills',
    name: 'Bills',
    icon: Icons.receipt_long,
    color: Colors.red,
    budgetLimit: 6000,
  );

  static const health = ExpenseCategory(
    id: 'health',
    name: 'Health',
    icon: Icons.local_hospital,
    color: Colors.green,
    budgetLimit: 3000,
  );

  static const education = ExpenseCategory(
    id: 'education',
    name: 'Education',
    icon: Icons.school,
    color: Colors.indigo,
    budgetLimit: 5000,
  );

  static const other = ExpenseCategory(
    id: 'other',
    name: 'Other',
    icon: Icons.more_horiz,
    color: Colors.grey,
    budgetLimit: 2000,
  );

  static List<ExpenseCategory> get all => [
    food,
    transport,
    shopping,
    entertainment,
    bills,
    health,
    education,
    other,
  ];

  static ExpenseCategory getById(String id) {
    return all.firstWhere((cat) => cat.id == id, orElse: () => other);
  }
}
