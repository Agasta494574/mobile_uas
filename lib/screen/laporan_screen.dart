// lib/screen/laporan_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:mobile_uas/providers/transaksi_provider.dart';
import 'package:mobile_uas/model/transaksi.dart';
import 'package:mobile_uas/model/transaksi_detail.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  @override
  void initState() {
    super.initState();
    // Memuat data transaksi saat screen diinisialisasi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransaksiProvider>(
        context,
        listen: false,
      ).fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Penjualan')),
      body: Consumer<TransaksiProvider>(
        builder: (context, transaksiProvider, child) {
          if (transaksiProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (transaksiProvider.errorMessage != null) {
            return Center(
              child: Text('Error: ${transaksiProvider.errorMessage}'),
            );
          }
          if (transaksiProvider.transactions.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada riwayat pembelian.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: transaksiProvider.transactions.length,
            itemBuilder: (context, index) {
              final transaksi = transaksiProvider.transactions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ExpansionTile(
                  title: Text(
                    'Transaksi ID: ${transaksi.id.substring(0, 8)}...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal: ${DateFormat('dd MMMM HH:mm', 'id').format(transaksi.tanggal)}',
                      ),
                      Text(
                        'Total Bayar: Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(transaksi.totalBayar)}',
                      ),
                    ],
                  ),
                  onExpansionChanged: (isExpanded) {
                    // <--- PASTIKAN BAGIAN INI ADA DAN BENAR
                    if (isExpanded) {
                      // Panggil fungsi untuk mengambil detail saat tile diperluas
                      // Perhatikan `listen: false` karena kita hanya ingin memanggil method, bukan rebuild di sini
                      Provider.of<TransaksiProvider>(
                        context,
                        listen: false,
                      ).fetchTransactionDetails(transaksi.id);
                    }
                  },
                  children: [
                    Consumer<TransaksiProvider>(
                      // <--- Consumer ini harus mendengarkan detailProvider
                      builder: (context, detailProvider, child) {
                        // Jika sedang loading atau belum ada detail
                        if (detailProvider.isLoading &&
                            detailProvider.transactionDetails.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (detailProvider.errorMessage != null) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Error memuat detail: ${detailProvider.errorMessage}',
                            ),
                          );
                        }

                        // Filter detail yang sesuai dengan transaksi yang sedang diperluas
                        // Penting: detailProvider.transactionDetails akan berisi detail dari
                        // transaksi terakhir yang detailnya diminta. Jadi, kita harus memfilter
                        // berdasarkan transaksi.id saat ini.
                        final currentTransaksiDetails =
                            detailProvider.transactionDetails
                                .where(
                                  (detail) =>
                                      detail.transaksiId == transaksi.id,
                                )
                                .toList();
                        print(
                          'Filtered ${currentTransaksiDetails.length} details for current transaction',
                        );

                        if (currentTransaksiDetails.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Tidak ada detail untuk transaksi ini.',
                            ),
                          );
                        }

                        // Tampilkan daftar detail produk
                        return Column(
                          children:
                              currentTransaksiDetails.map((detail) {
                                return ListTile(
                                  leading: const Icon(
                                    Icons.shopping_bag_outlined,
                                  ),
                                  title: Text(
                                    '${detail.productName} (x${detail.jumlah})',
                                  ),
                                  subtitle: Text(
                                    'Harga Satuan: Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(detail.productPricePerUnit)}',
                                  ),
                                  trailing: Text(
                                    'Subtotal: Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(detail.subtotal)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
