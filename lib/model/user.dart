// lib/model/user.dart
import 'package:supabase_flutter/supabase_flutter.dart' as SupabaseSdk;

class User {
  // Ini adalah model User aplikasi Anda
  String? id;
  String email;
  String password; // Hanya untuk transmisi data dari form
  String? username; // <-- Tambahkan ini
  String? phoneNumber; // <-- Tambahkan ini

  User({
    this.id,
    required this.email,
    required this.password,
    this.username, // <-- Tambahkan ini ke constructor
    this.phoneNumber, // <-- Tambahkan ini ke constructor
  });

  // Digunakan untuk menyimpan data profil ke tabel 'profiles' di Supabase
  // Kini akan menyimpan 'id', 'email', 'username', dan 'phone_number' ke profiles
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email':
          email, // Opsional: Hapus jika tabel profiles tidak punya kolom 'email'
      'username': username, // <-- Tambahkan ini
      'phone_number': phoneNumber, // <-- Tambahkan ini
    };
  }

  // Digunakan untuk membuat objek User dari data yang diambil dari tabel 'profiles' Supabase
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'], // Ambil email dari map (jika ada di profiles)
      password: '', // Password tidak pernah diambil kembali sebagai plain-text
      username: map['username'], // <-- Tambahkan ini
      phoneNumber: map['phone_number'], // <-- Tambahkan ini
    );
  }

  // Digunakan untuk membuat objek User lokal dari objek User Supabase SDK
  // Ini biasanya digunakan saat mendapatkan currentUser dari Supabase,
  // di mana metadata pengguna dapat diakses melalui `user.user_metadata`.
  factory User.fromSupabaseUser(SupabaseSdk.User user) {
    // Supabase menyimpan metadata tambahan di user_metadata
    final userMetadata = user.userMetadata;

    return User(
      id: user.id,
      email: user.email!,
      password: '', // Tidak ada password di objek User dari Supabase SDK
      username: userMetadata?['username'], // Ambil username dari user_metadata
      phoneNumber:
          userMetadata?['phone_number'], // Ambil phone_number dari user_metadata
    );
  }
}
