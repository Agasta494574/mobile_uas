// lib/service/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/user.dart' as AppUser; // Aliaskan model User Anda

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _profilesTableName =
      'profiles'; // Nama tabel profil pengguna Anda di Supabase

  // Metode untuk Register Pengguna
  // KINI MENERIMA EMAIL, PASSWORD, USERNAME, DAN PHONE
  Future<User?> signUp(
    String email,
    String password,
    String username,
    String phone,
  ) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        // Gunakan parameter 'data' untuk menyimpan metadata pengguna tambahan saat registrasi auth
        data: {
          'username': username,
          'phone_number': phone, // Sesuaikan dengan nama kolom di Supabase Anda
        },
      );

      // Pastikan registrasi auth Supabase berhasil
      if (response.user != null) {
        // Sekarang, masukkan data tambahan ke tabel 'profiles'
        // Jika Anda menyimpan username dan phone di tabel profiles terpisah,
        // pastikan kolom 'username' dan 'phone_number' ada di tabel 'profiles' Anda.
        await _supabase.from(_profilesTableName).insert({
          'id': response.user!.id, // ID pengguna dari Supabase Auth
          'username': username, // Simpan username di tabel profiles
          'phone_number': phone, // Simpan nomor telepon di tabel profiles
          'email': email, // Mungkin Anda juga ingin menyimpan email di profiles
          // Tambahkan kolom lain yang relevan di tabel profiles Anda
        });
        return response.user; // Kembalikan objek User dari Supabase Auth
      }
      return null;
    } on AuthException catch (e) {
      print('Supabase Auth Error (signUp): ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('Error during sign up: $e');
      throw Exception('Terjadi kesalahan saat pendaftaran.');
    }
  }

  // Metode untuk Login Pengguna
  Future<User?> signIn(String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } on AuthException catch (e) {
      print('Supabase Auth Error (signIn): ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('Error during sign in: $e');
      throw Exception('Terjadi kesalahan saat login.');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      print('Supabase Auth Error (signOut): ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('Error during sign out: $e');
      throw Exception('Terjadi kesalahan saat logout.');
    }
  }

  // Metode untuk mendapatkan objek User lengkap dari Supabase auth dan profil
  Future<AppUser.User?> getCurrentUserWithProfile() async {
    final User? supabaseUser = _supabase.auth.currentUser;
    if (supabaseUser == null) {
      return null;
    }

    try {
      // Ambil data profil dari tabel 'profiles'
      final response =
          await _supabase
              .from(_profilesTableName)
              .select(
                'username, phone_number',
              ) // Pilih kolom yang ingin Anda ambil
              .eq(
                'id',
                supabaseUser.id,
              ) // Gunakan ID pengguna untuk mencari profil
              .single(); // Harapkan hanya satu hasil

      if (response != null) {
        // Buat objek AppUser.User dari data auth dan profil
        return AppUser.User(
          id: supabaseUser.id,
          email: supabaseUser.email!,
          // Password tidak tersedia di sini untuk keamanan
          password: '',
          username: response['username'], // Ambil username dari data profil
          phoneNumber:
              response['phone_number'], // Ambil nomor telepon dari data profil
        );
      }
      // Jika tidak ada profil yang ditemukan, kembalikan AppUser.User hanya dengan data auth
      return AppUser.User(
        id: supabaseUser.id,
        email: supabaseUser.email!,
        password: '',
        username: null, // Atau defaultkan ke string kosong
        phoneNumber: null, // Atau defaultkan ke string kosong
      );
    } catch (e) {
      print('Error getting user profile: $e');
      // Jika terjadi kesalahan saat mengambil profil, masih kembalikan pengguna dasar
      return AppUser.User(
        id: supabaseUser.id,
        email: supabaseUser.email!,
        password: '',
        username: null,
        phoneNumber: null,
      );
    }
  }
}
