// lib/model/produk.dart
class Produk {
  final String id;
  final String kodeProduk;
  final String nama;
  final String deskripsi;
  final String kategori;
  final double hargaBeli;
  final double hargaJual;
  final int stok;
  final int stokMinimum;
  final String satuan;
  final bool isActive; // <--- Tambahkan ini

  Produk({
    required this.id, // ID ini akan digunakan untuk operasi UPDATE/DELETE
    required this.kodeProduk,
    required this.nama,
    required this.deskripsi,
    required this.kategori,
    required this.hargaBeli,
    required this.hargaJual,
    required this.stok,
    required this.stokMinimum,
    required this.satuan,
    this.isActive = true, // <--- Beri nilai default
  });

  factory Produk.fromMap(Map<String, dynamic> map) {
    return Produk(
      id: map['id'],
      kodeProduk: map['kode_produk'],
      nama: map['nama'],
      deskripsi: map['deskripsi'],
      kategori: map['kategori'],
      hargaBeli: (map['harga_beli'] as num).toDouble(),
      hargaJual: (map['harga_jual'] as num).toDouble(),
      stok: map['stok'],
      stokMinimum: map['stok_minimum'],
      satuan: map['satuan'],
      isActive:
          map['is_active'] ??
          true, // <--- Ambil nilai dari map, default true jika null
    );
  }

  Map<String, dynamic> toMap() {
    // Digunakan untuk update (menyertakan ID)
    return {
      'id': id,
      'kode_produk': kodeProduk,
      'nama': nama,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      'stok': stok,
      'stok_minimum': stokMinimum,
      'satuan': satuan,
      'is_active': isActive, // <--- Tambahkan ini
    };
  }

  Map<String, dynamic> toMapWithoutId() {
    // Digunakan untuk insert (tidak menyertakan ID)
    return {
      'kode_produk': kodeProduk,
      'nama': nama,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      'stok': stok,
      'stok_minimum': stokMinimum,
      'satuan': satuan,
      'is_active': isActive, // <--- Tambahkan ini
    };
  }
}
