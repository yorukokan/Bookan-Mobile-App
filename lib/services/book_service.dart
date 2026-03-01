import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bookan/models/book_model.dart'; // Model dosyasını doğru çağırdık

class BookService {
  final String _baseUrl = "https://www.googleapis.com/books/v1/volumes";

  // Kategoriye göre getir .)
  Future<List<BookModel>> getBooksByCategory(String category) async {
    // Bu işlem URL'in bozulmamasını sağlıyor
    String safeQuery = category.replaceAll(" ", "+");

    final String url = "$_baseUrl?q=$safeQuery&maxResults=30&langRestrict=tr&printType=books";

    // Hata için URL'i konsola yazdırıyormuşuz
    //print("URL: $url");

    try {
      final cevap = await http.get(Uri.parse(url));

      // 200 kodu başarılı işlem için 404--> hata
      if (cevap.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(cevap.body);
        if (data['items'] != null) {
          final List<dynamic> items = data['items'];
          return items.map((item) => BookModel.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Hata: $e");
      return [];
    }
  }

  // Arama Yapma Fonksiyonu
  Future<List<BookModel>> searchBooks(String query) async {
    final String url = "$_baseUrl?q=$query&maxResults=20&langRestrict=tr&printType=books";

    try {
      final cevap = await http.get(Uri.parse(url));

      if (cevap.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(cevap.body);
        if (data['items'] != null) {
          final List<dynamic> items = data['items'];
          return items.map((item) => BookModel.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Arama Hatası: $e");
      return [];
    }
  }
}