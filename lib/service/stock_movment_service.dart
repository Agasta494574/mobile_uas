// lib/service/stock_movement_service.dart
import 'package:mobile_uas/model/stock_movment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StockMovementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> addStockMovement(StockMovement movement) async {
    try {
      await _supabase.from('stock_movements').insert(movement.toMap());
    } catch (e) {
      print('Error adding stock movement: $e');
      throw Exception('Gagal menambahkan pergerakan stok: $e');
    }
  }

  // Mengambil pergerakan stok dengan informasi produk terkait
  Future<List<StockMovement>> getStockMovements({int? limit}) async {
    try {
      var query = _supabase
          .from('stock_movements')
          .select(
            '*, produk(nama, harga_jual, harga_beli)',
          ) // Join dengan tabel produk
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) => StockMovement.fromMap(json))
          .toList();
    } catch (e) {
      print('Error fetching stock movements: $e');
      throw Exception('Gagal memuat pergerakan stok: $e');
    }
  }

  // Metode untuk mendapatkan stok masuk hari ini
  Future<int> getStockInToday() async {
    try {
      final today = DateTime.now().toIso8601String().substring(
        0,
        10,
      ); // Format YYYY-MM-DD
      final response = await _supabase
          .from('stock_movements')
          .select('quantity')
          .eq('type', 'in')
          .gte('created_at', '$today 00:00:00')
          .lte('created_at', '$today 23:59:59');

      int total = 0;
      for (var item in response) {
        total += item['quantity'] as int;
      }
      return total;
    } catch (e) {
      print('Error fetching stock in today: $e');
      return 0; // Kembalikan 0 jika ada error
    }
  }

  // Metode untuk mendapatkan stok keluar hari ini (dari stock_movements, bukan penjualan)
  Future<int> getStockOutToday() async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final response = await _supabase
          .from('stock_movements')
          .select('quantity')
          .eq('type', 'out')
          .gte('created_at', '$today 00:00:00')
          .lte('created_at', '$today 23:59:59');

      int total = 0;
      for (var item in response) {
        total += item['quantity'] as int;
      }
      return total;
    } catch (e) {
      print('Error fetching stock out today: $e');
      return 0; // Kembalikan 0 jika ada error
    }
  }
}
