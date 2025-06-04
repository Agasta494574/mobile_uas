// lib/service/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/user.dart' as AppUser; // Aliaskan model User Anda

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _profilesTableName =
      'profiles'; // Nama tabel profil pengguna Anda di Supabase

  // Metode untuk Register Pengguna
  // KINI HANYA MENERIMA EMAIL DAN PASSWORD
  Future<User?> signUp(String email, String password) async {
    // <-- HAPUS PARAMETER 'name'
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      // Pastikan registrasi auth Supabase berhasil
      if (response.user != null) {
        // HAPUS LOGIKA INSERT KE TABEL 'profiles' UNTUK EMAIL DAN NAME.
        // Jika tabel 'profiles' Anda hanya berisi 'id' dan 'created_at',
        // maka Anda hanya perlu insert 'id' saja jika memang perlu entri profil default.
        // Jika tidak ada data profil tambahan yang perlu disimpan, blok insert ini bisa DIHAPUS SEPENUHNYA.
        await _supabase.from(_profilesTableName).insert({
          'id': response.user!.id, // Gunakan ID dari Supabase Auth
          // 'email': email, // HAPUS INI jika tidak ada kolom 'email' di profiles
          // 'name': name, // HAPUS INI jika tidak ada kolom 'name' di profiles
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

  // Metode untuk mendapatkan objek User lengkap (karena profiles minimal, langsung dari auth.users)
  Future<AppUser.User?> getCurrentUserWithProfile() async {
    final User? supabaseUser = _supabase.auth.currentUser;
    if (supabaseUser != null) {
      // Karena tabel profiles minimal, kita langsung buat AppUser.User dari data supabaseUser
      // tidak perlu query ke tabel profiles untuk 'email' atau 'name' lagi.
      return AppUser.User(
        id: supabaseUser.id,
        email: supabaseUser.email!,
        password: '', // Password tidak tersedia di sini
        // name: null, // Jika properti 'name' dihapus dari AppUser.User
      );
    }
    return null;
  }
}
