import 'package:flutter/material.dart';
import '../model/produk.dart'; //
import '../service/produk_service.dart'; //

class ProdukProvider with ChangeNotifier {
  final ProdukService _produkService = ProdukService();
  List<Produk> _listProduk = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Produk> get listProduk => _listProduk;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProdukProvider() {
    fetchProduk();
  }

  Future<void> fetchProduk() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _listProduk = await _produkService.getSemuaProduk();
    } catch (e) {
      _errorMessage = 'Gagal memuat produk: $e';
      debugPrint('Error fetching produk: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduk(Produk produk) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _produkService.tambahProduk(produk);
      await fetchProduk(); // Refresh list after adding
    } catch (e) {
      _errorMessage = 'Gagal menambahkan produk: $e';
      debugPrint('Error adding produk: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduk(Produk produk) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _produkService.updateProduk(produk);
      await fetchProduk(); // Refresh list after updating
    } catch (e) {
      _errorMessage = 'Gagal memperbarui produk: $e';
      debugPrint('Error updating produk: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduk(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _produkService.hapusProduk(id);
      await fetchProduk(); // Refresh list after deleting
    } catch (e) {
      _errorMessage = 'Gagal menghapus produk: $e';
      debugPrint('Error deleting produk: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
