import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:mobile_uas/providers/auth_provider.dart';
import 'package:mobile_uas/model/user.dart' as AppUser;
import 'package:mobile_uas/screen/edit_profile_screen.dart'; // Import halaman edit profil
import 'package:mobile_uas/screen/change_password_screen.dart'; // Import halaman ubah password
import 'package:mobile_uas/screen/login_screen.dart'; // Import login screen

class AkunScreen extends StatelessWidget {
  const AkunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final AppUser.User? currentUser = authProvider.currentUser;

          if (currentUser == null) {
            return const Center(
              child: Text('Anda belum login.', style: TextStyle(fontSize: 18)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage:
                        currentUser.avatarUrl != null &&
                                currentUser.avatarUrl!.isNotEmpty
                            ? NetworkImage(currentUser.avatarUrl!)
                                as ImageProvider
                            : null,
                    child:
                        currentUser.avatarUrl == null ||
                                currentUser.avatarUrl!.isEmpty
                            ? const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.blue,
                            )
                            : null,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    currentUser.username ?? 'Pengguna',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    currentUser.email,
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                  ),
                ),
                const SizedBox(height: 30),
                _buildInfoCard(
                  icon: Icons.phone,
                  title: 'Nomor Telepon',
                  value: currentUser.phoneNumber ?? 'Belum disetel',
                ),
                const SizedBox(height: 15),
                _buildSettingItem(
                  context,
                  icon: Icons.edit,
                  title: 'Edit Profil',
                  onTap: () {
                    Get.to(() => const EditProfileScreen());
                  },
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.lock,
                  title: 'Ubah Kata Sandi',
                  onTap: () {
                    Get.to(
                      () => const ChangePasswordScreen(),
                    ); // Navigasi ke halaman ubah password
                  },
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'Tentang Aplikasi',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Toko Kelontong Makmur',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2024 Toko Kelontong Makmur',
                      children: [
                        const Text(
                          'Aplikasi ini membantu mengelola produk dan transaksi toko kelontong Anda.',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (!context.mounted) return;

                      await Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).signOut();
                      if (!context.mounted) return;

                      Get.offAll(() => const LoginScreen());
                      Get.snackbar(
                        'Logout',
                        'Anda berhasil logout',
                        backgroundColor: Colors.green.shade300,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget pembantu untuk menampilkan informasi profil
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 30),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk item pengaturan yang bisa diklik
  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.teal, size: 28),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
