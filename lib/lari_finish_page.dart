import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'home_page.dart';
import 'akun_page.dart';

class LariFinishPage extends StatelessWidget {
  final List<LatLng> routePoints;
  final double distance;
  final int durationMinutes;
  final int durationSeconds;
  final int calories;

  const LariFinishPage({
    super.key,
    required this.routePoints,
    required this.distance,
    required this.durationMinutes,
    required this.durationSeconds,
    required this.calories,
  });

  // MARK: - LOGIC REAL-TIME TIME OF DAY

  /// Menentukan label waktu (Pagi, Siang, Sore, Malam) berdasarkan jam saat ini.
  String _getRunTimeOfDay() {
    final int hour = DateTime.now().hour;

    if (hour >= 5 && hour <= 10) {
      return 'Pagi'; // Jam 05:00 - 10:59
    } else if (hour >= 11 && hour <= 14) {
      return 'Siang'; // Jam 11:00 - 14:59
    } else if (hour >= 15 && hour <= 18) {
      return 'Sore'; // Jam 15:00 - 18:59
    } else {
      return 'Malam'; // Jam 19:00 - 04:59
    }
  }

  // MARK: - GET START AND END POINTS

  // Titik Awal Lari
  LatLng? get _startPoint => routePoints.isNotEmpty ? routePoints.first : null;
  // Titik Akhir Lari
  LatLng? get _endPoint => routePoints.isNotEmpty ? routePoints.last : null;

  @override
  Widget build(BuildContext context) {
    // Ambil label waktu secara real-time
    final String runTimeLabel = _getRunTimeOfDay();

    // Tentukan pusat peta agar mencakup semua rute
    final LatLng centerPoint = _startPoint ?? const LatLng(-7.2575, 112.7521);

    // KETEBELAN GARIS DITINGKATKAN DARI 6.0 MENJADI 8.0
    const double polylineStrokeWidth = 8.0;

    return Scaffold(
      body: Stack(
        children: [
          // Map with route polyline and markers
          FlutterMap(
            options: MapOptions(
              // Pastikan peta berpusat pada rute lari
              initialCenter: centerPoint,
              initialZoom: 15.5,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.maptiler.com/maps/openstreetmap/{z}/{x}/{y}.png?key=oRyZXl1bSYtekMhN6tw7',
                userAgentPackageName: 'com.stridez.app',
              ),

              // Rute (Track) Lari: Dibuat lebih tebal
              if (routePoints.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: const Color.fromARGB(255, 21, 42, 224),
                      strokeWidth: polylineStrokeWidth, // Ketebalan 8.0
                    ),
                  ],
                ),

              // Marker Titik Awal dan Akhir
              if (_startPoint != null && _endPoint != null)
                MarkerLayer(
                  markers: [
                    // Marker Titik Awal (Start Point) - Warna Hijau
                    Marker(
                      point: _startPoint!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.run_circle,
                        color: Colors.green, // Warna Hijau untuk START
                        size: 40,
                      ),
                    ),
                    // Marker Titik Akhir (End Point) - Warna Merah
                    Marker(
                      point: _endPoint!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.flag,
                        color: Color(0xFFE54721), // Warna Merah-Oranye untuk FINISH
                        size: 35,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Header & summary
          Positioned(
            top: 40,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_run, color: Color(0xFFE54721), size: 35),
                    const SizedBox(width: 8),
                    // MENGGUNAKAN LABEL WAKTU DINAMIS
                    Text(
                      'Lari $runTimeLabel', 
                      style: const TextStyle(
                        fontSize: 30, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFFE54721)
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  // Format jarak dengan koma sebagai pemisah desimal
                  distance.toStringAsFixed(2).replaceAll('.', ','),
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFFE54721)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kilometer',
                  style: TextStyle(fontSize: 43, fontWeight: FontWeight.bold, color: Color(0xFFE54721)),
                ),
              ],
            ),
          ),
          // Info panel
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Durasi
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Color(0xFFE54721), size: 28),
                      const SizedBox(width: 8),
                      const Text('DURASI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                      const SizedBox(width: 12),
                      Text(
                        '${durationMinutes.toString().padLeft(2, '0')} : ${durationSeconds.toString().padLeft(2, '0')} min',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Kalori
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Color(0xFFE54721), size: 28),
                      const SizedBox(width: 8),
                      const Text('KALORI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                      const SizedBox(width: 12),
                      Text(
                        '$calories Kcal',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.run_circle), label: 'Lari'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
        currentIndex: 1,
        selectedItemColor: const Color(0xFFE54721),
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AccountPage()),
            );
          }
        },
      ),
    );
  }
}