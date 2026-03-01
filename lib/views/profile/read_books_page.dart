import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookan/core/constants/colors.dart';
import 'package:bookan/models/book_model.dart';
import 'package:bookan/views/book/book_detail.dart';

class ReadBooksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Okuduğum Kitaplar", style: TextStyle(color: AppColors.renk2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.renk2),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('okunanlar') // Okunanları çekiyoruz
            .orderBy('okunmaTarihi', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: AppColors.renk2));
          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
                  SizedBox(height: 10),
                  Text("Henüz okundu olarak işaretlediğin kitap yok.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              BookModel kitap = BookModel(
                id: data['id'],
                baslik: data['baslik'],
                yazar: data['yazar'],
                resimUrl: data['resimUrl'],
                aciklama: "",
                yayinTarihi: "",
              );

              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(kitap.resimUrl, width: 50, fit: BoxFit.cover, errorBuilder: (c,e,s)=>Container(width: 50, color: Colors.grey)),
                  ),
                  title: Text(kitap.baslik, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.renk2)),
                  subtitle: Text(kitap.yazar),
                  trailing: Icon(Icons.check_circle, color: Colors.green),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetail(book: kitap)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}