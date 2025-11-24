import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Sign In dengan Email/Password (Login - Hanya memeriksa kredensial)
  // Mengembalikan pesan error (String) jika gagal, atau null jika berhasil.
  Future<String?> signInWithEmailPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; 
    } on FirebaseAuthException catch (e) {
      return e.message; 
    } catch (e) {
      return e.toString();
    }
  }

  // 2. Sign In dengan Google (Login/Pendaftaran via Google)
  // Mengembalikan UserCredential jika berhasil, atau null jika gagal.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Mulai proses interaktif Google Sign In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null; // Pengguna membatalkan proses
      }

      // Mendapatkan kredensial dari Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in ke Firebase dengan kredensial Google
      // Ini akan membuat user baru jika belum ada (Sign Up) atau login (Sign In).
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Mengembalikan credential untuk mendapatkan UID
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Google Sign In Error: ${e.message}');
      return null;
    } catch (e) {
      // Ini sering terjadi jika konfigurasi Android/iOS belum lengkap
      print('Gagal Sign In Google: ${e.toString()}');
      return null;
    }
  }

  // 3. Sign Up dengan Email/Password (Pendaftaran)
  // Fungsi ini digunakan untuk membuat akun baru dan MENGEMBALIKAN UserCredential
  // agar kita bisa mengambil UID untuk sinkronisasi.
  Future<UserCredential?> signUpWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // PENTING: Mengembalikan credential yang berisi UID!
      return userCredential; 
    } on FirebaseAuthException {
      return null;
    } catch (_) {
      return null;
    }
  }
  
  // 4. Sign In dengan Nomor Telepon (Hanya bagian inisiasi)
  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(PhoneAuthCredential) verificationCompleted,
    Function(FirebaseAuthException) verificationFailed,
    Function(String, int?) codeSent,
    Function(String) codeAutoRetrievalTimeout,
  ) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  } // <--- Penutup fungsi verifyPhoneNumber yang sebelumnya hilang

  // 5. Getter untuk mendapatkan UID atau User saat ini (berguna untuk API calls)
  User? get currentUser => _auth.currentUser;

  // 6. Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}