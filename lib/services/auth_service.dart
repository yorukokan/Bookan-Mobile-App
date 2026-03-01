import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Firebase auth ve firestore araçlarını çağırma
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Giriş Yapma İşlemi
  Future<User> girisYap(String email, String password) async {
    try {
      UserCredential sonuc = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return sonuc.user!;
    } catch (e) {
      print("Giriş Hatası: $e");
      throw e;
    }
  }

  // Kayıt Olma İşlemi
  Future<User?> kayitOl(
      String email,
      String password,
      String kullaniciadi,
      ) async {
    try {
      // E-posta şifre ile kullanıcıyı oluşturma
      UserCredential sonuc = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı oluşturulduktan sonra kullanıcı verilerini kaydetme
      if (sonuc.user != null) {
        await _firestore.collection('users').doc(sonuc.user!.uid).set({
          'email': email,
          'kullaniciadi': kullaniciadi,
          'uid': sonuc.user!.uid,
          'kayittarihi': FieldValue.serverTimestamp(),
        });
      }
      return sonuc.user;
    } catch (e) {
      print("Kayıt Hatası: $e");
      throw e;
    }
  }

  // Çıkış Yapma İşlemi
  Future<void> cikisYap() async {
    await _auth.signOut();
  }

  // Şifre sıfırlama içim mail gönderme
  Future<void> sifreSifirla(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (hata) {
      print("Şifre Sıfırlama Hatası: $hata");
      throw hata;
    }
  }
}
