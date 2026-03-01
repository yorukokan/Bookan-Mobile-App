import 'package:flutter/material.dart';
import 'package:bookan/core/constants/colors.dart';
import 'package:bookan/models/book_model.dart';
import 'package:bookan/services/book_service.dart';
import 'package:bookan/views/book/book_detail.dart';


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final BookService _bookService = BookService();
  List<BookModel> _kitaplar = [];
  bool _yukleniyor = false;
  String _seciliKategori = "Roman";

  final TextEditingController _aramaController = TextEditingController();
  final List<String> _kategoriler = [
    "Roman",
    "Klasik",
    "Bilim Kurgu",
    "Fantastik",
    "Korku-Gerilim",
    "Felsefe",
    "Psikoloji",
    'Tarih',
    'Bilim',
    'Biyografi',
    'Şiir',
    'Sanat',
    'Kişisel Gelişim',
    'Çizgi Roman',
  ];

  // --> Kitaplara belirli anahtarlarla çekme
  final Map<String, String> _apiSorguKelimeleri = {
    "Roman": "subject:fiction&orderBy=relevance",
    "Klasik": "Hasan Ali Yücel Klasikleri",
    "Bilim Kurgu": "subject:science_fiction&printType=books",
    "Fantastik": "Yüzüklerin Efendisi Harry Potter",
    "Korku-Gerilim": "Stephen King",
    "Felsefe": "subject:philosophy",
    "Psikoloji": "subject:psychology",
    "Tarih": "İlber Ortaylı Halil İnalcık",
    "Bilim": "subject:science&printType=books",
    "Biyografi": "subject:biography",
    "Şiir": "Nazım Hikmet Atilla İlhan",
    "Sanat": "subject:art",
    "Kişisel Gelişim": "subject:self-help",
    "Çizgi Roman": "Marvel DC Comics",
  };
  @override
  void initState() {
    super.initState();
    _kitaplariGetir();
  }

  // Kitapları internetten çekme
  void _kitaplariGetir() async {
    setState(() {
      _yukleniyor = true;
    });

    String apiTerimi = _apiSorguKelimeleri[_seciliKategori] ?? "subject:fiction";

    // Sadece gerçek kitapları printType=books ve popüler olanları getiriyoruz
    // Ayrıca dili türkçe olarak sınırlıyoruz
    String filtreliTerim = "$apiTerimi&printType=books&langRestrict=tr";

    List<BookModel> gelenKitaplar = await _bookService.getBooksByCategory(filtreliTerim);

    setState(() {

      _kitaplar = gelenKitaplar.where((k) =>
      k.resimUrl.isNotEmpty &&
          !k.resimUrl.contains("placeholder") &&
          k.baslik.length > 2
      ).toList();

      _yukleniyor = false;
    });
  }

  // Arama Yapma
  void _aramaYap(String kelime) async {
    if (kelime.isEmpty) return;

    setState(() {
      _yukleniyor = true;
      _seciliKategori = ""; // Tüm kategorileri bulabilmek için
    });

    List<BookModel> sonuc = await _bookService.searchBooks(kelime);

    setState(() {
      _kitaplar = sonuc;
      _yukleniyor = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Bookan",
          style: TextStyle(
            color: AppColors.renk2,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Arama kutusu
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _aramaController,
                onSubmitted: _aramaYap,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "Kitap, yazar veya tür ara...",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: AppColors.renk3),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _aramaController.clear();
                      setState(() {
                        _seciliKategori = "Roman";
                      });
                      _kitaplariGetir();
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Kategori kutusu
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _kategoriler.length,
                physics: BouncingScrollPhysics(), // Liste sonuna görsellik eklemek için kullanılıyormuş
                itemBuilder: (context, index) {
                  final kategori = _kategoriler[index];
                  final kontrolsecim = _seciliKategori == kategori;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _seciliKategori = kategori;
                        _aramaController.clear();
                      });
                      _kitaplariGetir(); // Yeni kategoriye göre alıyoruz kitapları
                    },
                    child: AnimatedContainer( // daha güzel görüntü geçişi için animatecontainer
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.only(right: 10),
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: kontrolsecim ? AppColors.renk2 : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: kontrolsecim ? AppColors.renk2 : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        kategori,
                        style: TextStyle(
                          color: kontrolsecim ? Colors.white : AppColors.renk3,
                          fontWeight: kontrolsecim ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),

            // Kitap Listesi için
            Expanded( // Kalan boşukları doldurup ekranı kaplıyor
              child: _yukleniyor
                  ? Center(child: CircularProgressIndicator(color: AppColors.renk2))
                  : _kitaplar.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("Bu kategoride kitap bulunamadı.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
                  : GridView.builder(
                physics: BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( // ızgaraları görüntüsünü belirlemek için kullanıyorum
                  crossAxisCount: 2, // sutün sayısı
                  childAspectRatio: 0.55, // en boy oranı
                  crossAxisSpacing: 15, // yan boşluk
                  mainAxisSpacing: 15,  // alt boşluk
                ),
                itemCount: _kitaplar.length,
                itemBuilder: (context, index) {
                  final kitap = _kitaplar[index];

                  // kitap detaya gitmek için
                  return GestureDetector( // tıklanabilir kutu widget
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetail(book: kitap),
                          ),);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kapak resmi
                        Expanded(
                          child: Container(
                            width: double.infinity, // max genişlik için
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(2, 4),
                                )
                              ],
                            ),
                            child: ClipRRect( // internetten gelen resmin köseleri görsellik için yumuşatma yapıyoruz
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                kitap.resimUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) { // kitap yoksa hatayı engellemek için
                                  print("Hata: $error");
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        // Başlık yazısı
                        Text(
                          kitap.baslik,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.renk2,
                          ),
                        ),
                        // Yazar yazısı
                        Text(
                          kitap.yazar,
                          maxLines: 1, // kitabın ismi uzunsa 1 satırı göstermek için
                          overflow: TextOverflow.ellipsis, // yazı taşmaması için sonuna ... ekler
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}