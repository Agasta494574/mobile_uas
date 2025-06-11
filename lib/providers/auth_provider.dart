// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as SupabaseSdk;
// import 'dart:io'; // Tidak perlu import File di sini jika tidak ada penggunaan langsung File
import '../service/auth_service.dart';
import '../model/user.dart' as AppUser;

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AppUser.User? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  AppUser.User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initAuthListener();
    _checkCurrentUserInitial();
  }

  void _initAuthListener() {
    SupabaseSdk.Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) async {
      final SupabaseSdk.AuthChangeEvent event = data.event;

      print('Auth event: $event');

      if (event == SupabaseSdk.AuthChangeEvent.signedIn ||
          event == SupabaseSdk.AuthChangeEvent.initialSession) {
        _isLoading = true;
        notifyListeners();
        try {
          _currentUser = await _authService.getCurrentUserWithProfile();
        } catch (e) {
          print("Error in onAuthStateChange listener: $e");
          _currentUser = null;
          _errorMessage = "Gagal memuat profil pengguna.";
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      } else if (event == SupabaseSdk.AuthChangeEvent.signedOut) {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _checkCurrentUserInitial() async {
    _isLoading = true;
    notifyListeners();
    try {
      final SupabaseSdk.User? supabaseUser =
          SupabaseSdk.Supabase.instance.client.auth.currentUser;
      if (supabaseUser != null) {
        _currentUser = await _authService.getCurrentUserWithProfile();
      } else {
        _currentUser = null;
      }
    } catch (e) {
      print("Error during initial user check: $e");
      _currentUser = null;
      _errorMessage = "Gagal memuat sesi awal.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Metode untuk Register
  Future<bool> signUp(
    String email,
    String password,
    String username,
    String phone,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final SupabaseSdk.User? supabaseUser = await _authService.signUp(
        email,
        password,
        username,
        phone,
      );
      if (supabaseUser != null) {
        _currentUser = await _authService.getCurrentUserWithProfile();
        return true;
      }
      _errorMessage = "Registrasi gagal, coba lagi.";
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Metode untuk Login
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final SupabaseSdk.User? supabaseUser = await _authService.signIn(
        email,
        password,
      );
      if (supabaseUser != null) {
        _currentUser = await _authService.getCurrentUserWithProfile();
        return true;
      }
      _errorMessage = "Email atau password salah.";
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Metode untuk Logout
  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.signOut();
      _currentUser = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Metode untuk memperbarui profil pengguna (username, phone_number, avatar_url)
  Future<bool> updateUserProfile({
    String? username,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (_currentUser == null || _currentUser!.id == null) {
        throw Exception(
          "Pengguna tidak terautentikasi atau ID pengguna tidak ada.",
        );
      }
      await _authService.updateUserProfile(
        userId: _currentUser!.id!,
        username: username,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
      );
      _currentUser = await _authService.getCurrentUserWithProfile();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Metode untuk memperbarui email pengguna
  Future<bool> updateEmail(String newEmail) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (_currentUser == null) {
        throw Exception("Pengguna tidak terautentikasi.");
      }
      await _authService.updateUserAuth(newEmail: newEmail);
      _currentUser = await _authService.getCurrentUserWithProfile();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Metode untuk memperbarui kata sandi pengguna
  Future<bool> updatePassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (_currentUser == null) {
        throw Exception("Pengguna tidak terautentikasi.");
      }
      await _authService.updateUserAuth(newPassword: newPassword);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Metode untuk Mengelola Avatar di Provider
  Future<bool> uploadAvatar(dynamic imageContent, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final String publicUrl = await _authService.uploadAvatar(
        userId,
        imageContent, // Meneruskan dynamic content (File atau Uint8List)
      );
      await updateUserProfile(avatarUrl: publicUrl);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
}
