// lib/model/user.dart
import 'package:supabase_flutter/supabase_flutter.dart' as SupabaseSdk;

class User {
  String? id;
  String email;
  String password;
  String? username;
  String? phoneNumber;
  String? avatarUrl;

  User({
    this.id,
    required this.email,
    required this.password,
    this.username,
    this.phoneNumber,
    this.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: '',
      username: map['username'],
      phoneNumber: map['phone_number'],
      avatarUrl: map['avatar_url'],
    );
  }

  factory User.fromSupabaseUser(SupabaseSdk.User user) {
    final userMetadata = user.userMetadata;

    return User(
      id: user.id,
      email: user.email!,
      password: '',
      username: userMetadata?['username'],
      phoneNumber: userMetadata?['phone_number'],
    );
  }
}
