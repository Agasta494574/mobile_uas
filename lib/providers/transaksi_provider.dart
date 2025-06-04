// lib/providers/transaksi_provider.dart
import 'package:flutter/material.dart';
import '../model/transaksi.dart'; // <--- PASTIKAN INI Transaksi.dart
import '../model/transaksi_detail.dart'; // <--- PASTIKAN INI TransaksiDetail.dart
import '../service/transaksi_service.dart'; // Nama service tetap, karena tidak ada nama kelasnya

class TransaksiProvider with ChangeNotifier {
  // <--- GANTI NAMA KELAS INI JIKA SEBELUMNYA TransactionProvider
  final TransactionService _transactionService =
      TransactionService(); // Nama service tetap sama
  List<Transaksi> _transactions = []; // <--- GUNAKAN Transaksi
  List<TransaksiDetail> _transactionDetails =
      []; // <--- GUNAKAN TransaksiDetail

  List<Transaksi> get transactions => _transactions; // <--- GUNAKAN Transaksi
  List<TransaksiDetail> get transactionDetails =>
      _transactionDetails; // <--- GUNAKAN TransaksiDetail

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

  Future<void> fetchTransactions() async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      // Asumsi getTransactions mengembalikan List<Transaksi>
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
    // <--- GUNAKAN Transaksi & TransaksiDetail
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await _transactionService.addTransactionWithDetails(transaction, details);
      await fetchTransactions();
    } catch (e) {
      _setErrorMessage('Gagal menambahkan transaksi: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTransactionDetails(String transactionId) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      // Asumsi getTransactionDetails mengembalikan List<TransaksiDetail>
      _transactionDetails = await _transactionService.getTransactionDetails(
        transactionId,
      );
    } catch (e) {
      _setErrorMessage('Gagal memuat detail transaksi: ${e.toString()}');
      _transactionDetails = [];
    } finally {
      _setLoading(false);
    }
  }
}
