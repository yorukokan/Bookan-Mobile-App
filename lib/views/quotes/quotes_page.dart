import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookan/core/constants/colors.dart';
import 'package:bookan/services/firestore_service.dart';
import 'package:bookan/services/book_service.dart';
import 'package:bookan/models/book_model.dart';

class QuotesPage extends StatefulWidget {
  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final BookService _bookService = BookService();

  // Alıntı eklemek için
  void _alintiEkleDialog() {
    TextEditingController _kitapAdiController = TextEditingController();
    TextEditingController _alintiController = TextEditingController();
    TextEditingController _yazarController = TextEditingController();
    bool _yukleniyor = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    top: 20, left: 20, right: 20
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Alıntı Paylaş", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.renk2), textAlign: TextAlign.center),
                    SizedBox(height: 20),
                    TextField(
                      controller: _kitapAdiController,
                      decoration: InputDecoration(
                        labelText: "Kitap Adı",
                        hintText: "Örn: Suç ve Ceza",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(Icons.book, color: AppColors.renk3),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _yazarController,
                      decoration: InputDecoration(
                        labelText: "Yazar (Opsiyonel)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(Icons.person, color: AppColors.renk3),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _alintiController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Alıntı Metni",
                        hintText: "Sözü buraya yaz...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        alignLabelWithHint: true,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _yukleniyor ? null : () async {
                        if(_kitapAdiController.text.isNotEmpty && _alintiController.text.isNotEmpty) {
                          setModalState(() { _yukleniyor = true; });
                          String bulunanResimUrl = "";
                          String bulunanYazar = _yazarController.text;
                          try {
                            List<BookModel> sonuclar = await _bookService.searchBooks(_kitapAdiController.text.trim());
                            if (sonuclar.isNotEmpty) {
                              bulunanResimUrl = sonuclar.first.resimUrl;
                              if (bulunanYazar.isEmpty) {
                                bulunanYazar = sonuclar.first.yazar;
                              }
                            }
                          } catch (e) { print("Kapak hatası: $e"); }

                          await _firestoreService.genelAlintiPaylas(
                            kitapAdi: _kitapAdiController.text.trim(),
                            yazar: bulunanYazar.isEmpty ? "Bilinmiyor" : bulunanYazar,
                            alinti: _alintiController.text.trim(),
                            resimUrl: bulunanResimUrl,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Paylaşıldı!")));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.renk2, foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _yukleniyor
                          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text("PAYLAŞ"),
                    )
                  ],
                ),
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Alıntılar", style: TextStyle(color: AppColors.renk2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.tumAlintilariGetir(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: AppColors.renk2));
          var docs = snapshot.data!.docs;

          if (docs.isEmpty) return Center(child: Text("Henüz hiç alıntı paylaşılmamış. İlk sen ol!"));

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return QuoteCard(doc: docs[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _alintiEkleDialog,
        backgroundColor: AppColors.renk2,
        child: Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }
}
class QuoteCard extends StatefulWidget {
  final DocumentSnapshot doc;

  const QuoteCard({Key? key, required this.doc}) : super(key: key);

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final TextEditingController _yorumController = TextEditingController();

  bool _yorumlariGoster = false;

  String _zamanHesapla(Timestamp? timestamp) {
    if (timestamp == null) return "Az önce";
    DateTime kayitZamani = timestamp.toDate();
    Duration fark = DateTime.now().difference(kayitZamani);
    if (fark.inMinutes < 1) return "Şimdi";
    if (fark.inMinutes < 60) return "${fark.inMinutes} dk";
    if (fark.inHours < 24) return "${fark.inHours} sa";
    return "${fark.inDays} gn";
  }

  void _yorumGonder() async {
    if (_yorumController.text.trim().isNotEmpty) {
      await _firestoreService.yorumYap(widget.doc.id, _yorumController.text.trim());
      _yorumController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.doc.data() as Map<String, dynamic>;
    String docId = widget.doc.id;
    String resimUrl = data['resimUrl'] ?? "";
    List begeniler = data['begeniler'] ?? [];
    bool begenmisMi = begeniler.contains(_currentUserId);
    int begeniSayisi = begeniler.length;
    String tarih = _zamanHesapla(data['tarih']);
    String userAvatarUrl = data['paylasanResim'] ?? "";

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kullanıcı  kısmı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              children: [
                // kullanıcı resimi
                CircleAvatar(
                  backgroundColor: AppColors.renk5.withOpacity(0.2),
                  radius: 18,
                  backgroundImage: (userAvatarUrl.isNotEmpty)
                      ? NetworkImage(userAvatarUrl)
                      : null,
                  // Resim yoksa ikon göstermek için
                  child: (userAvatarUrl.isEmpty)
                      ? Icon(Icons.person, color: AppColors.renk5, size: 20)
                      : null,
                ),
                // ---------------------------------------

                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['paylasanAd'] ?? "Kullanıcı", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.renk2)),
                    Text(tarih, style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),

          Divider(height: 1, thickness: 0.5),

          // Resim ve alıntı
          IntrinsicHeight( // fotoğraf ve alıntı boyunu eşitlemek için
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15)),
                      image: DecorationImage(
                        image: (resimUrl.isNotEmpty)
                            ? NetworkImage(resimUrl)
                            :NetworkImage("https://www.publicdomainpictures.net/pictures/30000/velka/plain-white-background.jpg"),
                        fit: BoxFit.cover,
                      )
                  ),
                  child: resimUrl.isEmpty
                      ? Center(child: Icon(Icons.book, size: 40, color: Colors.grey[300]))
                      : null,
                ),

                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber[50]!.withOpacity(0.3),
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.format_quote, color: Colors.amber[800], size: 24),
                        Text(
                          data['alinti'],
                          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.renk2, height: 1.4),
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Container(width: 2, height: 30, color: AppColors.renk5),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['kitapAdi'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text(data['yazar'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Beğenme butonu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                InkWell(
                  onTap: () => _firestoreService.alintiyiBegen(docId),
                  child: Row(
                    children: [
                      Icon(
                        begenmisMi ? Icons.favorite : Icons.favorite_border,
                        color: begenmisMi ? Colors.red : Colors.grey,
                        size: 24,
                      ),
                      SizedBox(width: 5),
                      Text("$begeniSayisi", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                    ],
                  ),
                ),
                SizedBox(width: 25),

                InkWell(
                  onTap: () {
                    setState(() {
                      _yorumlariGoster = !_yorumlariGoster;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, color: _yorumlariGoster ? AppColors.renk2 : Colors.grey, size: 22),
                      SizedBox(width: 5),
                      Text("Yorum Yap", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _yorumlariGoster ? AppColors.renk2 : Colors.grey[700])),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. YORUM BÖLÜMÜ
          if (_yorumlariGoster)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Column(
                children: [
                  Divider(height: 1),
                  SizedBox(
                    height: 150,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestoreService.yorumlariGetir(docId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                        var docs = snapshot.data!.docs;
                        if (docs.isEmpty) return Center(child: Text("İlk yorumu sen yaz! 👇", style: TextStyle(color: Colors.grey, fontSize: 12)));

                        return ListView.builder(
                          padding: EdgeInsets.all(10),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            var yData = docs[index].data() as Map<String, dynamic>;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${yData['kullaniciAdi']}: ",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.renk2),
                                  ),
                                  Expanded(
                                    child: Text(yData['yorum'], style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _yorumController,
                            style: TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: "Yorum yaz...",
                              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey[300]!)),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: _yorumGonder,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.renk2,
                            child: Icon(Icons.send, color: Colors.white, size: 16),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}