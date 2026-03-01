import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookan/core/constants/colors.dart';
import 'package:bookan/services/firestore_service.dart';

class MyQuotesPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Alıntılarım", style: TextStyle(color: AppColors.renk2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.renk2),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Servisteki "Sadece benim alıntılarımı getir" fonksiyonunu kullanıyoruz
        stream: _firestoreService.alintilariGetir(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: AppColors.renk2));
          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.format_quote, size: 80, color: Colors.grey[300]),
                  SizedBox(height: 10),
                  Text("Henüz hiç alıntı paylaşmamışsın.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String resimUrl = data['resimUrl'] ?? "";

              // Sağa kaydırınca silme özelliği Dismissible ile aynı listelerdeki gibi
              return Dismissible(
                key: Key(docs[index].id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("SİL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Icon(Icons.delete, color: Colors.white),
                    ],
                  ),
                ),
                onDismissed: (direction) {
                  // Veritabanından silmek için
                  _firestoreService.alintiSil(docs[index].id);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Alıntı silindi")));
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 15),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber[50], // Not kağıdı rengi
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // varsa Kitap Resmi
                      if (resimUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(resimUrl, width: 50, height: 75, fit: BoxFit.cover),
                        ),

                      SizedBox(width: 15),

                      // Yazılar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.format_quote, color: Colors.amber[800], size: 24),
                            Text(
                              data['alinti'],
                              style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.renk2, fontSize: 15),
                            ),
                            SizedBox(height: 10),
                            Divider(color: Colors.amber[200]),
                            Text(
                              data['kitapAdi'] ?? "Bilinmeyen Kitap",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}