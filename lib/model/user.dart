// lib/model/user.dart
import 'package:supabase_flutter/supabase_flutter.dart' as SupabaseSdk;

class User {
  // Ini adalah model User aplikasi Anda
  String? id;
  String email;
  String password; // Hanya untuk transmisi data dari form
  // String? name; // <-- HAPUS BARIS INI

  User({
    this.id,
    required this.email,
    required this.password,
    // this.name, // <-- HAPUS BARIS INI DARI CONSTRUCTOR
  });

  // Digunakan untuk menyimpan data profil ke tabel 'profiles' di Supabase
  // Kini hanya akan menyimpan 'id' dan 'email' (jika ada) ke profiles
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email':
          email, // Opsional: Hapus jika tabel profiles tidak punya kolom 'email'
      // 'name': name, // <-- HAPUS BARIS INI
    };
  }

  // Digunakan untuk membuat objek User dari data yang diambil dari tabel 'profiles' Supabase
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'], // Ambil email dari map (jika ada di profiles)
      password: '', // Password tidak pernah diambil kembali sebagai plain-text
      // name: map['name'], // <-- HAPUS BARIS INI
    );
  }

  // Digunakan untuk membuat objek User lokal dari objek User Supabase SDK
  factory User.fromSupabaseUser(SupabaseSdk.User user) {
    // <-- HAPUS PARAMETER 'name'
    return User(
      id: user.id,
      email: user.email!,
      password: '', // Tidak ada password di objek User dari Supabase SDK
      // name: null, // <-- HAPUS BARIS INI jika tidak ada properti 'name'
    );
  }
}
