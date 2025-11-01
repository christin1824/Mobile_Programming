import 'package:intl/intl.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
// Import Google Maps dengan alias
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

// Import lokal Anda
import 'home_page.dart';
import 'lari_finish_page.dart';
import 'akun_page.dart'; 

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
  // === STATE VARIABELS ===
  
  // 1. INISIALISASI LOKASI DENGAN DEFAULT AGAR PETA BISA LANGSUNG TERBUKA
  gmaps.LatLng? _currentLocation = const gmaps.LatLng(-7.2820, 112.7944); 
  Position? _previousPosition; 
  StreamSubscription<Position>? _positionStreamSubscription;
  
  final List<gmaps.LatLng> _routePoints = []; 

  // Variabel Tracking
  bool isPaused = false;
  Timer? _timer;
  double currentProgress = 0.0; // km
  double currentDistance = 0.0; // km
  double _currentSpeed = 0.0; // m/s
  int durationMinutes = 0; 
  int durationSeconds = 0;
  int calories = 0; 
  String? _currentAddress;
  bool _isLoading = true; // Tetap true saat awal untuk menampilkan overlay

  // --- GETTERS DAN HELPER ---

  bool get isTanpaTarget => widget.targetJarak == 0 && widget.targetWaktu == 0;
  
  String _getFormattedDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, d MMMM', 'id_ID').format(now);
  }

  // Fungsi untuk memformat durasi menjadi MM:SS
  String _formatDuration(int minutes, int seconds) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  // --- LOGIKA LOKASI DAN TIMER ---
  
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      
      const double minRunningSpeed = 0.5; 
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
  
  void _startPositionStream() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    ).listen((Position position) {
      if (!mounted) return;
      
      setState(() {
        gmaps.LatLng newPoint = gmaps.LatLng(position.latitude, position.longitude);

        _currentLocation = newPoint; 
        
        // JIKA LOKASI BERHASIL DIDAPATKAN PERTAMA KALI, HENTIKAN LOADING
        // Loading hanya untuk overlay, tetapi UI header tetap terlihat.
        _isLoading = false;

        // --- PENGUMPULAN RUTE LARI ---
        _routePoints.add(newPoint); 
        // -----------------------------

        // --- AMBIL KECEPATAN ---
        _currentSpeed = position.speed;
        
        // Logika Perhitungan Jarak
        if (_previousPosition != null) {
          double distanceInMeters = Geolocator.distanceBetween(
            _previousPosition!.latitude,
            _previousPosition!.longitude,
            position.latitude,
            position.longitude,
          );
          
          if (distanceInMeters > 0) { 
            currentDistance += distanceInMeters / 1000; // Konversi ke Km
          }
        }
        
        _previousPosition = position;
      });
      
      _updateAddressFromLocation();
    });
  }

  Future<void> _updateAddressFromLocation() async {
    // HANYA JALANKAN JIKA LOKASI SAAT INI BUKAN DEFAULT (Surabaya)
    if (_currentLocation == null || (_currentLocation!.latitude == -7.2820 && _currentLocation!.longitude == 112.7944)) {
        // SET ALAMAT SEMENTARA SAAT MASIH LOKASI DEFAULT
        if (_currentAddress == null || _currentAddress!.isEmpty) {
            setState(() {
                _currentAddress = "Mencari lokasi...";
            });
        }
        return; 
    }
    
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
      } else {
          setState(() {
              _currentAddress = "Lokasi tidak terdeteksi";
          });
      }
    } catch (e) {
        setState(() {
            _currentAddress = "Gagal memuat alamat";
        });
    }
  }

  // --- LIFECYCLE ---

  @override
  void initState() {
    super.initState();
    // Panggil _updateAddressFromLocation di initState untuk inisialisasi teks 'Mencari lokasi...'
    // sebelum stream lokasi dimulai
    _updateAddressFromLocation(); 
    _startPositionStream();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
  
  // --- WIDGETS ---

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
        } else if (index == 2) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AccountPage()),
          );
        }
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // === PETA INTERAKTIF ===
          gmaps.GoogleMap(
            // Target peta selalu menggunakan _currentLocation (yang sudah punya nilai default)
            initialCameraPosition: gmaps.CameraPosition(
              target: _currentLocation!, 
              zoom: 17.0,
            ),
            markers: {
              if (_currentLocation != null)
                gmaps.Marker(
                  markerId: const gmaps.MarkerId('currentLocation'),
                  position: _currentLocation!,
                  icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueBlue),
                ),
            },
            polylines: {
                gmaps.Polyline(
                    polylineId: const gmaps.PolylineId('runRoute'),
                    points: _routePoints,
                    color: const Color(0xFFE54721),
                    width: 5,
                ),
            }
          ),

          // Tampilkan layar loading di atas peta JIKA _isLoading masih true
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
            
          // --- UI LARI (HEADER & KONTROL) ---
          // TIDAK ADA LAGI if (!_isLoading) yang memblokir header
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
                          // MENGGUNAKAN _currentAddress (yang sudah diinisialisasi 'Mencari lokasi...')
                          _currentAddress ?? 'Lokasi tidak terdeteksi',
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
                                : '${_formatDuration(durationMinutes, durationSeconds)}', 
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
                                  : '${widget.targetWaktu} Min',
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
                      
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => LariFinishPage(
                            routePoints: _routePoints, 
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
          // HAPUS if (!_isLoading) yang di sini
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
