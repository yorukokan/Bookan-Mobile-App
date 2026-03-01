import 'package:flutter/material.dart';
import 'package:bookan/core/constants/colors.dart';
import 'package:bookan/views/home/home_page.dart';
import 'package:bookan/views/profile/profile_page.dart';
import 'package:bookan/views/quotes/quotes_page.dart';

class MainScaffold extends StatefulWidget {
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _seciliSayfa = 0;

  // Sayfaların Listesi
  final List<Widget> _sayfalar = [
    HomePage(),     // 0: Ana Sayfa
    QuotesPage(),   // 1: Alıntılar
    ProfilePage(),  // 2: Profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _seciliSayfa = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _sayfalar[_seciliSayfa],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: _seciliSayfa,
          onTap: _onItemTapped,
          selectedItemColor: AppColors.renk2,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedItemColor: AppColors.renk4,
          showUnselectedLabels: false, // isim sadece tıklamada gözüksün

          items: const [
            // Ana sayfa
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Ana Sayfa',
            ),

            // Alıntılar
            BottomNavigationBarItem(
              icon: Icon(Icons.format_quote_outlined),
              activeIcon: Icon(Icons.format_quote_sharp),
              label: 'Alıntılar',
            ),

            // Profil
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}