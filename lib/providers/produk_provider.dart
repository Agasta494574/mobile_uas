// lib/providers/produk_provider.dart
import 'package:flutter/material.dart';
import '../model/produk.dart';
import '../service/produk_service.dart';

class ProdukProvider extends ChangeNotifier {
  final ProdukService _produkService = ProdukService();

  List<Produk> _produkList = [];
  List<Produk> get produkList => _produkList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- PERBAIKAN ---
  // Konstruktor dikosongkan. Jangan panggil fetchProduk() dari sini
  // untuk menghindari error "setState() called during build".
  ProdukProvider();

  Future<void> fetchProduk() async {
    // Jika data sudah ada dan tidak sedang loading, jangan fetch ulang kecuali diminta.
    // Ini bisa membantu mengurangi panggilan jaringan yang tidak perlu.
    if (_produkList.isNotEmpty && !_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _produkList = await _produkService.getSemuaProduk();
    } catch (e) {
      print('Error di ProdukProvider.fetchProduk: $e');
      _produkList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> tambahProduk(Produk produk) async {
    try {
      await _produkService.tambahProduk(produk);
      await fetchProduk(); // Refresh seluruh list setelah insert
    } catch (e) {
      print('Error di ProdukProvider.tambahProduk: $e');
      throw e;
    }
  }

  Future<void> updateProduk(Produk produk) async {
    try {
      await _produkService.updateProduk(produk);
      int index = _produkList.indexWhere((p) => p.id == produk.id);
      if (index != -1) {
        _produkList[index] = produk;
        notifyListeners();
      }
    } catch (e) {
      print('Error di ProdukProvider.updateProduk: $e');
      throw e;
    }
  }

  Future<void> hapusProduk(String id) async {
    try {
      await _produkService.deactivateProduk(id);
      await fetchProduk();
    } catch (e) {
      print('Error di ProdukProvider.hapusProduk: $e');
      throw e;
    }
  }

  // Fungsi untuk refresh manual jika diperlukan (misal: dari pull-to-refresh)
  Future<void> forceFetchProduk() async {
    _isLoading = true;
    notifyListeners();

    try {
      _produkList = await _produkService.getSemuaProduk();
    } catch (e) {
      print('Error di ProdukProvider.forceFetchProduk: $e');
      _produkList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
