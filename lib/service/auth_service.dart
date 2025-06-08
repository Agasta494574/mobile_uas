// lib/service/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io'; // Tetap diperlukan untuk tipe File di non-web, tapi penggunaannya diatur oleh kIsWeb
import 'dart:typed_data'; // Diperlukan untuk Uint8List
import 'package:flutter/foundation.dart' show kIsWeb; // <-- IMPORT BARU

import '../model/user.dart' as AppUser;

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _profilesTableName =
      'profiles'; // Nama tabel profil pengguna Anda di Supabase

  // Metode untuk Register Pengguna
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
        data: {'username': username, 'phone_number': phone},
      );

      if (response.user != null) {
        await _supabase.from(_profilesTableName).insert({
          'id': response.user!.id,
          'username': username,
          'phone_number': phone,
          'email': email,
          'avatar_url': null,
        });
        return response.user;
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
      final response =
          await _supabase
              .from(_profilesTableName)
              .select('username, phone_number, avatar_url')
              .eq('id', supabaseUser.id)
              .single();

      if (response != null) {
        return AppUser.User(
          id: supabaseUser.id,
          email: supabaseUser.email!,
          password: '',
          username: response['username'],
          phoneNumber: response['phone_number'],
          avatarUrl: response['avatar_url'],
        );
      }
      return AppUser.User(
        id: supabaseUser.id,
        email: supabaseUser.email!,
        password: '',
        username: null,
        phoneNumber: null,
        avatarUrl: null,
      );
    } catch (e) {
      print('Error getting user profile: $e');
      return AppUser.User(
        id: supabaseUser.id,
        email: supabaseUser.email!,
        password: '',
        username: null,
        phoneNumber: null,
        avatarUrl: null,
      );
    }
  }

  // Metode untuk memperbarui data profil di tabel 'profiles'
  Future<void> updateUserProfile({
    required String userId,
    String? username,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (username != null && username.isNotEmpty) {
        updates['username'] = username;
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        updates['phone_number'] = phoneNumber;
      }
      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }

      if (updates.isNotEmpty) {
        await _supabase
            .from(_profilesTableName)
            .update(updates)
            .eq('id', userId);
      }
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Gagal memperbarui profil: ${e.toString()}');
    }
  }

  // Metode untuk memperbarui email atau kata sandi pengguna di Supabase Auth
  Future<void> updateUserAuth({String? newEmail, String? newPassword}) async {
    try {
      final UserAttributes attributes = UserAttributes(
        email: newEmail,
        password: newPassword,
      );
      await _supabase.auth.updateUser(attributes);
    } on AuthException catch (e) {
      print('Supabase Auth Error (updateUserAuth): ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('Error updating user auth: $e');
      throw Exception('Terjadi kesalahan saat memperbarui autentikasi.');
    }
  }

  // Metode untuk Mengunggah Avatar ke Supabase Storage
  // Ubah tipe parameter 'image' menjadi dynamic
  Future<String> uploadAvatar(String userId, dynamic image) async {
    try {
      final String path =
          '$userId/avatar/${DateTime.now().millisecondsSinceEpoch}.jpg';

      Future<void> uploadOperation;

      if (kIsWeb) {
        if (image is Uint8List) {
          uploadOperation = _supabase.storage
              .from('avatars')
              .uploadBinary(
                path,
                image,
                fileOptions: const FileOptions(
                  cacheControl: '3600',
                  upsert: true,
                ),
              );
        } else {
          throw Exception(
            "Tipe gambar tidak valid untuk web (bukan Uint8List).",
          );
        }
      } else {
        if (image is File) {
          uploadOperation = _supabase.storage
              .from('avatars')
              .upload(
                path,
                image,
                fileOptions: const FileOptions(
                  cacheControl: '3600',
                  upsert: true,
                ),
              );
        } else {
          throw Exception("Tipe gambar tidak valid untuk mobile (bukan File).");
        }
      }

      await uploadOperation;

      final String publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(path);

      return publicUrl;
    } on StorageException catch (e) {
      print('Supabase Storage Error: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('Error uploading avatar: $e');
      throw Exception('Gagal mengunggah foto profil: ${e.toString()}');
    }
  }
}
