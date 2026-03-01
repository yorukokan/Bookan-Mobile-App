import 'package:flutter/material.dart';
import 'package:bookan/core/constants/colors.dart';
import 'package:bookan/models/book_model.dart';
import 'package:bookan/services/firestore_service.dart';

class AddQuotePage extends StatefulWidget {
  final BookModel book;

  const AddQuotePage({Key? key, required this.book}) : super(key: key);

  @override
  State<AddQuotePage> createState() => _AddQuotePageState();
}

class _AddQuotePageState extends State<AddQuotePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _quoteController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();

  bool _yukleniyor = false;

  void _kaydet() async {

    // Boş alıntıyı engellemek için
    if (_quoteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lütfen bir alıntı yazın.")));
      return;
    }

    setState(() { _yukleniyor = true; });

    try {
      // alıntıyı paylaşmak için firebase bağlanıyoruz
      await _firestoreService.genelAlintiPaylas(
        kitapAdi: widget.book.baslik,
        yazar: widget.book.yazar,
        alinti: _quoteController.text.trim(),
        resimUrl: widget.book.resimUrl,
      );

      // Başarılı olursa işlem tamamlamak için çıkılıyor
      if (mounted) {
        setState(() { _yukleniyor = false; });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Alıntı Paylaşıldı!")));
      }

    } catch (e) {
      if (mounted) {
        setState(() { _yukleniyor = false; });
        print("Paylaşım Hatası: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Paylaşırken bir sorun oluştu.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Alıntı Ekle", style: TextStyle(color: AppColors.renk2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        // elevation: yukseklik ayarlıyor butonu güzel görüntü için
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.renk2),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Kitap Bilgisi
            Row(
              children: [
                // ClipRRect içine koyduğun bir resimin  köşelerini yuvarlatmaya yarayan widget
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.book.resimUrl,
                    width: 60, height: 90,
                    fit: BoxFit.cover,
                    // resim bulunamazsa hatayı engellemek için kullanılıyormuşş
                    errorBuilder: (c,e,s) => Container(width: 60, height: 90, color: Colors.grey),
                  ),
                ),
                // SizedBox: boşluk bırakmayı sağlıyor
                SizedBox(width: 15),
                //  Expanded: row ve column harici kalan boşlukları doldurmayı sağlıyormuşş
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.book.baslik, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.renk2)),
                      Text(widget.book.yazar, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              ],
            ),
            // Divider: çizgi çekmek için kullanılıyor
            Divider(height: 40),

            // Alıntı Yazma Alanı
            TextField(
              controller: _quoteController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Buraya kitapta beğendiğin sözü yaz...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: AppColors.renk2, width: 2)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            SizedBox(height: 20),

            // Sayfa No
            TextField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Sayfa No (Opsiyonel)",
                prefixIcon: Icon(Icons.bookmark_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            SizedBox(height: 30),

            // Paylaşma Butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _yukleniyor ? null : _kaydet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.renk2,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _yukleniyor
                    ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : Text("PAYLAŞ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}