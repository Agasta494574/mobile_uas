class Produk {
  final String id;
  final String nama;
  final double harga;
  final int stok;

  Produk({
    required this.id,
    required this.nama,
    required this.harga,
    required this.stok,
  });

  factory Produk.fromMap(Map<String, dynamic> map) {
    return Produk(
      id: map['id'],
      nama: map['nama'],
      harga: (map['harga'] as num).toDouble(),
      stok: map['stok'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'nama': nama, 'harga': harga, 'stok': stok};
  }
}
