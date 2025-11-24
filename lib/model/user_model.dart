// lib/models/user_model.dart

class User {
  final String userId;
  final String name;
  final String? email; // Boleh null jika login via telepon
  final String? phone; // Boleh null jika login via email/google

  // Kolom joinDate tidak perlu dikirim ke server, tapi diterima dari server
  final DateTime? joinDate; 

  User({
    required this.userId,
    required this.name,
    this.email,
    this.phone,
    this.joinDate,
  });

  // Fungsi untuk mengirim data ke Spring Boot (POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      // joinDate tidak dikirim
    };
  }

  // Fungsi untuk menerima data dari Spring Boot (GET)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      // Penanganan joinDate dari String/Timestamp server ke DateTime Dart
      joinDate: json['joinDate'] != null ? DateTime.parse(json['joinDate']) : null, 
    );
  }
}