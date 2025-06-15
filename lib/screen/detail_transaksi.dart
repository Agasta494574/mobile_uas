// lib/screen/detail_transaksi_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mobile_uas/providers/transaksi_provider.dart';
import '../model/transaksi_detail.dart';

class DetailTransaksiScreen extends StatefulWidget {
  final String transactionId;
  final String transactionDate;
  final double transactionTotal;

  const DetailTransaksiScreen({
    super.key,
    required this.transactionId,
    required this.transactionDate,
    required this.transactionTotal,
  });

  @override
  State<DetailTransaksiScreen> createState() => _DetailTransaksiScreenState();
}

class _DetailTransaksiScreenState extends State<DetailTransaksiScreen> {
  @override
  void initState() {
    super.initState();
    // INI ADALAH BAGIAN PENTING UNTUK MEMPERBAIKI ERROR
    // Kita memanggil fungsi untuk mengambil data SETELAH UI selesai dibangun
    // untuk menghindari error "setState() called during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransaksiProvider>(
        context,
        listen: false,
      ).fetchTransactionDetails(widget.transactionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TransaksiProvider>(
        builder: (context, provider, child) {
          // Kita cek status loading khusus untuk transaksi ini
          final isLoading = provider.isLoadingDetails(widget.transactionId);
          // Kita ambil detail transaksi yang sudah di-fetch
          final details = provider.getTransactionDetailsById(
            widget.transactionId,
          );

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (details.isEmpty && !isLoading) {
            return const Center(
              child: Text('Detail transaksi tidak dapat dimuat.'),
            );
          }

          return Column(
            children: [
              // --- Bagian Header Informasi Transaksi ---
              Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tanggal:',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            widget.transactionDate,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ID Transaksi:',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '#${widget.transactionId.substring(0, 8)}...',
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Transaksi:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(widget.transactionTotal)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // --- Bagian Daftar Produk ---
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Daftar Produk Dibeli',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: details.length,
                  itemBuilder: (context, index) {
                    final TransaksiDetail detail = details[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Text(
                          detail.jumlah.toString(),
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(detail.productName),
                      subtitle: Text(
                        'Harga Satuan: Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(detail.productPricePerUnit)}',
                      ),
                      trailing: Text(
                        'Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(detail.subtotal)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
