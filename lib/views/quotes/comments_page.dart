import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookan/core/constants/colors.dart';
import 'package:bookan/services/firestore_service.dart';

class CommentsPage extends StatefulWidget {
  final String quoteId;

  const CommentsPage({Key? key, required this.quoteId}) : super(key: key);

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _yorumController = TextEditingController();

  // Yorum Gönderme Fonksiyonu
  void _yorumGonder() async {
    if (_yorumController.text.trim().isNotEmpty) {
      await _firestoreService.yorumYap(widget.quoteId, _yorumController.text.trim());
      _yorumController.clear(); // Yazıyı temizlemek için kullanılıyormuş
      FocusScope.of(context).unfocus(); // Klavyeyi kapatmak için kullanılıyormuş
    }
  }

  // Zamanı bulmak için hesaplama
  String _zamanHesapla(Timestamp? timestamp) {
    if (timestamp == null) return "Az önce";
    DateTime kayitZamani = timestamp.toDate();
    Duration fark = DateTime.now().difference(kayitZamani);

    if (fark.inMinutes < 1) return "Şimdi";
    if (fark.inMinutes < 60) return "${fark.inMinutes}dk";
    if (fark.inHours < 24) return "${fark.inHours}sa";
    return "${fark.inDays}gün";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Yorumlar", style: TextStyle(color: AppColors.renk2, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.renk2),
      ),
      body: Column(
        children: [
          // Yorumları listelemek için
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.yorumlariGetir(widget.quoteId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: AppColors.renk2));
                var docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey[200]),
                        SizedBox(height: 10),
                        Text("Henüz yorum yok. İlk sen yaz!", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    String zaman = _zamanHesapla(data['tarih']);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Yorumdaki resim
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.renk5.withOpacity(0.2),
                            child: Text(
                              data['kullaniciAdi'][0].toUpperCase(),
                              style: TextStyle(color: AppColors.renk5, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: 10),

                          // İsim ve Yorum
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      data['kullaniciAdi'],
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.renk2),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      zaman,
                                      style: TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2),
                                Text(
                                  data['yorum'],
                                  style: TextStyle(color: Colors.black87, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Divider(height: 1),

          // Yorum yazma kısmı
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _yorumController,
                    decoration: InputDecoration(
                      hintText: "Yorum yap...",
                      hintStyle: TextStyle(fontSize: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: _yorumGonder,
                  child: CircleAvatar(
                    backgroundColor: AppColors.renk2,
                    child: Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}