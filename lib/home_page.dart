import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lari_page.dart';
import 'akun_page.dart'; // Pastikan AccountPage sudah diimpor
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _displayName = 'User';

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
  }
  
  Future<void> _loadDisplayName() async {
    // Coba load dari SharedPreferences dulu (nama yang disimpan di akun_page)
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_display_name');
    
    if (savedName != null && savedName.isNotEmpty) {
      setState(() {
        _displayName = savedName;
      });
    } else {
      // Fallback ke Firebase Auth jika belum ada di SharedPreferences
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _displayName = (user.displayName != null && user.displayName!.isNotEmpty) 
              ? user.displayName! 
              : (user.email ?? 'User');
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Navigasi ke Beranda (Tetap di sini)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 1) {
      // Navigasi ke Lari
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LariPage()),
      );
    } else if (index == 2) {
      // PENAMBAHAN LOGIKA: Navigasi ke AccountPage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AccountPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePageContent(),
          const LariPage(),
          const AccountPage(), 
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.run_circle),
            label: 'Lari',
          ),
          // Bagian Akun
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFE54721),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomePageContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE54721),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
            ),
            padding: const EdgeInsets.only(top: 75, left: 24, right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat pagi, $_displayName!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Siap olahraga hari ini?',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  _buildWeeklyProgress(),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/lari.png',
                        height: 200,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TARGET\nLARI\nKAMU\nHARI INI!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE54721),
                                height: 1.2,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '10.000 langkah',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFFE54721),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildProgressBar(current: 6550, target: 10000),
                  const SizedBox(height: 30),
                  _buildStatsContainer(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    // Cari Senin minggu ini
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekDates = List.generate(7, (i) => monday.add(Duration(days: i)));
    final progressValues = [0.7, 0.5, 0.8, 0.4, 0.0, 0.0, 0.0]; // dummy

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress Mingguan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(137, 10, 10, 10),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final progress = progressValues[index];
            final date = weekDates[index];
            // Inisial hari: S, S, R, K, J, S, M (Senin-Minggu)
            final dayInitial = DateFormat.E('id_ID').format(date)[0].toUpperCase();
            
            // Cek apakah ini hari ini (untuk highlight hari dan tanggal)
            final isToday = date.year == now.year && 
                           date.month == now.month && 
                           date.day == now.day;
            // Hanya hari ini yang kuning, yang lain abu-abu
            final textColor = isToday ? Colors.orange : Colors.grey;
            
            return Column(
              children: [
                SizedBox(
                  width: 35,
                  height: 35,
                  child: CustomPaint(
                    painter: _ProgressCirclePainter(
                      progress: progress,
                      backgroundColor: Colors.grey[200]!,
                      progressColor: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dayInitial,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildProgressBar({required int current, required int target}) {
    final progress = current / target;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$current / $target Langkah',
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          color: const Color(0xFFE54721),
          minHeight: 12,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  Widget _buildStatsContainer() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE54721),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(icon: Icons.directions_walk, value: '6.500', label: 'Langkah'),
          _buildStatItem(icon: Icons.location_on, value: '4.2', label: 'Km'),
          _buildStatItem(icon: Icons.local_fire_department, value: '180', label: 'Kalori'),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// Custom Painter untuk menggambar lingkaran progress
class _ProgressCirclePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _ProgressCirclePainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Lingkaran latar belakang
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, backgroundPaint);

    // Garis progress
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      final Rect rect = Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2);
      canvas.drawArc(rect, -0.5 * pi, 2 * pi * progress, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}