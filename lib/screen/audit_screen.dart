// lib/screen/audit_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_uas/model/stock_movment_model.dart';
import 'package:mobile_uas/providers/stock_movment_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mobile_uas/providers/transaksi_provider.dart'; // Untuk menampilkan log transaksi juga
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
      Provider.of<StockMovementProvider>(
        context,
        listen: false,
      ).fetchStockMovements();
      Provider.of<TransaksiProvider>(
        context,
        listen: false,
      ).fetchTransactions();
    });
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
              child: Text(
                'Error pergerakan stok: ${stockMovementProvider.errorMessage}',
              ),
            );
          }
          if (transaksiProvider.errorMessage != null) {
            return Center(
              child: Text('Error transaksi: ${transaksiProvider.errorMessage}'),
            );
          }

          // Gabungkan data pergerakan stok dan transaksi untuk tampilan audit
          final List<dynamic> auditItems = [];

          // Perbaikan di sini: Hilangkan operator '?'
          auditItems.addAll(stockMovementProvider.stockMovements);

          // Perbaikan di sini: Hilangkan operator '?'
          auditItems.addAll(transaksiProvider.transactions);

          // Urutkan berdasarkan tanggal terbaru
          auditItems.sort((a, b) {
            DateTime dateA;
            if (a is StockMovement) {
              dateA = a.createdAt;
            } else if (a is Transaksi) {
              dateA = a.tanggal;
            } else {
              dateA = DateTime(0); // Tanggal default jika tipe tidak dikenali
            }

            DateTime dateB;
            if (b is StockMovement) {
              dateB = b.createdAt;
            } else if (b is Transaksi) {
              dateB = b.tanggal;
            } else {
              dateB = DateTime(0);
            }
            return dateB.compareTo(dateA); // Urutkan dari terbaru ke terlama
          });

          if (auditItems.isEmpty) {
            return const Center(
              child: Text('Tidak ada log audit yang tersedia.'),
            );
          }

          return ListView.builder(
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
                      'Stok ${item.type == 'in' ? 'Masuk' : 'Keluar'}: ${item.productName ?? 'Produk Tidak Dikenal'}',
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
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.blue.shade50, // Warna berbeda untuk transaksi
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
                  ),
                );
              }
              return const SizedBox.shrink(); // Untuk tipe yang tidak dikenali
            },
          );
        },
      ),
    );
  }
}
