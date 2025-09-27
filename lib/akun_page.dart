import 'dart:math';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'lari_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int _selectedIndex = 2; // Index 2 adalah halaman Akun

  // Data dummy untuk tampilan
  final String _userName = 'Icha';
  final String _userEmail = 'icha.cantik@gmail.com';
  final double _weightAwal = 78;
  final double _weightSaatIni = 71;
  final double _weightTarget = 65;
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Logika navigasi menggunakan pushReplacement untuk BottomNavigationBar
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LariPage()),
      );
    } 
    // Jika index == 2 (Akun), tetap di halaman ini.
  }

  @override
  Widget build(BuildContext context) {
    // Tinggi header disesuaikan. Dikecilkan sedikit untuk overlap yang lebih baik.
    const double headerHeight = 220; 
    
    // Mendapatkan tinggi aman status bar
    final double topPadding = MediaQuery.of(context).padding.top; 

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // GANTI DARI STACK MENJADI SINGLECHILDSCROLLVIEW
      body: SingleChildScrollView( 
        // Padding bawah untuk mencegah konten terpotong BottomNavigationBar
        padding: const EdgeInsets.only(bottom: 80), 
        child: Column(
          children: [
            // BAGIAN 1: HEADER MERAH (Ikut di-scroll)
            Container(
              height: 200, 
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE54721),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
              ),
              child: Column(
                children: [
                  SizedBox(height: topPadding), 
                  // Konten header (Foto Profil, Nama, Email)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Foto Profil (Stack)
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            const CircleAvatar(
                              radius: 40, 
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 38, 
                                backgroundImage: AssetImage('assets/icons/profile_placeholder.png'),
                              ),
                            ),
                            // Ikon Edit
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFE54721), width: 1.5),
                              ),
                              child: const Icon(Icons.edit, color: Color(0xFFE54721), size: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _userEmail,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // BAGIAN 2: KONTEN UTAMA (Kartu dan Menu - Ikut di-scroll)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              // Transform.translate menarik konten ke atas untuk efek overlap
              child: Transform.translate(
                offset: const Offset(0, 10), // Menarik konten ke atas 60 piksel
                child: Column(
                  children: [
                    // Kartu Berat Badan
                    _buildWeightCard(),
                    const SizedBox(height: 10), 

                    // Kartu Statistik Cepat
                    _buildQuickStats(),
                    const SizedBox(height: 30),

                    // Tombol Set Goals
                    _buildMenuButton(
                      title: 'Set Goals',
                      icon: Icons.track_changes,
                      onTap: () { /* TODO: Navigasi ke Halaman Set Goals */ },
                    ),
                    const SizedBox(height: 15),

                    // Tombol Riwayat Lari
                    _buildMenuButton(
                      title: 'Riwayat Lari',
                      icon: Icons.history,
                      onTap: () { /* TODO: Navigasi ke Halaman Riwayat Lari */ },
                    ),
                  ],
                ),
              ),
            ),
            // Padding tambahan di bawah
            const SizedBox(height: 30), 
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.run_circle), label: 'Lari'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFE54721),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  // MARK: - Widget Pembantu (Tidak Ada Perubahan)

  Widget _buildWeightCard() {
    return Card(
      elevation: 4,
      color: const Color(0xFFE54721), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'BERAT BADAN',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), 
                ),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Image.asset(
                    'assets/icons/body_target.png',
                    height: 40,
                    color: Colors.white, 
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.accessibility_new, 
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            LinearProgressIndicator(
              value: (_weightAwal - _weightSaatIni) / (_weightAwal - _weightTarget),
              backgroundColor: Colors.white.withOpacity(0.5),
              color: Colors.white,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _weightItem('Awal', '${_weightAwal.toInt()} kg', Colors.white), 
                _weightItem('Saat Ini', '${_weightSaatIni.toInt()} kg', Colors.white), 
                _weightItem('Target', '${_weightTarget.toInt()} kg', Colors.white), 
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _weightItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: color.withOpacity(0.7))), 
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statCircle(Icons.access_time, '0j 50m', 'Total Waktu', Colors.orange),
        _statCircle(Icons.local_fire_department, '747 kal', 'Terbakar', Colors.red),
        _statCircle(Icons.fitness_center, '2 lari', 'Berhasil dilakukan', Colors.blue),
      ],
    );
  }

  Widget _statCircle(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMenuButton({required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFFDEAE4),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFFE54721), size: 30),
                  const SizedBox(width: 15),
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}