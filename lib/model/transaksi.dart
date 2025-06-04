// lib/model/transaksi.dart
class Transaksi {
  // <--- GANTI NAMA KELAS INI JIKA SEBELUMNYA Transaction
  final String id;
  final DateTime tanggal;
  final double totalBayar;
  final String? userId;

  Transaksi({
    // <--- GANTI NAMA KONSTRUKTOR INI JIKA SEBELUMNYA Transaction
    required this.id,
    required this.tanggal,
    required this.totalBayar,
    this.userId,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    // <--- GANTI NAMA FACTORY INI
    return Transaksi(
      // <--- GANTI NAMA KELAS INI
      id: json['id'] as String,
      tanggal: DateTime.parse(json['tanggal'] as String),
      totalBayar: (json['total_bayar'] as num).toDouble(),
      userId: json['user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal': tanggal.toIso8601String(),
      'total_bayar': totalBayar,
      'user_id': userId,
    };
  }
}
