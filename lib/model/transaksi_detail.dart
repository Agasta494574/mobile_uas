// lib/model/transaksi_detail.dart
class TransaksiDetail {
  final String id;
  final String transaksiId;
  final String produkId;
  final int jumlah;
  final double subtotal;
  final String productName;
  final double productPricePerUnit;
  final double? productBuyingPrice; // Tambahkan ini jika belum ada
  final DateTime createdAt; // <--- BARU

  TransaksiDetail({
    required this.id,
    required this.transaksiId,
    required this.produkId,
    required this.jumlah,
    required this.subtotal,
    required this.productName,
    required this.productPricePerUnit,
    this.productBuyingPrice, // Tambahkan di konstruktor
    required this.createdAt, // <--- BARU
  });

  factory TransaksiDetail.fromJson(Map<String, dynamic> json) {
    return TransaksiDetail(
      id: json['id'] as String,
      transaksiId: json['transaksi_id'] as String,
      produkId: json['produk_id'] as String,
      jumlah: json['jumlah'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      productName:
          json['produk'] != null ? json['produk']['nama'] as String : 'N/A',
      productPricePerUnit:
          json['produk'] != null
              ? (json['produk']['harga_jual'] as num).toDouble()
              : 0.0,
      productBuyingPrice:
          json['produk'] != null
              ? (json['produk']['harga_beli'] as num).toDouble()
              : null, // Tambahkan ini
      createdAt: DateTime.parse(json['created_at'] as String), // <--- BARU
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaksi_id': transaksiId,
      'produk_id': produkId,
      'jumlah': jumlah,
      'subtotal': subtotal,
      'created_at': createdAt.toIso8601String(), // <--- BARU
    };
  }
}
