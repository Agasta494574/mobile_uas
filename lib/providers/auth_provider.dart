// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as SupabaseSdk;
import '../service/auth_service.dart';
import '../model/user.dart' as AppUser; // Aliaskan model User Anda

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
  // KINI MENERIMA EMAIL, PASSWORD, USERNAME, DAN PHONE
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
      // Teruskan username dan phone ke AuthService.signUp
      final SupabaseSdk.User? supabaseUser = await _authService.signUp(
        email,
        password,
        username,
        phone,
      );
      if (supabaseUser != null) {
        // Setelah registrasi berhasil, Supabase secara otomatis masuk.
        // Anda mungkin ingin segera memuat profil pengguna di sini.
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
        _currentUser =
            await _authService
                .getCurrentUserWithProfile(); // Pastikan profil dimuat setelah login
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
}
