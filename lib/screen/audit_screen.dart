// lib/screen/audit_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_uas/model/stock_movment_model.dart';
import 'package:mobile_uas/providers/stock_movment_provider.dart';
import 'package:mobile_uas/screen/detail_transaksi.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart'; // <-- 1. TAMBAHKAN IMPORT GET
import 'package:mobile_uas/providers/transaksi_provider.dart';
import 'package:mobile_uas/model/transaksi.dart';


class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Refresh data saat halaman dibuka
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    // Fungsi ini bisa dipanggil oleh RefreshIndicator
    // listen: false aman digunakan di sini
    Provider.of<StockMovementProvider>(
      context,
      listen: false,
    ).fetchStockMovements();
    Provider.of<TransaksiProvider>(context, listen: false).fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log & Riwayat'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Consumer2<StockMovementProvider, TransaksiProvider>(
        builder: (context, stockMovementProvider, transaksiProvider, child) {
          if (stockMovementProvider.isLoading || transaksiProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (stockMovementProvider.errorMessage != null) {
            return Center(
              child: Text('Error: ${stockMovementProvider.errorMessage}'),
            );
          }
          if (transaksiProvider.errorMessage != null) {
            return Center(
              child: Text('Error: ${transaksiProvider.errorMessage}'),
            );
          }

          final List<dynamic> auditItems = [
            ...stockMovementProvider.stockMovements,
            ...transaksiProvider.transactions,
          ];

          // Urutkan berdasarkan tanggal terbaru
          auditItems.sort((a, b) {
            DateTime dateA =
                (a is StockMovement) ? a.createdAt : (a as Transaksi).tanggal;
            DateTime dateB =
                (b is StockMovement) ? b.createdAt : (b as Transaksi).tanggal;
            return dateB.compareTo(dateA);
          });

          if (auditItems.isEmpty) {
            return const Center(
              child: Text('Tidak ada log audit yang tersedia.'),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              itemCount: auditItems.length,
              itemBuilder: (context, index) {
                final item = auditItems[index];

                if (item is StockMovement) {
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: Icon(
                        item.type == 'in'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: item.type == 'in' ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        'Stok ${item.type == 'in' ? 'Masuk' : 'Keluar'}: ${item.productName ?? 'Produk Dihapus'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jumlah: ${item.quantity}'),
                          Text('Alasan: ${item.reason ?? '-'}'),
                          Text(
                            'Waktu: ${DateFormat('dd MMM yyyy, HH:mm').format(item.createdAt)}',
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (item is Transaksi) {
                  // --- PERBAIKAN DI SINI ---
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.blue.shade50,
                    // Menambahkan InkWell agar Card bisa di-klik
                    child: InkWell(
                      onTap: () {
                        // Navigasi ke halaman detail saat di-klik
                        Get.to(
                          () => DetailTransaksiScreen(
                            transactionId: item.id,
                            transactionDate: DateFormat(
                              'dd MMM yyyy, HH:mm',
                            ).format(item.tanggal),
                            transactionTotal: item.totalBayar,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        leading: const Icon(
                          Icons.shopping_cart,
                          color: Colors.blue,
                        ),
                        title: Text(
                          'Transaksi Penjualan (ID: ${item.id.substring(0, 8)}...)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Bayar: Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(item.totalBayar)}',
                            ),
                            Text(
                              'Waktu: ${DateFormat('dd MMM yyyy, HH:mm').format(item.tanggal)}',
                            ),
                          ],
                        ),
                        // Menambahkan ikon panah untuk menandakan item bisa di-klik
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                  // --- AKHIR PERBAIKAN ---
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}
