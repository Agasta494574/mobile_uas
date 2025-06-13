// lib/service/transaksi_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/transaksi.dart';
import '../model/transaksi_detail.dart';

class TransactionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Mengambil semua transaksi dari tabel 'transaksi'
  Future<List<Transaksi>> getTransactions() async {
    try {
      final response = await _supabase
          .from('transaksi')
          .select()
          .order('tanggal', ascending: false); // Urutkan dari yang terbaru

      if (response == null) {
        throw Exception('Tidak ada data transaksi yang ditemukan.');
      }

      return (response as List)
          .map((json) => Transaksi.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getTransactions: $e');
      throw Exception('Gagal mengambil data transaksi: $e');
    }
  }

  // Menambahkan transaksi baru dan detailnya secara bersamaan (gunakan transaksi database Supabase)
  Future<void> addTransactionWithDetails(
    Transaksi transaction,
    List<TransaksiDetail> details,
  ) async {
    try {
      // Insert transaksi utama
      final insertedTransaction =
          await _supabase
              .from('transaksi')
              .insert(transaction.toJson())
              .select() // Ambil kembali data yang baru diinsert, termasuk ID
              .single();

      final String newTransactionId = insertedTransaction['id'];

      // Siapkan data detail untuk diinsert
      final List<Map<String, dynamic>> detailsToInsert =
          details.map((detail) {
            return {
              'transaksi_id': newTransactionId,
              'produk_id': detail.produkId,
              'jumlah': detail.jumlah,
              'subtotal': detail.subtotal,
              'created_at':
                  DateTime.now()
                      .toIso8601String(), // <--- Pastikan kolom ini ada di DB transaksi_detail
            };
          }).toList();

      // Insert semua detail transaksi
      await _supabase.from('transaksi_detail').insert(detailsToInsert);
    } catch (e) {
      print('Error addTransactionWithDetails: $e');
      throw Exception('Gagal menambahkan transaksi dan detail: $e');
    }
  }

  // Mengambil detail transaksi untuk transaksi tertentu
  Future<List<TransaksiDetail>> getTransactionDetails(
    String transactionId,
  ) async {
    try {
      // Lakukan JOIN dengan tabel 'produk' untuk mendapatkan nama dan harga jual produk
      final response = await _supabase
          .from('transaksi_detail')
          .select(
            '*, produk(nama, harga_jual, harga_beli)',
          ) // Join ke tabel produk, ambil harga_beli juga
          .eq('transaksi_id', transactionId)
          .order('id', ascending: true); // Urutkan berdasarkan ID detail

      if (response == null) {
        throw Exception(
          'Tidak ada detail transaksi yang ditemukan untuk ID: $transactionId.',
        );
      }

      return (response as List)
          .map((json) => TransaksiDetail.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getTransactionDetails: $e');
      throw Exception('Gagal mengambil detail transaksi: $e');
    }
  }

  // --- Metode Baru untuk Dashboard Home ---

  Future<double> getOmsetToday() async {
    try {
      final today = DateTime.now().toIso8601String().substring(
        0,
        10,
      ); // Format YYYY-MM-DD
      final response = await _supabase
          .from('transaksi')
          .select('total_bayar')
          .gte('tanggal', '$today 00:00:00')
          .lte('tanggal', '$today 23:59:59');

      double totalOmset = 0;
      for (var item in response) {
        totalOmset += (item['total_bayar'] as num).toDouble();
      }
      return totalOmset;
    } catch (e) {
      print('Error fetching omset today: $e');
      return 0.0;
    }
  }

  Future<double> getKeuntunganToday() async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      // Ambil detail transaksi yang 'created_at' hari ini
      final response = await _supabase
          .from('transaksi_detail')
          .select(
            'jumlah, produk(harga_jual, harga_beli)',
          ) // Ambil jumlah, dan harga jual/beli dari produk
          .gte(
            'created_at',
            '$today 00:00:00',
          ) // Filter berdasarkan created_at di transaksi_detail
          .lte('created_at', '$today 23:59:59');

      double totalKeuntungan = 0;
      for (var item in response) {
        final jumlah = item['jumlah'] as int;
        final hargaJual = (item['produk']['harga_jual'] as num).toDouble();
        final hargaBeli = (item['produk']['harga_beli'] as num).toDouble();
        totalKeuntungan += (hargaJual - hargaBeli) * jumlah;
      }
      return totalKeuntungan;
    } catch (e) {
      print('Error fetching keuntungan today: $e');
      return 0.0;
    }
  }

  // Metode baru untuk mendapatkan data produk terjual dalam periode waktu
  Future<List<Map<String, dynamic>>> getTopSellingProducts({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5, // Batasi jumlah produk teratas
  }) async {
    try {
      final response = await _supabase
          .from('transaksi_detail')
          .select(
            'produk_id, jumlah, produk(nama, harga_jual, harga_beli)',
          ) // Ambil data produk
          .gte(
            'created_at',
            startDate.toIso8601String(),
          ) // Filter berdasarkan created_at di transaksi_detail
          .lte('created_at', endDate.toIso8601String())
          .order(
            'jumlah',
            ascending: false,
          ); // Urutkan berdasarkan jumlah terjual

      // Agregasi data jika ada duplikat produk_id
      Map<String, Map<String, dynamic>> aggregatedData = {};
      for (var item in response) {
        final productId = item['produk_id'] as String;
        final quantity = item['jumlah'] as int;
        final productName = item['produk']['nama'] as String;
        final hargaJual = (item['produk']['harga_jual'] as num).toDouble();
        final hargaBeli = (item['produk']['harga_beli'] as num).toDouble();

        if (aggregatedData.containsKey(productId)) {
          aggregatedData[productId]!['total_quantity'] += quantity;
          aggregatedData[productId]!['total_omset'] += quantity * hargaJual;
          aggregatedData[productId]!['total_profit'] +=
              quantity * (hargaJual - hargaBeli);
        } else {
          aggregatedData[productId] = {
            'produk_id': productId,
            'product_name': productName,
            'total_quantity': quantity,
            'total_omset': quantity * hargaJual,
            'total_profit': quantity * (hargaJual - hargaBeli),
          };
        }
      }

      // Konversi ke List dan urutkan lagi berdasarkan total_quantity
      List<Map<String, dynamic>> result = aggregatedData.values.toList();
      result.sort(
        (a, b) =>
            (b['total_quantity'] as int).compareTo(a['total_quantity'] as int),
      );

      return result.take(limit).toList(); // Ambil sesuai limit
    } catch (e) {
      print('Error fetching top selling products: $e');
      throw Exception('Gagal memuat produk terlaris: $e');
    }
  }
}
