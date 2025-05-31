class Transaksi {
  final String id;
  final String produkId;
  final int jumlah;
  final DateTime tanggal;

  Transaksi({
    required this.id,
    required this.produkId,
    required this.jumlah,
    required this.tanggal,
  });

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      id: map['id'],
      produkId: map['produk_id'],
      jumlah: map['jumlah'],
      tanggal: DateTime.parse(map['tanggal']), // Mengasumsikan string ISO 8601 dari Supabase
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'produk_id': produkId,
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
    };
  }
}