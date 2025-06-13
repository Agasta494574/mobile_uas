// lib/providers/stock_movement_provider.dart
import 'package:flutter/material.dart';
import 'package:mobile_uas/model/stock_movment_model.dart';
import 'package:mobile_uas/service/stock_movment_service.dart';
import '../model/produk.dart'; // Untuk tipe data Produk

class StockMovementProvider extends ChangeNotifier {
  final StockMovementService _stockMovementService = StockMovementService();

  List<StockMovement> _stockMovements = [];
  List<StockMovement> get stockMovements => _stockMovements;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Fetch all stock movements (for AuditScreen)
  Future<void> fetchStockMovements() async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      _stockMovements = await _stockMovementService.getStockMovements();
    } catch (e) {
      _setErrorMessage('Gagal memuat pergerakan stok: ${e.toString()}');
      _stockMovements = [];
    } finally {
      _setLoading(false);
    }
  }

  // Add Stock In
  Future<bool> addStockIn({
    required Produk produk,
    required int quantity,
    required String reason,
    required String userId,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final newMovement = StockMovement(
        id: '', // ID akan di-generate oleh Supabase
        productId: produk.id,
        userId: userId,
        type: 'in',
        quantity: quantity,
        reason: reason,
        createdAt: DateTime.now(),
      );
      await _stockMovementService.addStockMovement(newMovement);
      // Tidak perlu update stok secara manual di sini, karena ada trigger Supabase
      // Namun, kita perlu memicu ProdukProvider untuk refresh data stoknya
      // Ini akan dilakukan di UI (StockInScreen) setelah pemanggilan ini
      return true;
    } catch (e) {
      _setErrorMessage('Gagal menambah stok masuk: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add Stock Out
  Future<bool> addStockOut({
    required Produk produk,
    required int quantity,
    required String reason,
    required String userId,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      // Lakukan validasi stok di sini juga atau di UI
      if (quantity > produk.stok) {
        _setErrorMessage('Jumlah keluar melebihi stok yang tersedia.');
        return false;
      }
      if (quantity <= 0) {
        // Menambahkan validasi jika jumlah 0 atau negatif
        _setErrorMessage('Jumlah keluar harus lebih dari 0.');
        return false;
      }

      final newMovement = StockMovement(
        id: '', // ID akan di-generate oleh Supabase
        productId: produk.id,
        userId: userId,
        type: 'out',
        quantity: quantity,
        reason: reason,
        createdAt: DateTime.now(),
      );
      await _stockMovementService.addStockMovement(newMovement);
      // Tidak perlu update stok secara manual di sini, karena ada trigger Supabase
      // Ini akan dilakukan di UI (StockOutScreen) setelah pemanggilan ini
      return true;
    } catch (e) {
      _setErrorMessage('Gagal mengurangi stok keluar: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
