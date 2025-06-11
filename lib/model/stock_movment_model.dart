// lib/model/stock_movement.dart
import 'package:flutter/material.dart'; // Hanya untuk Icons jika diperlukan, tapi tidak langsung digunakan di sini
import 'package:intl/intl.dart'; // Untuk parsing tanggal jika string

class StockMovement {
  final String id;
  final String productId;
  final String? userId; // Nullable
  final String type; // 'in' or 'out'
  final int quantity;
  final String? reason; // Nullable
  final DateTime createdAt;

  // Nama produk dan harga jual produk dari join/fetch terpisah, bukan bagian dari model ini
  // Ini akan diisi ketika melakukan join di service atau provider
  final String? productName;
  final double? productSellingPrice;
  final double? productBuyingPrice; // Tambahkan ini untuk hitungan keuntungan

  StockMovement({
    required this.id,
    required this.productId,
    this.userId,
    required this.type,
    required this.quantity,
    this.reason,
    required this.createdAt,
    this.productName,
    this.productSellingPrice,
    this.productBuyingPrice, // Inisialisasi
  });

  factory StockMovement.fromMap(Map<String, dynamic> map) {
    return StockMovement(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      userId: map['user_id'] as String?,
      type: map['type'] as String,
      quantity: map['quantity'] as int,
      reason: map['reason'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      productName:
          map['produk'] != null ? map['produk']['nama'] as String : null,
      productSellingPrice:
          map['produk'] != null
              ? (map['produk']['harga_jual'] as num).toDouble()
              : null,
      productBuyingPrice:
          map['produk'] != null
              ? (map['produk']['harga_beli'] as num).toDouble()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'type': type,
      'quantity': quantity,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
