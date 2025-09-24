import 'dart:math';
import 'package:flutter/material.dart';
import 'lari_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bagian Header (Orange)
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE54721),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
              ),
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat pagi, User!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Siap olahraga hari ini?',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            
            // Konten Halaman (Putih)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  // Progress Mingguan
                  _buildWeeklyProgress(),
                  const SizedBox(height: 30),

                  // Target Lari & Ilustrasi
                  Row(
                    children: [
                      // Ilustrasi
                      Image.asset(
                        'assets/icons/lari.png',
                        height: 250,
                      ),
                      const SizedBox(width: 20),
                      // Teks Target
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

                  // Progress Bar
                  _buildProgressBar(current: 6550, target: 10000),
                  const SizedBox(height: 30),

                  // Ringkasan Statistik
                  _buildStatsContainer(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Widget Pembantu untuk Progress Mingguan
  Widget _buildWeeklyProgress() {
    final days = ['M', 'S', 'S', 'R', 'K', 'J', 'S'];
    final dates = ['14', '15', '16', '17', '18', '19', '20'];
    final progressValues = [0.7, 0.5, 0.8, 0.4, 0.0, 0.0, 0.0]; // Contoh nilai progress

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
            final isCompleted = progress > 0;
            final color = isCompleted ? Colors.orange : Colors.grey;

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
                  days[index],
                  style: TextStyle(color: color),
                ),
                Text(
                  dates[index],
                  style: TextStyle(color: color),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  // Custom Painter untuk menggambar lingkaran progress
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

  // Widget Pembantu untuk Statistik
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

  // Widget Pembantu untuk Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.run_circle),
          label: 'Lari',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Akun',
        ),
      ],
      currentIndex: 0,
      selectedItemColor: const Color(0xFFE54721),
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