import 'package:flutter/material.dart';
import 'package:mobile_uas/model/produk.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:uuid/uuid.dart'; // Pastikan Anda menambahkan package uuid di pubspec.yaml
import '../../providers/produk_provider.dart';
import 'package:provider/provider.dart';

class ProdukFormScreen extends StatefulWidget {
  final Produk? produk; // Jika ada produk, berarti mode edit

  const ProdukFormScreen({super.key, this.produk});

  @override
  State<ProdukFormScreen> createState() => _ProdukFormScreenState();
}

class _ProdukFormScreenState extends State<ProdukFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  bool _isEditing = false;
  String? _produkId;

  @override
  void initState() {
    super.initState();
    if (widget.produk != null) {
      _isEditing = true;
      _produkId = widget.produk!.id;
      _namaController.text = widget.produk!.nama;
      _hargaController.text = widget.produk!.harga.toString();
      _stokController.text = widget.produk!.stok.toString();
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final provider = Provider.of<ProdukProvider>(context, listen: false);

      final produk = Produk(
        id: _isEditing ? _produkId! : const Uuid().v4(),
        nama: _namaController.text,
        harga: double.parse(_hargaController.text),
        stok: int.parse(_stokController.text),
      );

      if (_isEditing) {
        await provider.updateProduk(produk);
      } else {
        await provider.addProduk(produk);
      }

      if (provider.errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Produk berhasil diperbarui!'
                  : 'Produk berhasil ditambahkan!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Produk' : 'Tambah Produk Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan harga yang valid (angka)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Stok tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan stok yang valid (angka)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(_isEditing ? 'Perbarui Produk' : 'Tambah Produk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
