import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io'; // Tetap diperlukan untuk File di non-web
import 'dart:typed_data'; // Diperlukan untuk Uint8List
import 'package:flutter/foundation.dart' show kIsWeb; // <-- IMPORT BARU
import 'package:mobile_uas/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // Ubah tipe _pickedImageContent menjadi dynamic karena bisa File atau Uint8List
  dynamic _pickedImageContent; // Menyimpan file gambar yang dipilih dari galeri
  String? _currentAvatarUrl; // Menyimpan URL avatar dari database

  // Inisialisasi ImagePicker
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _usernameController = TextEditingController(
      text: authProvider.currentUser?.username ?? '',
    );
    _emailController = TextEditingController(
      text: authProvider.currentUser?.email ?? '',
    );
    _phoneController = TextEditingController(
      text: authProvider.currentUser?.phoneNumber ?? '',
    );
    _currentAvatarUrl =
        authProvider.currentUser?.avatarUrl; // Ambil URL avatar yang ada
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      if (kIsWeb) {
        // Untuk web, baca sebagai bytes
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _pickedImageContent = bytes; // Simpan Uint8List
        });
      } else {
        // Untuk mobile/desktop, gunakan File
        setState(() {
          _pickedImageContent = File(pickedFile.path); // Simpan File
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        String? newUsername = _usernameController.text.trim();
        String? newEmail = _emailController.text.trim();
        String? newPhoneNumber = _phoneController.text.trim();

        bool emailChanged = (newEmail != authProvider.currentUser?.email);
        bool profileDataChanged =
            (newUsername != authProvider.currentUser?.username ||
                newPhoneNumber != authProvider.currentUser?.phoneNumber);

        bool updateSuccessOverall = true;

        if (emailChanged) {
          bool authSuccess = await authProvider.updateEmail(newEmail!);
          if (!mounted) return;
          if (!authSuccess) {
            updateSuccessOverall = false;
            Get.snackbar(
              'Gagal',
              authProvider.errorMessage ?? 'Gagal memperbarui email.',
              backgroundColor: Colors.red.shade200,
              snackPosition: SnackPosition.BOTTOM,
            );
          } else {
            Get.snackbar(
              'Informasi',
              'Perubahan email memerlukan verifikasi. Silakan cek email baru Anda.',
              backgroundColor: Colors.blue.shade200,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }

        if (profileDataChanged) {
          bool profileSuccess = await authProvider.updateUserProfile(
            username: newUsername,
            phoneNumber: newPhoneNumber,
          );
          if (!mounted) return;
          if (!profileSuccess) {
            updateSuccessOverall = false;
            Get.snackbar(
              'Gagal',
              authProvider.errorMessage ?? 'Gagal memperbarui profil.',
              backgroundColor: Colors.red.shade200,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }

        // Modifikasi pemanggilan uploadAvatar
        if (_pickedImageContent != null &&
            authProvider.currentUser?.id != null) {
          bool avatarSuccess = await authProvider.uploadAvatar(
            _pickedImageContent!, // Meneruskan dynamic content (File atau Uint8List)
            authProvider.currentUser!.id!,
          );
          if (!mounted) return;
          if (!avatarSuccess) {
            updateSuccessOverall = false;
            Get.snackbar(
              'Gagal',
              authProvider.errorMessage ?? 'Gagal mengunggah foto profil.',
              backgroundColor: Colors.red.shade200,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }

        if (!mounted) return;

        if (updateSuccessOverall) {
          Get.snackbar(
            'Sukses',
            'Profil berhasil diperbarui!',
            backgroundColor: Colors.green.shade200,
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.back();
        }
      } catch (e) {
        if (!mounted) return;
        Get.snackbar(
          'Error',
          'Terjadi kesalahan: ${e.toString()}',
          backgroundColor: Colors.red.shade200,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Variabel bantu untuk backgroundImage
    ImageProvider? avatarImageProvider;
    if (_pickedImageContent != null) {
      if (kIsWeb) {
        // Untuk web, gunakan MemoryImage dengan Uint8List
        avatarImageProvider = MemoryImage(_pickedImageContent as Uint8List);
      } else {
        // Untuk mobile/desktop, gunakan FileImage dengan File
        avatarImageProvider = FileImage(_pickedImageContent as File);
      }
    } else if (authProvider.currentUser?.avatarUrl != null &&
        authProvider.currentUser!.avatarUrl!.isNotEmpty) {
      avatarImageProvider = NetworkImage(authProvider.currentUser!.avatarUrl!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue.shade100,
                        // Gunakan avatarImageProvider yang sudah ditentukan di atas
                        backgroundImage: avatarImageProvider,
                        child:
                            _pickedImageContent == null &&
                                    (authProvider.currentUser?.avatarUrl ==
                                            null ||
                                        authProvider
                                            .currentUser!
                                            .avatarUrl!
                                            .isEmpty)
                                ? const Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.blue,
                                )
                                : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
