import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookan/models/book_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Favoriye Ekle --> kullanıcı id'ye göre favorilerine kitabin bilgilerini kaydediyor
  Future<void> favoriyeEkle(BookModel kitap) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favoriler')
        .doc(kitap.id)
        .set({
      'id': kitap.id,
      'baslik': kitap.baslik,
      'yazar': kitap.yazar,
      'resimUrl': kitap.resimUrl,
      'eklenmeTari': FieldValue.serverTimestamp(),
    });
  }

  // Favoriden Çıkar --> aynı klasöre gidip o kitabı siliyor
  Future<void> favoridenCikar(String kitapId) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favoriler')
        .doc(kitapId)
        .delete();
  }

  // Favori Kontrol --> true ya da false kitap favori ise kalp dolu değilse boş yapmaya yarıyor
  Future<bool> favoriMi(String kitapId) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favoriler')
        .doc(kitapId)
        .get();

    return doc.exists;
  }


  // Yeni Liste Oluştur --> kullaniciya liste oluşturuyor ilk başta içi boş oluyor
  Future<void> yeniListeOlustur(String listeAdi) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('listeler')
        .add({
      'listeAdi': listeAdi,
      'olusturulmaTarihi': FieldValue.serverTimestamp(),
    });
  }

  // Listeleri Getir --> kullanıcıya ait listeleri getiriyor sayfa yenilemeye gerek kalmadan orada beliriyor
  Stream<QuerySnapshot> listeleriGetir() {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.empty();

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('listeler')
        .orderBy('olusturulmaTarihi', descending: false)
        .snapshots();
  }

  // Kitabı Listeye Ekle --> seçilen kitabın bilgilerini listeye ekliyor
  Future<void> kitabiListeyeEkle(String listeId, BookModel kitap) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('listeler')
        .doc(listeId)
        .collection('kitaplar')
        .doc(kitap.id)
        .set({
      'id': kitap.id,
      'baslik': kitap.baslik,
      'yazar': kitap.yazar,
      'resimUrl': kitap.resimUrl,
      'eklenmeTarihi': FieldValue.serverTimestamp(),
    });
  }


  // Okunanlara Ekle --> favoriler kısmı ile aynı mantıkta kitabı okunan listesine ekliyor
  Future<void> okunanlaraEkle(BookModel kitap) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('okunanlar')
        .doc(kitap.id)
        .set({
      'id': kitap.id,
      'baslik': kitap.baslik,
      'yazar': kitap.yazar,
      'resimUrl': kitap.resimUrl,
      'okunmaTarihi': FieldValue.serverTimestamp(),
    });
  }

  // Okunanlardan Çıkar --> aynı mantıkta okunanlar listesinden çıkarıyor
  Future<void> okunanlardanCikar(String kitapId) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('okunanlar')
        .doc(kitapId)
        .delete();
  }

  // Okundu Kontrol --> kitap okunmuş mu kontrol ediyor okunmuş ise dolu değlse boş oluyor
  Future<bool> okunduMu(String kitapId) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('okunanlar')
        .doc(kitapId)
        .get();

    return doc.exists;
  }


  // Genel Alıntı Paylaş  --> alıntı paylaşmadan önce kullanıcının adını ve profil fotoğrafını alıyor
  Future<void> genelAlintiPaylas({
    required String kitapAdi,
    required String yazar,
    required String alinti,
    String? resimUrl,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("Giriş yapılmamış");

    String paylasanKisi = "Kullanıcı";
    String paylasanResim = "";

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        var data = userDoc.data() as Map<String, dynamic>;
        paylasanKisi = data['kullaniciadi'] ?? "Kullanıcı";
        paylasanResim = data['avatarUrl'] ?? "";
      }
    } catch (e) {
      print("Kullanıcı verisi çekilemedi: $e");
    }

    await _firestore.collection('feed').add({
      'paylasanId': user.uid,
      'paylasanAd': paylasanKisi,
      'paylasanResim': paylasanResim,
      'kitapAdi': kitapAdi,
      'yazar': yazar,
      'alinti': alinti,
      'resimUrl': resimUrl ?? "",
      'tarih': FieldValue.serverTimestamp(),
      'begeniler': [],
    });
  }

  // Tüm Alıntıları Getir --> Alıntılar herkesin paylaştığı alıntıları tarihe göre sıralıyor
  Stream<QuerySnapshot> tumAlintilariGetir() {
    return _firestore
        .collection('feed')
        .orderBy('tarih', descending: true)
        .snapshots();
  }

  // Sadece Benim Alıntılarımı Getir --> sadece giriş yapmış kullanıcının paylaştıklarını getiriyor
  Stream<QuerySnapshot> alintilariGetir() {
    User? user = _auth.currentUser;
    if (user == null) return Stream.empty();

    return _firestore
        .collection('feed')
        .where('paylasanId', isEqualTo: user.uid)
        .snapshots();
  }

  // Alıntı Sil
  Future<void> alintiSil(String docId) async {
   await _firestore.collection('feed').doc(docId).delete();
  }

  // Alıntıyı Beğen --> Kullanıcı beğene basınca beğenme çalışıyor zaten beğenmiş ise çıkartıyor
  Future<void> alintiyiBegen(String docId) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentReference docRef = _firestore.collection('feed').doc(docId);
    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      List begeniler = (doc.data() as Map)['begeniler'] ?? [];

      if (begeniler.contains(user.uid)) {
        await docRef.update({
          'begeniler': FieldValue.arrayRemove([user.uid])
        });
      } else {
        await docRef.update({
          'begeniler': FieldValue.arrayUnion([user.uid])
        });
      }
    }
  }

  // Yorum Yap  --> alıntı altında yorumu yazmaya yarıyor
  Future<void> yorumYap(String quoteId, String yorumMetni) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    String yorumYapan = "Kullanıcı";

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        yorumYapan = (userDoc.data() as Map)['kullaniciadi'] ?? "Kullanıcı";
      }
    } catch (e) {
      print("İsim hatası: $e");
    }

    await _firestore
        .collection('feed')
        .doc(quoteId)
        .collection('comments')
        .add({
      'userId': user.uid,
      'kullaniciAdi': yorumYapan,
      'yorum': yorumMetni,
      'tarih': FieldValue.serverTimestamp(),
    });
  }

  // Yorumları Getir --> ilgili alıntıya yapılan yorumları canlı olarak listelemeye yarıyor
  Stream<QuerySnapshot> yorumlariGetir(String quoteId) {
    return _firestore
        .collection('feed')
        .doc(quoteId)
        .collection('comments')
        .orderBy('tarih', descending: false)
        .snapshots();
  }


  // Puanı Kaydet --> kullanının kitap puanını kaydediyor
  Future<void> puaniKaydet(BookModel book, int puan) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('ratings')
        .doc(book.id)
        .set({
      'puan': puan,
      'kitapAdi': book.baslik,
      'tarih': FieldValue.serverTimestamp(),
    });
  }

  // Puanı Getir  --> kullanıcıya ait kitapların puanlarını getiriyor
  Future<int> puaniGetir(String bookId) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return 0;

    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('ratings')
        .doc(bookId)
        .get();

    if (doc.exists) {
      return (doc.data() as Map)['puan'] ?? 0;
    }
    return 0;
  }


  // Profil Bio Güncelleme --> kullanıcıya ait bilgileri güncelliyor aynı zamanda eski gönderileri de güncelliyor
  Future<void> profiliGuncelle({
    required String yeniAd,
    required String yeniBio,
    required String yeniResimUrl
  }) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'kullaniciadi': yeniAd,
        'bio': yeniBio,
        'avatarUrl': yeniResimUrl,
      });
    } catch (e) {
      await _firestore.collection('users').doc(userId).set({
        'kullaniciadi': yeniAd,
        'bio': yeniBio,
        'avatarUrl': yeniResimUrl,
        'email': _auth.currentUser?.email,
      }, SetOptions(merge: true));
    }

    try {
      var anlikdosya = await _firestore
          .collection('feed')
          .where('paylasanId', isEqualTo: userId)
          .get();

      //// 'Batch' --> bu sayede birden fazla işlem yapılıyor tüm eski gönderilerimdeki bilgiler de güncelleniyor
      WriteBatch batch = _firestore.batch();

      for (var doc in anlikdosya.docs) {
        batch.update(doc.reference, {
          'paylasanAd': yeniAd,
          'paylasanResim': yeniResimUrl, // Resim de güncelleniyor
        });
      }

      // Batch işlemi tamamlanıyor ve eski gönderilerde güncelleniyor
      await batch.commit();
      print("Tüm eski gönderiler başarıyla güncellendi.");

    } catch (e) {
      print("Feed güncelleme hatası: $e");
    }
  }
}