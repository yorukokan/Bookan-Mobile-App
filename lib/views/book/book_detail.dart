import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookan/core/constants/colors.dart';
import 'package:bookan/models/book_model.dart';
import 'package:bookan/services/firestore_service.dart';
import 'add_quote_page.dart';

class BookDetail extends StatefulWidget {

  final BookModel book;
  const BookDetail({Key? key, required this.book}) : super(key: key);

  @override
  State<BookDetail> createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  final FirestoreService _firestoreService = FirestoreService();

  bool _favorimi = false;
  bool _okunduMu = false;
  int _verilenPuan = 0;
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _durumlariKontrolEt();
  }

  void _durumlariKontrolEt() async {
    bool favoriSonuc = await _firestoreService.favoriMi(widget.book.id);
    bool okunduSonuc = await _firestoreService.okunduMu(widget.book.id);
    int puanSonuc = await _firestoreService.puaniGetir(widget.book.id);

    if (mounted) {
      setState(() {
        _favorimi = favoriSonuc;
        _okunduMu = okunduSonuc;
        _verilenPuan = puanSonuc;
        _yukleniyor = false;
      });
    }
  }

  // Puan Verme Fonksiyonu
  void _puanVer(int puan) async {
    setState(() {
      _verilenPuan = puan;
    });
    await _firestoreService.puaniKaydet(widget.book, puan);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("$puan Yıldız verdin!"),
        duration: Duration(milliseconds: 800)
    ));
  }

  void _favoriIslemi() async {
    setState(() { _favorimi = !_favorimi; });
    if (_favorimi) {
      await _firestoreService.favoriyeEkle(widget.book);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Favorilere eklendi!"), duration: Duration(milliseconds: 800)));
    } else {
      await _firestoreService.favoridenCikar(widget.book.id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Favorilerden çıkarıldı!"), duration: Duration(milliseconds: 800)));
    }
  }

  void _okunduIslemi() async {
    setState(() { _okunduMu = !_okunduMu; });
    if (_okunduMu) {
      await _firestoreService.okunanlaraEkle(widget.book);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Okundu işaretlendi!"), duration: Duration(milliseconds: 1000)));
    } else {
      await _firestoreService.okunanlardanCikar(widget.book.id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Okunanlardan kaldırıldı!"), duration: Duration(milliseconds: 1000)));
    }
  }

  void _listeyeEkleMenuAc() {
    // Ekranın altından yukarı doğru açılan o meşhur yarım pencere
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 450,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Listeye Ekle", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.renk2)),
              SizedBox(height: 15),
              Expanded(
                // StreamBuilder ile anlık veri alabiliyoruz
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.listeleriGetir(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                    var listeler = snapshot.data!.docs;
                    if (listeler.isEmpty) return Center(child: Text("Henüz listen yok. Aşağıdan oluşturabilirsin."));

                    // Kullanıcıların sahip olduğu listeleri sıralıyor
                    return ListView.builder(
                      itemCount: listeler.length,
                      itemBuilder: (context, index) {
                        var liste = listeler[index];
                        // listedeki her bir satır için görsellik ve kitabı listeye kaydetme
                        return ListTile(
                          leading: Icon(Icons.folder_special, color: AppColors.renk2),
                          title: Text(liste['listeAdi']),
                          trailing: Icon(Icons.add_circle, color: AppColors.renk5),
                          onTap: () async {
                            await _firestoreService.kitabiListeyeEkle(liste.id, widget.book);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("'${liste['listeAdi']}' listesine eklendi! ✅")));
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              Divider(),
              ElevatedButton.icon(
                onPressed: _yeniListeOlusturDialog,
                icon: Icon(Icons.add),
                label: Text("Yeni Liste Oluştur"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.renk2,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _yeniListeOlusturDialog() {
    TextEditingController _listeAdiController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Yeni Liste Oluştur"),
        content: TextField(
          controller: _listeAdiController,
          decoration: InputDecoration(hintText: "Örn: Okunacaklar"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("İptal")),
          ElevatedButton(
            onPressed: () async {
              if (_listeAdiController.text.isNotEmpty) {
                await _firestoreService.yeniListeOlustur(_listeAdiController.text.trim());
                Navigator.pop(context);
              }
            },
            child: Text("Oluştur"),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.renk2, foregroundColor: Colors.white),
          )
        ],
      ),
    );
  }

  void _alintiYap() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddQuotePage(book: widget.book))
    );
  }

  // Puanlardaki yıldız için widget !!!!! sıkıntılı !!!!!
  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        int starValue = index + 1;
        return IconButton(
          onPressed: () => _puanVer(starValue),
          icon: Icon(
            starValue <= _verilenPuan ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
          splashRadius: 20,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.renk2),
        title: Text("Kitap Detayı", style: TextStyle(color: AppColors.renk2, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 10))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    widget.book.resimUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(width: 170, color: Colors.grey[300]),
                  ),
                ),
              ),
            ),

            Text(widget.book.baslik, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.renk2)),
            SizedBox(height: 5),
            Text(widget.book.yazar, style: TextStyle(fontSize: 16, color: Colors.grey[700])),

            SizedBox(height: 10),

            Text("Puanın:", style: TextStyle(fontSize: 12, color: Colors.grey)),
            _buildStarRating(),

            SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(
                    icon: _okunduMu ? Icons.check_circle : Icons.check_circle_outline,
                    text: "Okudum",
                    isActive: _okunduMu,
                    activeColor: Colors.green,
                    onTap: _okunduIslemi,
                  ),
                  _actionButton(
                    icon: _favorimi ? Icons.favorite : Icons.favorite_border,
                    text: "Favorile",
                    isActive: _favorimi,
                    activeColor: Colors.red,
                    onTap: _favoriIslemi,
                  ),
                  _actionButton(
                    icon: Icons.bookmark_add_outlined,
                    text: "Listele",
                    isActive: true,
                    activeColor: AppColors.renk2,
                    onTap: _listeyeEkleMenuAc,
                  ),
                ],
              ),
            ),

            SizedBox(height: 15),

            // Alıntı Butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _alintiYap,
                  icon: Icon(Icons.format_quote_rounded),
                  label: Text("Bu Kitaptan Alıntı Paylaş"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.renk2,
                    side: BorderSide(color: AppColors.renk2, width: 1.5),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  SizedBox(height: 10),
                  Text("Kitap Hakkında", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.renk2)),
                  SizedBox(height: 10),
                  Text(widget.book.aciklama.isEmpty ? "Açıklama yok." : widget.book.aciklama, style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.6)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kendi widgetimiz ile kod tekrarını önlüyoruz !!!! sonradan yaptım olmasa da çalışıyordu
  Widget _actionButton({required IconData icon, required String text, required bool isActive, required Color activeColor, required VoidCallback onTap}) {
    // InkWell: görsel odaklı GestureDetector ile yapmıştım böyle daha iyi oluyormuş
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 80,
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? activeColor : Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? activeColor : Colors.grey[600], size: 28),
            SizedBox(height: 4),
            Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? activeColor : Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}