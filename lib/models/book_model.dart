/* --> Google Books API verilerini uygulamada anlayabilecek şekilde oluşturma
   --> https://javiercbk.github.io/json_to_dart/ */

class BookModel {
  final String id;
  final String baslik;
  final String yazar;
  final String aciklama;
  final String resimUrl;
  final String yayinTarihi;

  BookModel({
    required this.id,
    required this.baslik,
    required this.yazar,
    required this.aciklama,
    required this.resimUrl,
    required this.yayinTarihi,
  });

  // Verileri Json'dan alıp Nesnelere dönüştürüyoruz.
  factory BookModel.fromJson(Map<String, dynamic> map) {
    final kitapBilgileri = map['volumeInfo']; // Bilgilerin olduğu ana kutu

    return BookModel(
      id: map['id'] ?? '',

      baslik: kitapBilgileri['title'] ?? 'İsimsiz Kitap',

      // Yazarlar liste olarak geldiği için ilkini almamız gerekiyormuş.
      yazar: (kitapBilgileri['authors'] != null && kitapBilgileri['authors'].isNotEmpty)
          ? kitapBilgileri['authors'][0]
          : 'Yazar Bilinmiyor',

      aciklama: kitapBilgileri['description'] ?? 'Açıklama bulunamadı.',

      // Resim linkini güvenli olarak almamız gerekiyormuş bu yüzden https olarak aldık.
      resimUrl: (kitapBilgileri['imageLinks'] != null && kitapBilgileri['imageLinks']['thumbnail'] != null)
          ? kitapBilgileri['imageLinks']['thumbnail'].toString().replaceFirst("http://", "https://")
          : '', // Resim yoksa boş dönmesi için

      yayinTarihi: kitapBilgileri['publishedDate'] ?? 'Tarih Yok',
    );
  }
}