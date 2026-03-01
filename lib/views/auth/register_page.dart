import 'package:flutter/material.dart';
import 'package:bookan/core/constants/colors.dart';
import 'package:bookan/views/auth/login_page.dart';
import 'package:bookan/services/auth_service.dart';

class RegisterPage extends StatefulWidget {

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _kullaniciadiController = TextEditingController();

  bool _yukleniyor = false;
  bool _sifregizle=false;

  void _kayitOl() async {
      if(_emailController.text.isEmpty || _passwordController.text.isEmpty || _kullaniciadiController.text.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lütfen tüm alanları doldurunuz.")),
        );
        return;
      }
      setState(() {
        _yukleniyor = true;
      });

      try{
        await _authService.kayitOl(
          _emailController.text,
          _passwordController.text,
          _kullaniciadiController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hesap başarıyla oluşturuldu! Giriş Yapabilirsiniz.")),
        );

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
      }
      catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kayıt Hatası: $e")));
      }
      finally{
        setState(() {
          _yukleniyor = false;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // IconThemeData, uygulama içindeki bütün ikonların ayarını tutuyor ve kod tekrarını engelliyor
        iconTheme: IconThemeData(color: AppColors.renk2),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 300,
                child: Image.asset(
                  "assets/images/logo.png",
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20,),

              TextField(
                controller: _kullaniciadiController,
                decoration: InputDecoration(
                  labelText: "Kullanıcı Adı",
                  labelStyle: TextStyle(color: AppColors.renk4),
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.renk3),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.renk4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.renk2,width: 2),
                    borderRadius: BorderRadius.circular(15),
                  )
                ),
              ),
              SizedBox(height: 20,),

              // E-posta Girişi
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "E-posta",
                  labelStyle: TextStyle(color: AppColors.renk4),
                  prefixIcon: Icon(Icons.email_outlined,color: AppColors.renk3,),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.renk4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.renk2,width: 2),
                    borderRadius: BorderRadius.circular(15),
                  )
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
                  prefixIcon: Icon(Icons.lock_outline,color: AppColors.renk3,),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _sifregizle ? Icons.visibility : Icons.visibility_off,color: AppColors.renk4
                    ),
                    onPressed: (){
                      setState(() {
                        _sifregizle=!_sifregizle;
                      });
                    },
                  ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.renk4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.renk2,width: 2),
                    borderRadius: BorderRadius.circular(15),
                  )
                ),
                ),
              SizedBox(height: 30),

              // KAYIT OL BUTONU
              // Giriş yap butonu ile aynı mantıkta çalışıyor
              _yukleniyor
                  ? CircularProgressIndicator(color: AppColors.renk2)
                  : ElevatedButton(
                onPressed: _kayitOl,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.renk2,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                child: Text("KAYIT OL", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),

              SizedBox(height: 20),

              // Kayıtlı ise giriş yapa yönlendirme
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Zaten hesabın var mı?", style: TextStyle(color: Colors.grey[600])),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: Text(
                      "Giriş Yap",
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.renk3),
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

