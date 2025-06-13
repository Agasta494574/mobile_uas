// lib/screen/product_sales_chart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import 'package:mobile_uas/providers/transaksi_provider.dart';

// Import untuk PDF
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ProductSalesChartScreen extends StatefulWidget {
  const ProductSalesChartScreen({super.key});

  @override
  State<ProductSalesChartScreen> createState() =>
      _ProductSalesChartScreenState();
}

class _ProductSalesChartScreenState extends State<ProductSalesChartScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedPeriod = 'Minggu Ini'; // Default period

  @override
  void initState() {
    super.initState();
    _setPeriodDates(_selectedPeriod);
  }

  void _setPeriodDates(String period) {
    DateTime now = DateTime.now();
    setState(() {
      _selectedPeriod = period;
      if (period == 'Minggu Ini') {
        _startDate = now.subtract(Duration(days: now.weekday - 1)); // Senin
        _endDate = now.add(Duration(days: 7 - now.weekday)); // Minggu
      } else if (period == 'Bulan Ini') {
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(
          now.year,
          now.month + 1,
          0,
        ); // Hari terakhir bulan ini
      } else {
        // Custom
        _startDate = null;
        _endDate = null;
      }
    });
    if (_startDate != null && _endDate != null) {
      _fetchDataForChart();
    }
  }

  Future<void> _fetchDataForChart() async {
    if (_startDate != null && _endDate != null) {
      await Provider.of<TransaksiProvider>(
        context,
        listen: false,
      ).fetchTopSellingProducts(startDate: _startDate!, endDate: _endDate!);
    }
  }

  Future<void> _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now(),
        end: _endDate ?? DateTime.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedPeriod = 'Kustom';
      });
      _fetchDataForChart();
    }
  }

  Future<void> _generatePdf(List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();
    final font =
        await PdfGoogleFonts.nunitoExtraLight(); // Ganti dengan font yang Anda inginkan

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Laporan Produk Terlaris',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Periode: ${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}',
                style: pw.TextStyle(font: font, fontSize: 14),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Produk', 'Jumlah Terjual', 'Omset', 'Keuntungan'],
                data:
                    data
                        .map(
                          (item) => [
                            item['product_name'],
                            item['total_quantity'].toString(),
                            'Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(item['total_omset'])}',
                            'Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(item['total_profit'])}',
                          ],
                        )
                        .toList(),
                headerStyle: pw.TextStyle(
                  font: font,
                  fontWeight: pw.FontWeight.bold,
                ),
                cellStyle: pw.TextStyle(font: font),
                border: pw.TableBorder.all(color: PdfColors.black),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'laporan_produk_terlaris.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final transaksiProvider = Provider.of<TransaksiProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk Terlaris'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          if (_startDate != null &&
              _endDate != null &&
              !transaksiProvider.isLoadingTopProducts &&
              transaksiProvider.topSellingProducts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed:
                  () => _generatePdf(transaksiProvider.topSellingProducts),
              tooltip: 'Ekspor ke PDF',
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPeriod,
                    decoration: const InputDecoration(
                      labelText: 'Periode',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Minggu Ini',
                        child: Text('Minggu Ini'),
                      ),
                      DropdownMenuItem(
                        value: 'Bulan Ini',
                        child: Text('Bulan Ini'),
                      ),
                      DropdownMenuItem(value: 'Kustom', child: Text('Kustom')),
                    ],
                    onChanged: (value) {
                      if (value == 'Kustom') {
                        _pickDateRange();
                      } else {
                        _setPeriodDates(value!);
                      }
                    },
                  ),
                ),
                if (_selectedPeriod == 'Kustom') ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickDateRange,
                      child: Text(
                        _startDate == null
                            ? 'Pilih Tanggal'
                            : '${DateFormat('dd/MM').format(_startDate!)} - ${DateFormat('dd/MM').format(_endDate!)}',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child:
                transaksiProvider.isLoadingTopProducts
                    ? const Center(child: CircularProgressIndicator())
                    : transaksiProvider.topProductsErrorMessage != null
                    ? Center(
                      child: Text(
                        'Error: ${transaksiProvider.topProductsErrorMessage}',
                      ),
                    )
                    : transaksiProvider.topSellingProducts.isEmpty
                    ? const Center(
                      child: Text(
                        'Tidak ada data produk terlaris untuk periode ini.',
                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieChartSections(
                            transaksiProvider.topSellingProducts,
                          ),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                          pieTouchData: PieTouchData(
                            touchCallback: (
                              FlTouchEvent event,
                              pieTouchResponse,
                            ) {
                              // Implementasi touch data jika diperlukan
                            },
                          ),
                        ),
                      ),
                    ),
          ),
          if (transaksiProvider.topSellingProducts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildLegend(transaksiProvider.topSellingProducts),
              ),
            ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    List<Map<String, dynamic>> data,
  ) {
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.brown,
      Colors.grey,
      Colors.cyan,
    ];
    double totalQuantity = data.fold(
      0,
      (sum, item) => sum + (item['total_quantity'] as int),
    );

    return List.generate(data.length, (i) {
      final item = data[i];
      final isTouched = false; // Anda bisa tambahkan state untuk interaktivitas
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 60.0 : 50.0;
      final value = (item['total_quantity'] as int).toDouble();
      final percentage = (value / totalQuantity * 100).toStringAsFixed(1);

      return PieChartSectionData(
        color: colors[i % colors.length],
        value: value,
        title: '${item['product_name']}\n($percentage%)',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
        titlePositionPercentageOffset: 0.55,
      );
    });
  }

  List<Widget> _buildLegend(List<Map<String, dynamic>> data) {
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.brown,
      Colors.grey,
      Colors.cyan,
    ];

    return List.generate(data.length, (i) {
      final item = data[i];
      final color = colors[i % colors.length];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(width: 16, height: 16, color: color),
            const SizedBox(width: 8),
            Text(
              '${item['product_name']} - ${item['total_quantity']} unit terjual',
            ),
          ],
        ),
      );
    });
  }
}
