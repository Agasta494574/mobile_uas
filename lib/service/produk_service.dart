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
          .order('nama', ascending: true);

      return response.map((item) => Produk.fromMap(item)).toList();
    } catch (e) {
      print('Error fetching produk: $e');
      throw Exception('Gagal memuat data produk: $e');
    }
  }

  Future<void> tambahProduk(Produk produk) async {
    try {
      await supabase
          .from('produk')
          .insert(produk.toMapWithoutId()); // Memanggil toMapWithoutId()
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

  Future<void> hapusProduk(String id) async {
    try {
      await supabase.from('produk').delete().eq('id', id);
    } catch (e) {
      print('Error deleting produk: $e');
      throw Exception('Gagal menghapus produk: $e');
    }
  }
}
