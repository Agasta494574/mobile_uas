// lib/service/transaction_service.dart
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
              // 'id' tidak perlu karena auto-generated di Supabase
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
          .select('*, produk(nama, harga_jual)') // Join ke tabel produk
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
}
