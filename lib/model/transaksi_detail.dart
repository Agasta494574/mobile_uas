// lib/model/transaksi_detail.dart
class TransaksiDetail {
  // <--- GANTI NAMA KELAS INI JIKA SEBELUMNYA TransactionDetail
  final String id;
  final String transaksiId;
  final String produkId;
  final int jumlah;
  final double subtotal;
  final String productName;
  final double productPricePerUnit;
  final double?
  productBuyingPrice; // <--- BARU: Untuk perhitungan keuntungan di frontend
  final DateTime
  createdAt; // <--- BARU: Penting untuk filter waktu penjualan produk terlaris

  TransaksiDetail({
    // <--- GANTI NAMA KONSTRUKTOR INI JIKA SEBELUMNYA TransactionDetail
    required this.id,
    required this.transaksiId,
    required this.produkId,
    required this.jumlah,
    required this.subtotal,
    required this.productName,
    required this.productPricePerUnit,
    this.productBuyingPrice, // <--- BARU
    required this.createdAt, // <--- BARU
  });

  factory TransaksiDetail.fromJson(Map<String, dynamic> json) {
    // <--- GANTI NAMA FACTORY INI
    return TransaksiDetail(
      // <--- GANTI NAMA KELAS INI
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
      productBuyingPrice: // <--- BARU
          json['produk'] != null
              ? (json['produk']['harga_beli'] as num).toDouble()
              : 0.0,
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ), // <--- BARU: Asumsi kolom ini ada di Supabase
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
