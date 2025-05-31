import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/produk.dart'; //

class ProdukService {
  final supabase = Supabase.instance.client;

  Future<List<Produk>> getSemuaProduk() async {
    final response = await supabase
        .from('produk')
        .select()
        .order('nama', ascending: true);

    return (response as List).map((data) => Produk.fromMap(data)).toList();
  }

  Future<void> tambahProduk(Produk produk) async {
    await supabase.from('produk').insert(produk.toMap());
  }

  Future<void> updateProduk(Produk produk) async {
    // Tambahkan update
    await supabase.from('produk').update(produk.toMap()).eq('id', produk.id);
  }

  Future<void> hapusProduk(String id) async {
    // Tambahkan delete
    await supabase.from('produk').delete().eq('id', id);
  }
}
