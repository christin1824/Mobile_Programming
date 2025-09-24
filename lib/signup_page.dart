import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Ganti warna latar belakang menjadi putih
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bagian atas dengan teks "Belum Punya Akun?"
            Container(
              height: 200,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 50.0),
              decoration: const BoxDecoration(
                color: Color(0xFFE54721),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(50.0)),
              ),
              child: const Text(
                'Belum Punya Akun?',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Bagian bawah dengan form sign up
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDEAE4),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                              );
                            },
                            child: const Text(
                              'Masuk',
                              style: TextStyle(color: Color(0xFFE54721), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE54721),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Daftar',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Nama',
                      filled: true,
                      fillColor: const Color(0xFFFDEAE4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFFE54721), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Nomor Telepon',
                      filled: true,
                      fillColor: const Color(0xFFFDEAE4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFFE54721), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: const Color(0xFFFDEAE4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFFE54721), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Input Kata Sandi
                  TextField(
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Kata Sandi',
                      filled: true,
                      fillColor: const Color(0xFFFDEAE4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFFE54721), width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey[700],
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Input Konfirmasi Kata Sandi
                  TextField(
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Konfirmasi Kata Sandi',
                      filled: true,
                      fillColor: const Color(0xFFFDEAE4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFFE54721), width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey[700],
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE54721),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Daftar'),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'atau masuk dengan',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton('assets/icons/google.png'),
                      const SizedBox(width: 20),
                      _buildSocialButton('assets/icons/telfon.png'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(String assetPath) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Image.asset(assetPath, height: 30, width: 30),
    );
  }
}