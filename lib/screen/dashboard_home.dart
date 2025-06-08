import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_uas/providers/auth_provider.dart'; // Import AuthProvider
import 'package:mobile_uas/providers/produk_provider.dart'; // Import ProdukProvider
import 'package:mobile_uas/model/user.dart' as AppUser; // Alias model User Anda

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final produkProvider = Provider.of<ProdukProvider>(context);
    final AppUser.User? currentUser =
        authProvider.currentUser; // Mendapatkan pengguna saat ini

    // Filter produk yang stoknya menipis
    final lowStockProduk =
        produkProvider.produkList
            .where(
              (produk) => produk.stok <= produk.stokMinimum,
            ) // Memfilter produk yang stoknya menipis
            .toList();

    // Data placeholder untuk stok masuk dan keluar
    // Anda akan menggantinya dengan data aktual yang diambil dari layanan Anda
    final int totalIncomingStock = 1200; // Contoh
    final int totalOutgoingStock = 850; // Contoh

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang, ${currentUser?.username ?? currentUser?.email ?? 'Pengguna'}!', // Menampilkan username atau email pengguna
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Ringkasan Profil Pengguna
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Profil',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Email: ${currentUser?.email ?? '-'}',
                  ), // Menampilkan email pengguna
                  Text(
                    'Username: ${currentUser?.username ?? '-'}',
                  ), // Menampilkan username pengguna
                  Text(
                    'Nomor Telepon: ${currentUser?.phoneNumber ?? '-'}',
                  ), // Menampilkan nomor telepon pengguna
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Ringkasan Stok
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Stok',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text('Total Produk'),
                          Text(
                            produkProvider.produkList.length
                                .toString(), // Menampilkan total produk
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Stok Masuk Hari Ini'),
                          Text(
                            totalIncomingStock
                                .toString(), // Placeholder untuk stok masuk
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Stok Keluar Hari Ini'),
                          Text(
                            totalOutgoingStock
                                .toString(), // Placeholder untuk stok keluar
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (lowStockProduk.isNotEmpty) ...[
                    const Divider(),
                    const Text(
                      'Produk dengan Stok Menipis:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: lowStockProduk.length,
                      itemBuilder: (context, index) {
                        final produk = lowStockProduk[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            '• ${produk.nama} (${produk.kodeProduk}): ${produk.stok} ${produk.satuan}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Tambahkan widget lain di sini sesuai kebutuhan dashboard Anda
        ],
      ),
    );
  }
}
