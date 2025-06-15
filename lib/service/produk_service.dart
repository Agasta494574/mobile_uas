// lib/service/produk_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/produk.dart';

final supabase = Supabase.instance.client; // Menggunakan instance global

class ProdukService {
  Future<List<Produk>> getSemuaProduk() async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('produk')
          .select()
          .eq('is_active', true) // <--- Hanya ambil produk yang aktif
          .order('nama', ascending: true);

      return response.map((item) => Produk.fromMap(item)).toList();
    } catch (e) {
      print('Error fetching produk: $e');
      throw Exception('Gagal memuat data produk: $e');
    }
  }

  Future<void> tambahProduk(Produk produk) async {
    try {
      await supabase.from('produk').insert(produk.toMapWithoutId());
    } catch (e) {
      print('Error adding produk: $e');
      throw Exception('Gagal menambahkan produk: $e');
    }
  }

  Future<void> updateStok(String id, int stokBaru) async {
    try {
      await supabase.from('produk').update({'stok': stokBaru}).eq('id', id);
    } catch (e) {
      print('Error updating stok: $e');
      throw Exception('Gagal memperbarui stok: $e');
    }
  }

  Future<void> updateProduk(Produk produk) async {
    try {
      await supabase.from('produk').update(produk.toMap()).eq('id', produk.id);
    } catch (e) {
      print('Error updating produk: $e');
      throw Exception('Gagal memperbarui produk: $e');
    }
  }

  // Ganti metode ini menjadi deactivateProduk
  Future<void> deactivateProduk(String id) async {
    // <--- Nama metode diubah
    try {
      await supabase
          .from('produk')
          .update({'is_active': false})
          .eq('id', id); // <--- Update kolom is_active
    } catch (e) {
      print('Error deactivating produk: $e'); // Log disesuaikan
      throw Exception('Gagal menonaktifkan produk: $e');
    }
  }

  // Hapus metode hapusProduk(String id) yang melakukan delete fisik jika ada
}
