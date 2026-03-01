import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Beni hatırla mantığı için biraz veri saklanıyor onları almak ve kullanmak için
import 'firebase_options.dart';
import 'core/constants/colors.dart';
import 'views/auth/login_page.dart';
import 'views/navigation/navigation_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bookan',
      theme: ThemeData(
        primaryColor: AppColors.renk2,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.renk2),
          titleTextStyle: TextStyle(
              color: AppColors.renk2,
              fontSize: 20,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
      home: AuthKontrol(),
    );
  }
}

class AuthKontrol extends StatefulWidget {
  @override
  _AuthKontrolState createState() => _AuthKontrolState();
}

class _AuthKontrolState extends State<AuthKontrol> {
  bool _yukleniyor = true;
  bool _girisYapmisMi = false;

  @override
  void initState() {
    super.initState();
    _kontrolEt();
  }

  void _kontrolEt() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool beniHatirla = prefs.getBool('beniHatirla') ?? false;

      if (beniHatirla == true) {
        setState(() {
          _girisYapmisMi = true;
        });
      } else {
        await FirebaseAuth.instance.signOut();
        setState(() {
          _girisYapmisMi = false;
        });
      }
    } else {
      setState(() {
        _girisYapmisMi = false;
      });
    }
    setState(() {
      _yukleniyor = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_yukleniyor) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_girisYapmisMi) {
      return MainScaffold();
    } else {
      return LoginPage();
    }
  }
}