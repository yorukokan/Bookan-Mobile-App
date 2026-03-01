import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookan/core/constants/colors.dart';
import 'package:bookan/models/book_model.dart';
import 'package:bookan/services/auth_service.dart';
import 'package:bookan/services/firestore_service.dart';
import 'package:bookan/views/book/book_detail.dart';
import 'package:bookan/views/auth/login_page.dart';
import 'package:bookan/views/profile/read_books_page.dart';
import 'package:bookan/views/profile/list_detail_page.dart';
import 'package:bookan/views/profile/my_quotes_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Hazır resimler profil fotoğrafı için
  final List<String> _avatars = [
    "https://cdn-icons-png.flaticon.com/512/4140/4140048.png",
    "https://cdn-icons-png.flaticon.com/512/4140/4140047.png",
    "https://cdn-icons-png.flaticon.com/512/4140/4140037.png",
    "https://cdn-icons-png.flaticon.com/128/3135/3135715.png",
    "https://cdn-icons-png.flaticon.com/128/3135/3135789.png",
    "https://cdn-icons-png.flaticon.com/128/924/924915.png",
  ];

  // Ayarlar yerini açma burada profil güncelleme ve çıkış yapma yer alıyor
  void _ayarlariAc(BuildContext context, String currentName, String currentBio, String currentAvatar) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              SizedBox(height: 15),
              Text("Ayarlar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.renk2)),
              SizedBox(height: 10),

              // Profili güncelleme
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.edit, color: Colors.blue),
                ),
                title: Text("Profili Düzenle", style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  Navigator.pop(context);
                  _profiliDuzenleDialog(currentName, currentBio, currentAvatar); // Diyaloğu aç
                },
              ),
              Divider(),

              // Çıkış Yap Seçeneği
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.logout, color: Colors.red),
                ),
                title: Text("Çıkış Yap", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _cikisYap();
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Çıkış yapma işlemi
  void _cikisYap() async {
    await _authService.cikisYap();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
    );
  }

  // Profil güncelleme işlemi
  void _profiliDuzenleDialog(String mevcutAd, String mevcutBio, String mevcutResim) {
    TextEditingController _adController = TextEditingController(text: mevcutAd);
    TextEditingController _bioController = TextEditingController(text: mevcutBio);
    String _seciliAvatar = mevcutResim.isNotEmpty ? mevcutResim : _avatars.last;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Profili Düzenle", style: TextStyle(color: AppColors.renk2, fontWeight: FontWeight.bold)),
              content: Container(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Resim seçimi
                      Text("Avatar Seç", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      SizedBox(height: 10),

                      // Avatar Listesi
                      SizedBox(
                        height: 60,
                        width: double.maxFinite,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _avatars.length,
                          itemBuilder: (context, index) {
                            String avatarUrl = _avatars[index];
                            bool seciliMi = _seciliAvatar == avatarUrl;
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  _seciliAvatar = avatarUrl;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 10),
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: seciliMi ? Border.all(color: AppColors.renk5, width: 3) : null,
                                ),
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(avatarUrl),
                                  radius: 24,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Divider(height: 30),

                      // İsim değiştirme
                      TextField(
                        controller: _adController,
                        decoration: InputDecoration(
                          labelText: "Kullanıcı Adı",
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      SizedBox(height: 15),

                      // Hakkında
                      TextField(
                        controller: _bioController,
                        maxLength: 80,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: "Hakkımda",
                          prefixIcon: Icon(Icons.info_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("İptal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_adController.text.isNotEmpty) {
                      Navigator.pop(context);
                      await _firestoreService.profiliGuncelle(
                        yeniAd: _adController.text.trim(),
                        yeniBio: _bioController.text.trim(),
                        yeniResimUrl: _seciliAvatar,
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profil güncellendi!")));
                      }
                    }
                  },
                  child: Text("Kaydet"),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.renk2, foregroundColor: Colors.white),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return Center(child: Text("Giriş Hatası"));

    // Kullanıcı verisini en tepede dinliyoruz ki AppBar'daki butona veri gönderebilelim
    return StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(_currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Scaffold(body: Center(child: CircularProgressIndicator()));

          var userData = snapshot.data!.data() as Map<String, dynamic>?;
          String kullaniciAdi = userData?['kullaniciadi'] ?? "Kullanıcı";
          String bio = userData?['bio'] ?? "Kitap sever bir okur.";
          String avatarUrl = userData?['avatarUrl'] ?? "";

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text("Profilim", style: TextStyle(color: AppColors.renk2, fontWeight: FontWeight.bold)),
              // Ayarlar butonu
              actions: [
                IconButton(
                  icon: Icon(Icons.settings, color: AppColors.renk2),
                  onPressed: () => _ayarlariAc(context, kullaniciAdi, bio, avatarUrl),
                )
              ],
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // profil kısımı
                  _buildProfileHeader(kullaniciAdi, bio, avatarUrl),
                  SizedBox(height: 20),

                  // İstatistikler
                  _buildStatsSection(),

                  SizedBox(height: 25),
                  Divider(thickness: 1, color: Colors.grey[200]),

                  // Favoriler
                  _buildSectionTitle("Favorilerim"),
                  _buildFavoritesHorizontalList(),

                  SizedBox(height: 20),

                  // Listeler
                  _buildSectionTitle("Listelerim"),
                  _buildListsVertical(),
                ],
              ),
            ),
          );
        }
    );
  }

  // Profili yapma
  Widget _buildProfileHeader(String ad, String bio, String resimUrl) {
    ImageProvider bgImage;
    if (resimUrl.isNotEmpty) {
      bgImage = NetworkImage(resimUrl);
    } else {
      bgImage = const AssetImage("assets/images/profilelogo.png");
    }

    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.renk5, width: 4),
              color: Colors.grey[200],
              image: DecorationImage(
                fit: BoxFit.cover,
                image: bgImage,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
              ]
          ),
        ),
        SizedBox(height: 15),

        // İsim
        Text(
          ad,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.renk2),
        ),
        SizedBox(height: 5),

        // Hakkında
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            bio,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  // İstatistikler
  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildClickableStat("Okunan", 'okunanlar', Colors.green, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ReadBooksPage()));
          }),

          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyQuotesPage()));
            },
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('feed').where('paylasanId', isEqualTo: _currentUser!.uid).snapshots(),
              builder: (context, snapshot) {
                String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : "-";
                return _statContainer(count, "Alıntı", Colors.orange);
              },
            ),
          ),

          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').doc(_currentUser!.uid).collection('favoriler').snapshots(),
            builder: (context, snapshot) {
              String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : "-";
              return _statCard("Favori", count, AppColors.renk2);
            },
          ),

          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').doc(_currentUser!.uid).collection('listeler').snapshots(),
            builder: (context, snapshot) {
              String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : "-";
              return _statCard("Liste", count, AppColors.renk2);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClickableStat(String label, String collectionName, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').doc(_currentUser!.uid).collection(collectionName).snapshots(),
        builder: (context, snapshot) {
          String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : "-";
          return _statContainer(count, label, color);
        },
      ),
    );
  }

  Widget _statContainer(String count, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _statCard(String label, String count, Color color) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  // Favoriler widget
  Widget _buildFavoritesHorizontalList() {
    return SizedBox(
      height: 180,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').doc(_currentUser!.uid).collection('favoriler').orderBy('eklenmeTari', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          var docs = snapshot.data!.docs;
          if (docs.isEmpty) return Center(child: Text("Henüz favori kitabın yok.", style: TextStyle(color: Colors.grey)));

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
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
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetail(book: kitap))),
                child: Container(
                  width: 110,
                  margin: EdgeInsets.only(right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(kitap.resimUrl, fit: BoxFit.cover, errorBuilder: (c,e,s)=>Container(color: Colors.grey[300])),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(kitap.baslik, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.renk2)),
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

  // Listeler widget
  Widget _buildListsVertical() {
    return StreamBuilder<QuerySnapshot>( // Canlı veriler için
      stream: _firestore.collection('users').doc(_currentUser!.uid).collection('listeler').orderBy('olusturulmaTarihi', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();
        var docs = snapshot.data!.docs;
        if (docs.isEmpty) return Padding(padding: const EdgeInsets.all(16.0), child: Text("Henüz oluşturulmuş bir listen yok.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)));

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var liste = docs[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
              child: ListTile(
                leading: Icon(Icons.folder_special, color: AppColors.renk2, size: 30),
                title: Text(liste['listeAdi'], style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.renk2)),
                subtitle: Text("Detaylar için tıkla"),
                trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ListDetailPage(listeId: liste.id, listeAdi: liste['listeAdi'])));
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.renk2)),
          Icon(Icons.arrow_forward, size: 18, color: AppColors.renk3),
        ],
      ),
    );
  }
}