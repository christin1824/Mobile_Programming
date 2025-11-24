import 'dart:async'; // Import untuk Timer

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

import 'home_page.dart'; 
import 'lari_start_page.dart';
import 'akun_page.dart'; 

class LariPage extends StatefulWidget {
  const LariPage({super.key});

  @override
  State<LariPage> createState() => _LariPageState();
}


class _LariPageState extends State<LariPage> {
  String? _currentAddress;
  String _getFormattedDate() {
    final now = DateTime.now();
    // Format: Kamis, 25 September
    return DateFormat('EEEE, d MMMM', 'id_ID').format(now);
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
  String _targetType = 'Target Jarak'; // atau 'Target Waktu' atau 'Tanpa Target'
  double _targetJarakValue = 2.0; // km
  int _targetWaktuValue = 15; // menit
  latlong.LatLng? _currentLocation;
  bool _isLoading = true;
  StreamSubscription<Position>? _positionStreamSubscription;

  /// Mulai stream lokasi agar marker update otomatis saat user bergerak
  void _startPositionStream() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    ).listen((Position position) {
      print('Position: $position'); // Log untuk debugging
      if (!mounted) return;
      setState(() {
        _currentLocation = latlong.LatLng(position.latitude, position.longitude);
      });
      _updateAddressFromLocation(); // Perbarui alamat secara realtime
    });
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _startPositionStream();
  // Update address pertama kali jika sudah ada lokasi
  WidgetsBinding.instance.addPostFrameCallback((_) => _updateAddressFromLocation());
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  /// Menentukan posisi pengguna saat ini dan meminta izin jika diperlukan.
  Future<void> _determinePosition() async {
    // Menambahkan Timeout: Jika lebih dari 10 detik tidak ada lokasi, hentikan loading.
    Timer(const Duration(seconds: 15), () {
      if (_isLoading && mounted) {
        print("Timeout! Gagal mendapatkan lokasi GPS.");
        setState(() {
          _isLoading = false;
          // Set lokasi default jika GPS gagal, agar peta tetap muncul.
          _currentLocation ??= const latlong.LatLng(-7.2820, 112.7944);
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gagal mendapatkan lokasi. Menampilkan lokasi default.'),
          backgroundColor: Colors.red,
        ));
      }
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Layanan lokasi tidak aktif. Mohon aktifkan GPS.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin lokasi ditolak.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return; 
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Izin lokasi ditolak permanen, kami tidak dapat meminta izin.')));
      return;
    }

    print('Masuk ke _determinePosition');
    print('Current Location: $_currentLocation');

    // Tambahkan log di setiap langkah untuk memeriksa alur eksekusi kode
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );
      print('Position: $position');
      if (!mounted) return;
      setState(() {
        _currentLocation = latlong.LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      print('Error mendapatkan lokasi: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    // Fallback: Jika lokasi masih null, gunakan lokasi default
    if (_currentLocation == null) {
      print('Lokasi tidak tersedia, menggunakan lokasi default');
      _currentLocation = const latlong.LatLng(-7.2820, 112.7944);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // === PETA INTERAKTIF ===
          gmaps.GoogleMap(
            initialCameraPosition: gmaps.CameraPosition(
              target: _currentLocation != null
                  ? gmaps.LatLng(_currentLocation!.latitude, _currentLocation!.longitude)
                  : const gmaps.LatLng(-7.2820, 112.7944),
              zoom: 17.0,
            ),
            markers: {
              if (_currentLocation != null)
                gmaps.Marker(
                  markerId: const gmaps.MarkerId('currentLocation'),
                  position: gmaps.LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
                  icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueBlue),
                ),
            },
          ),
          // Tampilkan layar loading di atas peta jika sedang mencari lokasi
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
          // === UI LAINNYA DI ATAS PETA ===
          if (!_isLoading) ...[
            // Hanya tampilkan UI jika tidak loading
            Positioned(
              top: 50,
              left: 24,
              right: 24,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LARI',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        shadows: [
                          Shadow(
                              blurRadius: 10.0,
                              color: Colors.white,
                              offset: Offset(0, 0))
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getFormattedDate(),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                              blurRadius: 10.0,
                              color: Colors.white,
                              offset: Offset(0, 0))
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.black54),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _currentAddress ?? 'Mencari lokasi...',
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.white,
                                    offset: Offset(0, 0))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 300,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 250,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE440),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE54721),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 36,
                              constraints: const BoxConstraints(minWidth: 100, maxWidth: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE54721),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isDense: true,
                                  value: _targetType,
                                  dropdownColor: const Color(0xFFE54721),
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  items: <String>['Target Jarak', 'Target Waktu', 'Tanpa Target']
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Center(child: Text(value)),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _targetType = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.black, size: 32),
                            onPressed: () {
                              setState(() {
                                if (_targetType == 'Target Jarak') {
                                  if (_targetJarakValue > 0.5) {
                                    _targetJarakValue -= 0.5;
                                  }
                                } else {
                                  if (_targetWaktuValue > 1) {
                                    _targetWaktuValue -= 1;
                                  }
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          _targetType == 'Tanpa Target'
                              ? const SizedBox(height: 40)
                              : Text(
                                  _targetType == 'Target Jarak'
                                      ? '${_targetJarakValue.toStringAsFixed(2)} Km'
                                      : '${_targetWaktuValue} Menit',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Color.fromARGB(255, 16, 15, 15), size: 32),
                            onPressed: () {
                              setState(() {
                                if (_targetType == 'Target Jarak') {
                                  _targetJarakValue += 0.5;
                                } else {
                                  _targetWaktuValue += 1;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LariStartPage(
                          isTargetJarak: _targetType == 'Target Jarak',
                          targetJarak: _targetJarakValue,
                          targetWaktu: _targetWaktuValue,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE54721),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE54721).withOpacity(0.5),
                          spreadRadius: 10,
                          blurRadius: 20,
                        ),
                        BoxShadow(
                          color: const Color(0xFFE54721).withOpacity(0.2),
                          spreadRadius: 20,
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'GO!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
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
        } else if (index == 2) {
          // PENAMBAHAN LOGIKA: Navigasi ke AccountPage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AccountPage()),
          );
          }
      } 
    );
  }
}