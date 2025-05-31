import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/produk.dart';

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

  Future<void> updateStok(String id, int stokBaru) async {
    await supabase.from('produk').update({'stok': stokBaru}).eq('id', id);
  }
}
