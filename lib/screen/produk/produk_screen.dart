import 'package:flutter/material.dart';
import 'package:mobile_uas/providers/produk_provider.dart';
import 'package:provider/provider.dart';
import 'produk_form_screen.dart'; // Import form screen

class ProdukScreen extends StatefulWidget {
  const ProdukScreen({super.key});

  @override
  State<ProdukScreen> createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  @override
  void initState() {
    super.initState();
    // Memuat produk saat pertama kali layar dibuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProdukProvider>(context, listen: false).fetchProduk();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProdukProvider>(
        builder: (context, produkProvider, child) {
          if (produkProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (produkProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${produkProvider.errorMessage}'),
                  ElevatedButton(
                    onPressed: () => produkProvider.fetchProduk(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (produkProvider.listProduk.isEmpty) {
            return const Center(
              child: Text('Belum ada produk. Tambahkan satu!'),
            );
          } else {
            return ListView.builder(
              itemCount: produkProvider.listProduk.length,
              itemBuilder: (context, index) {
                final produk = produkProvider.listProduk[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: ListTile(
                    title: Text(produk.nama),
                    subtitle: Text(
                      'Harga: Rp${produk.harga.toStringAsFixed(0)} | Stok: ${produk.stok}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ProdukFormScreen(produk: produk),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Konfirmasi Hapus'),
                                    content: Text(
                                      'Apakah Anda yakin ingin menghapus ${produk.nama}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                            );
                            if (confirm == true) {
                              await produkProvider.deleteProduk(produk.id);
                              if (produkProvider.errorMessage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Produk berhasil dihapus!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(produkProvider.errorMessage!),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProdukFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
