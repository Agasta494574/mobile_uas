import 'package:mobile_uas/model/transaksi_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/produk.dart'; // Untuk berpotensi mengambil detail produk dalam laporan

class TransaksiService {
  final supabase = Supabase.instance.client;

  Future<void> recordTransaksi(Transaksi transaksi) async {
    await supabase.from('transaksi').insert(transaksi.toMap());
    // Secara opsional, perbarui stok produk di sini jika transaksi berarti pengurangan stok
    // Ini idealnya adalah fungsi/trigger Supabase untuk atomicity
  }

  // --- Metode Pelaporan ---

  Future<List<Map<String, dynamic>>> getDailyReport(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final response = await supabase
        .from('transaksi')
        .select('*, produk:produk_id(*)') // Ambil detail produk terkait
        .gte('tanggal', startOfDay.toIso8601String())
        .lte('tanggal', endOfDay.toIso8601String())
        .order('tanggal', ascending: true);

    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getWeeklyReport(DateTime dateInWeek) async {
    // Tentukan awal minggu (misalnya, Senin)
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Senin
    final endOfWeek = startOfWeek.add(const Duration(days: 6)); // Minggu

    final response = await supabase
        .from('transaksi')
        .select('*, produk:produk_id(*)')
        .gte('tanggal', startOfWeek.toIso8601String())
        .lte('tanggal', endOfWeek.toIso8601String())
        .order('tanggal', ascending: true);

    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getMonthlyReport(DateTime dateInMonth) async {
    final startOfMonth = DateTime(dateInMonth.year, dateInMonth.month, 1);
    final endOfMonth = DateTime(dateInMonth.year, dateInMonth.month + 1, 0, 23, 59, 59); // Hari terakhir bulan

    final response = await supabase
        .from('transaksi')
        .select('*, produk:produk_id(*)')
        .gte('tanggal', startOfMonth.toIso8601String())
        .lte('tanggal', endOfMonth.toIso8601String())
        .order('tanggal', ascending: true);

    return (response as List).cast<Map<String, dynamic>>();
  }

  // Anda mungkin menginginkan laporan teragregasi langsung dari Supabase untuk efisiensi
  // Contoh untuk agregasi harian berdasarkan produk:
  Future<List<Map<String, dynamic>>> getDailyProductSummary(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    // Ini membutuhkan fungsi atau view Supabase untuk agregasi langsung
    // Untuk saat ini, kita akan mengambil semua transaksi dan mengagregasinya di Flutter
    final response = await supabase
        .from('transaksi')
        .select('produk_id, jumlah')
        .gte('tanggal', startOfDay.toIso8601String())
        .lte('tanggal', endOfDay.toIso8601String());

    // Agregasi dasar dalam aplikasi (agregasi yang lebih kompleks lebih baik dilakukan di DB)
    Map<String, int> productQuantities = {};
    for (var item in (response as List).cast<Map<String, dynamic>>()) {
      final productId = item['produk_id'] as String;
      final quantity = item['jumlah'] as int;
      productQuantities.update(productId, (value) => value + quantity, ifAbsent: () => quantity);
    }

    // Sekarang ambil nama produk untuk ID ini
    final productIds = productQuantities.keys.toList();
    final productResponse = await supabase
        .from('produk')
        .select('id, nama')
        .in_('id', productIds);

    final productNames = { for (var p in (productResponse as List)) p['id'] as String : p['nama'] as String };

    List<Map<String, dynamic>> summary = [];
    productQuantities.forEach((id, totalQuantity) {
      summary.add({
        'nama_produk': productNames[id] ?? 'Produk Tidak Dikenal',
        'total_jumlah': totalQuantity,
      });
    });

    return summary;
  }
}