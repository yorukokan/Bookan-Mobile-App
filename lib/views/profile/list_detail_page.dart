import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/colors.dart';
import '../../models/book_model.dart';
import '../book/book_detail.dart';

class ListDetailPage extends StatelessWidget {
  final String listeId;
  final String listeAdi;

  const ListDetailPage({Key? key, required this.listeId, required this.listeAdi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(listeAdi, style: TextStyle(color: AppColors.renk2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.renk2),
        actions: [
          // Listeyi silme
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              _listeyiSil(context, uid);
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>( // canlı veri çekmek için kullanıyorum
        // O listenin içindeki kitaplar koleksiyonuna gidiyoruz
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('listeler')
            .doc(listeId)
            .collection('kitaplar')
            .orderBy('eklenmeTarihi', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: AppColors.renk2)); // veriler yüklenirken boş beklememek için
          var docs = snapshot.data!.docs;

          if (docs.isEmpty) { // dosya boş olduğu durumda göstermek için ekran
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 70, color: Colors.grey[300]),
                  SizedBox(height: 10),
                  Text("Bu liste şu an boş.", style: TextStyle(color: Colors.grey)),
                  Text("Kitap detay sayfasından listeye ekleme yapabilirsin.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }

          // Kitapları Listele
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;

              // verileri modele çeviriyoruz ki daha iyi görmek için
              BookModel kitap = BookModel(
                id: data['id'],
                baslik: data['baslik'],
                yazar: data['yazar'],
                resimUrl: data['resimUrl'],
                aciklama: "",
                yayinTarihi: "",
              );

              // Kaydırma ile silme işlemi
              return Dismissible(
                key: Key(kitap.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('listeler')
                      .doc(listeId)
                      .collection('kitaplar')
                      .doc(kitap.id)
                      .delete();

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${kitap.baslik} listeden çıkarıldı.")));
                },
                child: Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(kitap.resimUrl, width: 50, fit: BoxFit.cover, errorBuilder: (c,e,s)=>Container(width: 50, color: Colors.grey)),
                    ),
                    title: Text(kitap.baslik, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.renk2)),
                    subtitle: Text(kitap.yazar),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetail(book: kitap)));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Listeyi Komple Silme Fonksiyonu
  void _listeyiSil(BuildContext context, String? uid) {
    if (uid == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Listeyi Sil?"),
        content: Text("'$listeAdi' listesi ve içindeki tüm kitaplar silinecek. Emin misin?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("İptal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // Önce listeyi sil
              await FirebaseFirestore.instance.collection('users').doc(uid).collection('listeler').doc(listeId).delete();
              Navigator.pop(context); // Dialog kapat
              Navigator.pop(context); // Sayfadan çık
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Liste silindi.")));
            },
            child: Text("Sil", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}