import 'package:flutter/material.dart';
import 'home_page.dart';

class LariPage extends StatefulWidget {
  const LariPage({super.key});

  @override
  State<LariPage> createState() => _LariPageState();
}

class _LariPageState extends State<LariPage> {
  // Anda bisa menambahkan state lain di sini jika diperlukan
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Latar Belakang Placeholder
          Container(
            color: Colors.grey[300], // Warna abu-abu sebagai latar belakang
            child: const Center(
              child: Text(
                'Peta akan ditampilkan di sini.',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
          
          // Bagian Atas
          Positioned(
            top: 50,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LARI',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('Kamis, September 18'),
                  SizedBox(height: 4),
                  Text('Taman Alumni, ITS'),
                ],
              ),
            ),
          ),

          // Kartu Target Jarak (Kuning)
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 250,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                child: const Column(
                  children: [
                    Text(
                      'Target Jarak',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '2.00 Km',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tombol "GO!"
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
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
                  ],
                ),
                child: const Center(
                  child: Text(
                    'GO!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
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
}