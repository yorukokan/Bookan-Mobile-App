import 'package:flutter/material.dart';
import 'package:bookan/core/constants/colors.dart';
import 'package:bookan/services/auth_service.dart';
import 'register_page.dart';
import 'package:bookan/views/home/home_page.dart';
import 'package:bookan/views/navigation/navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  // Giriş sayfasında yazıları tutmak için değişkenler
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _yukleniyor = false;
  bool _sifregizle=false;
  bool _beniHatirla = false;

  void _girisYap() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen e-posta ve şifrenizi giriniz.")),
      );
      return;
    }
    setState(() {
      _yukleniyor = true;
    });

    try {
      await _authService.girisYap(
        _emailController.text,
        _passwordController.text,
      );
      // bu eklenti sayesinde beni hatırla kolay oluyor. kullanıcı verisi uygulamada saklanıyor ve sonraki giriş için daha kolay oluyor.
      SharedPreferences tercih = await SharedPreferences.getInstance();
      await tercih.setBool('beniHatirla', _beniHatirla);
      // ------------------------------------------
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Giriş Başarılı! Ana Sayfaya yönlendiriliyorsunuz..."),
        ),
      );
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScaffold())
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Giriş Hatası: $e")));
    } finally {
      setState(() {
        _yukleniyor = false;
      });
    }
  }
  // Şifremi Unuttum Penceresi
  void _sifreSifirlaPenceresi() {
    TextEditingController _sifirlamaEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Şifre Sıfırlama"),
          content: TextField(
            controller: _sifirlamaEmailController,
            decoration: InputDecoration(
                hintText: "E-posta adresinizi girin",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("İptal", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                if (_sifirlamaEmailController.text.isNotEmpty) {
                  try {
                    await _authService.sifreSifirla(_sifirlamaEmailController.text.trim());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Sıfırlama bağlantısı e-postanıza gönderildi!")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Hata: $e")),
                    );
                  }
                }
              },
              child: Text("Gönder", style: TextStyle(color: AppColors.renk2, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 350,
                child: Image.asset("assets/images/logo.png",
                fit: BoxFit.contain,),
              ),
              SizedBox(height: 20),

              // E-posta Girişi
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "E-posta",
                  labelStyle: TextStyle(color: AppColors.renk4),
                  prefixIcon: Icon(Icons.email_outlined,color: AppColors.renk3),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.renk4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.renk2,width: 2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Şifre Girişi
              TextField(
                controller: _passwordController,
                obscureText: !_sifregizle,
                decoration: InputDecoration(
                  labelText: "Şifre",
                  labelStyle: TextStyle(color: AppColors.renk4),
                  prefixIcon: Icon(Icons.lock_outline,color: AppColors.renk3),
                  suffixIcon: IconButton(icon: Icon(
                    _sifregizle ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.renk4,
                  ),
                  onPressed:() {
                    setState(() {
                      _sifregizle=!_sifregizle;
                    });
                  }),
                  // kullanıcıya göstermek için bu şekilde görsellik için tıklandığında ise focusedborder devreye giriyor !!!
                  enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.renk4),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.renk2,width: 2),
                  borderRadius: BorderRadius.circular(15),),
                  ),
                ),

              // Beni hatırla ve Şifremi unuttum
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Beni hatırla
                  Row(
                    children: [
                      Checkbox(
                        value: _beniHatirla,
                        activeColor: AppColors.renk2,
                        onChanged: (bool? deger) {
                          setState(() {
                            _beniHatirla = deger ?? false;
                          });
                        },
                      ),
                      Text("Beni Hatırla", style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),

                  // Şifremi Unuttum
                  TextButton(
                    onPressed: _sifreSifirlaPenceresi,
                    child: Text("Şifremi unuttum", style: TextStyle(color: AppColors.renk3)),
                  ),
                ],
              ),


              // Giriş Yap Butonu
              // CircularProgressIndicator: o sürekli dönen yuvarlak "Yükleniyor" animasyonu
              _yukleniyor
                  ? CircularProgressIndicator(color: AppColors.renk2)
                  : ElevatedButton(
                      onPressed: _girisYap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.renk2,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 100,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text("GİRİŞ YAP", style: TextStyle(fontSize: 16)),
                    ),
              SizedBox(height: 20),

              // Kayıt Olma Yazısı
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Hesabın yok mu?",style: TextStyle(color: Colors.grey[600]),),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                    },
                    child: Text(
                      "Kayıt ol",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.renk3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
