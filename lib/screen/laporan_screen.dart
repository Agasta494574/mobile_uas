// lib/screen/laporan_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_uas/screen/produk_sales_chart_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart'; // Import GetX
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
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Get.to(() => const ProductSalesChartScreen());
            },
            tooltip: 'Lihat Produk Terlaris',
          ),
        ],
      ),
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
                    if (isExpanded) {
                      Provider.of<TransaksiProvider>(
                        context,
                        listen: false,
                      ).fetchTransactionDetails(transaksi.id);
                    }
                  },
                  children: [
                    Builder(
                      builder: (BuildContext innerContext) {
                        final provider = Provider.of<TransaksiProvider>(
                          innerContext,
                        );
                        final currentTransaksiDetails = provider
                            .getTransactionDetailsById(transaksi.id);
                        final isLoadingThisDetail = provider.isLoadingDetails(
                          transaksi.id,
                        );

                        if (isLoadingThisDetail) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (currentTransaksiDetails.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Tidak ada detail untuk transaksi ini atau gagal memuat detail.',
                            ),
                          );
                        }

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
