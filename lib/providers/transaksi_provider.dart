// lib/providers/transaksi_provider.dart
import 'package:flutter/material.dart';
import '../model/transaksi.dart';
import '../model/transaksi_detail.dart';
import '../service/transaksi_service.dart';

class TransaksiProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  List<Transaksi> _transactions = [];

  // Ganti List<TransaksiDetail> menjadi Map<String, List<TransaksiDetail>>
  Map<String, List<TransaksiDetail>> _transactionDetailsMap = {};

  List<Transaksi> get transactions => _transactions;
  // Getter baru untuk mengambil detail berdasarkan transaksiId
  List<TransaksiDetail> getTransactionDetailsById(String transactionId) {
    return _transactionDetailsMap[transactionId] ?? [];
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Map untuk melacak status loading detail per transaksi
  final Map<String, bool> _isLoadingDetails = {};
  bool isLoadingDetails(String transactionId) =>
      _isLoadingDetails[transactionId] ?? false;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      _transactions = await _transactionService.getTransactions();
    } catch (e) {
      _setErrorMessage('Gagal memuat transaksi: ${e.toString()}');
      _transactions = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addTransaction(
    Transaksi transaction,
    List<TransaksiDetail> details,
  ) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await _transactionService.addTransactionWithDetails(transaction, details);
      // Setelah berhasil menambah, mungkin perlu refresh semua transaksi
      await fetchTransactions();
    } catch (e) {
      _setErrorMessage('Gagal menambahkan transaksi: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Modifikasi fetchTransactionDetails untuk menyimpan ke Map
  Future<void> fetchTransactionDetails(String transactionId) async {
    if (_transactionDetailsMap.containsKey(transactionId) &&
        _transactionDetailsMap[transactionId]!.isNotEmpty) {
      // Jika detail sudah ada dan tidak kosong, tidak perlu fetch ulang
      return;
    }

    _isLoadingDetails[transactionId] = true;
    notifyListeners(); // Beritahu listener bahwa loading detail spesifik ini dimulai

    _setErrorMessage(null); // Reset error message umum
    try {
      final details = await _transactionService.getTransactionDetails(
        transactionId,
      );
      _transactionDetailsMap[transactionId] = details;
    } catch (e) {
      _setErrorMessage(
        'Gagal memuat detail transaksi ID $transactionId: ${e.toString()}',
      );
      _transactionDetailsMap[transactionId] = []; // Kosongkan jika ada error
    } finally {
      _isLoadingDetails[transactionId] = false;
      notifyListeners(); // Beritahu listener bahwa loading detail spesifik ini selesai
    }
  }

  // --- Metode Baru untuk Grafik Produk Terlaris ---
  List<Map<String, dynamic>> _topSellingProducts = [];
  List<Map<String, dynamic>> get topSellingProducts => _topSellingProducts;

  bool _isLoadingTopProducts = false;
  bool get isLoadingTopProducts => _isLoadingTopProducts;

  String? _topProductsErrorMessage;
  String? get topProductsErrorMessage => _topProductsErrorMessage;

  Future<void> fetchTopSellingProducts({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isLoadingTopProducts = true;
    _topProductsErrorMessage = null;
    notifyListeners();
    try {
      _topSellingProducts = await _transactionService.getTopSellingProducts(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _topProductsErrorMessage =
          'Gagal memuat produk terlaris: ${e.toString()}';
      _topSellingProducts = [];
    } finally {
      _isLoadingTopProducts = false;
      notifyListeners();
    }
  }
}
