import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_uas/model/transaksi_model.dart';
import '../service/transaksi_service.dart'; // Impor service baru Anda
import 'package:intl/intl.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final TransaksiService _transaksiService = TransaksiService();
  DateTime _selectedDate = DateTime.now(); // Untuk laporan harian
  int _selectedReportType = 0; // 0: Harian, 1: Mingguan, 2: Bulanan

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildReportTypeSelector(),
          const SizedBox(height: 16),
          _buildDatePicker(),
          const SizedBox(height: 16),
          Expanded(child: _buildReportContent()),
        ],
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return SegmentedButton<int>(
      segments: const <ButtonSegment<int>>[
        ButtonSegment<int>(
          value: 0,
          label: Text('Harian'),
          icon: Icon(Icons.calendar_view_day),
        ),
        ButtonSegment<int>(
          value: 1,
          label: Text('Mingguan'),
          icon: Icon(Icons.calendar_view_week),
        ),
        ButtonSegment<int>(
          value: 2,
          label: Text('Bulanan'),
          icon: Icon(Icons.calendar_view_month),
        ),
      ],
      selected: <int>{_selectedReportType},
      onSelectionChanged: (Set<int> newSelection) {
        setState(() {
          _selectedReportType = newSelection.first;
          // Atur ulang tanggal jika mengubah jenis laporan mungkin memerlukan pemilihan tanggal yang berbeda
          // Untuk kesederhanaan, kita akan membiarkan _selectedDate apa adanya.
        });
      },
    );
  }

  Widget _buildDatePicker() {
    String dateDisplay = '';
    if (_selectedReportType == 0) {
      // Harian
      dateDisplay = DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate);
    } else if (_selectedReportType == 1) {
      // Mingguan
      final startOfWeek = _selectedDate.subtract(
        Duration(days: _selectedDate.weekday - 1),
      );
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      dateDisplay =
          '${DateFormat('dd MMM').format(startOfWeek)} - ${DateFormat('dd MMM yyyy').format(endOfWeek)}';
    } else {
      // Bulanan
      dateDisplay = DateFormat('MMMM yyyy').format(_selectedDate);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              if (_selectedReportType == 0) {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              } else if (_selectedReportType == 1) {
                _selectedDate = _selectedDate.subtract(const Duration(days: 7));
              } else {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                  _selectedDate.day,
                );
              }
            });
          },
        ),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null && picked != _selectedDate) {
              setState(() {
                _selectedDate = picked;
              });
            }
          },
          child: Text(
            dateDisplay,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            setState(() {
              if (_selectedReportType == 0) {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              } else if (_selectedReportType == 1) {
                _selectedDate = _selectedDate.add(const Duration(days: 7));
              } else {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                  _selectedDate.day,
                );
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildReportContent() {
    Future<List<Map<String, dynamic>>> reportFuture;
    if (_selectedReportType == 0) {
      reportFuture = _transaksiService.getDailyProductSummary(_selectedDate);
    } else if (_selectedReportType == 1) {
      reportFuture = _transaksiService.getWeeklyReport(
        _selectedDate,
      ); // Anda perlu mengagregasi ini di UI atau DB
      // Untuk kesederhanaan, kita hanya akan menampilkan transaksi mingguan mentah untuk saat ini.
      // Solusi yang lebih kuat akan mengagregasi berdasarkan produk untuk mingguan/bulanan.
    } else {
      reportFuture = _transaksiService.getMonthlyReport(
        _selectedDate,
      ); // Mirip dengan mingguan
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: reportFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Tidak ada data transaksi untuk periode ini.'),
          );
        } else {
          // Tampilkan data laporan
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              if (_selectedReportType == 0) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(item['nama_produk'] ?? 'Produk Tidak Dikenal'),
                    trailing: Text('Jumlah: ${item['total_jumlah']}'),
                  ),
                );
              } else {
                // Untuk mingguan dan bulanan, Anda kemungkinan ingin mengagregasi berdasarkan produk
                // Ini adalah tampilan dasar dari transaksi individu
                final transaksi = Transaksi.fromMap(item);
                final produkNama =
                    item['produk']['nama'] ?? 'Produk Tidak Dikenal';
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text('$produkNama (Jumlah: ${transaksi.jumlah})'),
                    subtitle: Text(
                      'Tanggal: ${DateFormat('dd MMM yyyy HH:mm').format(transaksi.tanggal)}',
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}
