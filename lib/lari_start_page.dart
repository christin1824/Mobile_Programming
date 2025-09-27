import 'package:intl/intl.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'lari_finish_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Custom painter untuk progress lingkaran
class TargetProgressPainter extends CustomPainter {
  final double progress; // 0.0 - 1.0
  final Color color;
  final double strokeWidth;
  TargetProgressPainter({required this.progress, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final bgPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    // Background circle
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 0, 2 * 3.1416, false, bgPaint);
    // Foreground arc (progress)
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.1416/2, 2 * 3.1416 * progress, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LariStartPage extends StatefulWidget {
  final bool isTargetJarak;
  final double targetJarak;
  final int targetWaktu;

  const LariStartPage({
    super.key,
    required this.isTargetJarak,
    required this.targetJarak,
    required this.targetWaktu,
  });

  @override
  State<LariStartPage> createState() => _LariStartPageState();
}

class _LariStartPageState extends State<LariStartPage> {
  // Fungsi untuk memformat durasi menjadi MM:SS
  String _formatDuration(int minutes, int seconds) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  // Logika: Target dianggap "Tanpa Target" jika kedua nilai target disetel ke nol.
  bool get isTanpaTarget => widget.targetJarak == 0 && widget.targetWaktu == 0;
  
  bool isPaused = false;
  Timer? _timer;
  
  // Variabel State Lari
  LatLng? _currentLocation;
  double currentProgress = 0.0;
  double currentDistance = 0.0; // Jarak yang sudah ditempuh
  Position? _previousPosition; // VARIABEL BARU UNTUK TRACKING JARAK
  double _currentSpeed = 0.0; // VAR BARU: Kecepatan dalam m/s
  
  // Durasi aktual lari dan kalori
  int durationMinutes = 0; 
  int durationSeconds = 0;
  int calories = 0; // Masih dummy 0

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      
      // LOGIKA UTAMA: Timer HANYA berjalan jika kecepatan > 0.5 m/s (bergerak)
      // DAN tidak dalam keadaan JEDA (isPaused).
      const double minRunningSpeed = 0.5; // Ambang batas (0.5 m/s = 1.8 km/jam)
      if (_currentSpeed > minRunningSpeed && !isPaused) {
        setState(() {
          // Logika penghitungan Durasi
          if (durationSeconds < 59) {
            durationSeconds++;
          } else {
            durationSeconds = 0;
            durationMinutes++;
          }
          
          // Logika Progress Lingkaran
          if (widget.isTargetJarak) {
            currentProgress = widget.targetJarak == 0 ? 0 : (currentDistance / widget.targetJarak);
          } else {
            currentProgress = widget.targetWaktu == 0 ? 0 : ((durationMinutes * 60 + durationSeconds) / (widget.targetWaktu * 60));
          }
          
          currentProgress = currentProgress.clamp(0.0, 1.0);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startPositionStream();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateAddressFromLocation());
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
  
  String? _currentAddress;
  bool _isLoading = true;
  String _getFormattedDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, d MMMM', 'id_ID').format(now);
  }
  
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
      currentIndex: 1,
      selectedItemColor: const Color(0xFFE54721),
      onTap: (index) {
        if (index == 0) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      },
    );
  }
  
  StreamSubscription<Position>? _positionStreamSubscription;

  void _startPositionStream() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    ).listen((Position position) {
      if (!mounted) return;
      
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;

        // --- AMBIL KECEPATAN (position.speed) ---
        // position.speed memberikan kecepatan dalam meter per detik (m/s)
        _currentSpeed = position.speed;
        
        // Logika Perhitungan Jarak (BARU)
        if (_previousPosition != null) {
          double distanceInMeters = Geolocator.distanceBetween(
            _previousPosition!.latitude,
            _previousPosition!.longitude,
            position.latitude,
            position.longitude,
          );
          // Tambahkan jarak, KECUALI jika kecepatan GPS menunjukkan 0 (untuk menghindari drift/loncatan jarak saat diam)
          if (distanceInMeters > 0) { 
            currentDistance += distanceInMeters / 1000;
          }
        }
        
        // Simpan posisi saat ini sebagai posisi sebelumnya
        _previousPosition = position;
      });
      
      _updateAddressFromLocation();
    });
  }

  Future<void> _updateAddressFromLocation() async {
    if (_currentLocation == null) return;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _currentAddress = [
            if (p.name != null && p.name!.isNotEmpty) p.name,
            if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality,
            if (p.locality != null && p.locality!.isNotEmpty) p.locality,
            if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) p.administrativeArea,
          ].whereType<String>().where((e) => e.isNotEmpty).join(', ');
        });
      }
    } catch (e) {
      // ignore error
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            options: MapOptions(
              initialCenter: _currentLocation ?? const LatLng(-7.2575, 112.7521), // Surabaya
              initialZoom: 16.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.maptiler.com/maps/openstreetmap/{z}/{x}/{y}.png?key=oRyZXl1bSYtekMhN6tw7',
                userAgentPackageName: 'com.stridez.app',
              ),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentLocation!,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 30.0,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Header, tanggal, lokasi
          Positioned(
            top: 40,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LARI',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getFormattedDate(),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.black87, size: 18),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        (_currentAddress == null || _currentAddress!.isEmpty)
                            ? 'Lokasi tidak ditemukan'
                            : _currentAddress!,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Mencari lokasi Anda..."),
                  ],
                ),
              ),
            ),

          // Lingkaran Progres Lari
          Positioned(
            top: 180,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(220, 220),
                      painter: TargetProgressPainter(
                        progress: currentProgress, 
                        color: const Color(0xFFE54721),
                        strokeWidth: 18,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Teks Utama Lingkaran (Km atau MM:SS Min)
                        Text(
                          (widget.isTargetJarak || isTanpaTarget)
                              ? '${currentDistance.toStringAsFixed(1)} Km' 
                              : '${_formatDuration(durationMinutes, durationSeconds)} Min', 
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        // HANYA tampilkan Target Harian jika BUKAN mode Tanpa Target
                        if (!isTanpaTarget) ...[
                          const SizedBox(height: 4),
                          Text(
                            // Nilai target kecil
                            widget.isTargetJarak
                                ? '${widget.targetJarak.toStringAsFixed(1)} Km'
                                : '${widget.targetWaktu} min',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Target Harian',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Informasi Durasi/Jarak dan Kalori
          Positioned(
            bottom: 140,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withOpacity(0.25),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Info pendamping (durasi/jarak)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            widget.isTargetJarak ? Icons.timer : Icons.directions_run,
                            color: Colors.deepOrange,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.isTargetJarak ? 'DURASI' : 'JARAK',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        // Nilai pendamping
                        widget.isTargetJarak
                            ? _formatDuration(durationMinutes, durationSeconds) 
                            : '${currentDistance.toStringAsFixed(2)} Km', 
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                  // Kalori
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 28),
                          SizedBox(width: 8),
                          Text('KALORI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                        ],
                      ),
                      const SizedBox(height: 8),
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

          // Tombol Jeda dan Selesai
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tombol JEDA bulat
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isPaused = !isPaused;
                    });
                  },
                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE54721), width: 7),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isPaused ? 'LANJUT' : 'JEDA',
                        style: const TextStyle(color: Color(0xFFE54721), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                // Tombol FINISH bulat
                GestureDetector(
                  onTap: () {
                    _timer?.cancel();
                    // Kumpulkan data tracking
                    List<LatLng> routePoints = [];
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => LariFinishPage(
                          routePoints: routePoints,
                          distance: currentDistance,
                          durationMinutes: durationMinutes,
                          durationSeconds: durationSeconds,
                          calories: calories,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE54721),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('FINISH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}