import 'package:flutter/material.dart';

class SalsaModel {
  // Atributos
  final String id;
  final String name;
  final String color; // Hex string: #RRGGBB
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  // Constructor principal
  SalsaModel({
    required this.id,
    required this.name,
    required this.color,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  // Factory constructor desde Map (para cargar de BD)
  factory SalsaModel.fromMap(Map<String, dynamic> map) {
    return SalsaModel(
      id: map['salsa_id'] ?? '',
      name: map['name'] ?? '',
      color: map['color'] ?? '#FFFFFF',
      activo: map['activo'] == 1 ? true : false,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
    );
  }

  // Convertir a Map (para guardar en BD)
  Map<String, dynamic> toMap() {
    return {
      'salsa_id': id,
      'name': name,
      'color': color,
      'activo': activo ? 1 : 0,
      'created_at': createdAt?.toUtc().toString(),
      'updated_at': updatedAt?.toUtc().toString(),
      'deleted_at': deletedAt?.toUtc().toString(),
    };
  }

  // Convertir Color de Flutter a Hex string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  // Convertir Hex string a Color de Flutter
  static Color colorFromHex(String hexString) {
    try {
      var hex = hexString.trim();
      if (hex.isEmpty) return Colors.white;

      // Eliminar prefijos comunes
      if (hex.startsWith('#')) hex = hex.substring(1);
      if (hex.toLowerCase().startsWith('0x')) hex = hex.substring(2);

      // Normalizar a 8 dígitos ARGB
      if (hex.length == 6) {
        hex = 'FF$hex';
      }

      if (hex.length != 8) {
        // Valor no válido -> fallback seguro
        return Colors.white;
      }

      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.white;
    }
  }

  // Obtener imagen de preview del color
  Color getColorObject() {
    return colorFromHex(color);
  }

  // Copiar con cambios (para actualizar)
  SalsaModel copyWith({
    String? id,
    String? name,
    String? color,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return SalsaModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
