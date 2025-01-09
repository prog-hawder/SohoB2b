// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_build_context_synchronously
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:b2b/Pages/Home/home.dart';
import 'package:b2b/Pages/Login/Standart_Login/LoginTextFormField.dart';
import 'package:b2b/Themes/colors.dart';
import 'package:b2b/Themes/text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSwitched = true;
  String _message = '';
  String? acesso;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLogin = prefs.getString('savedLogin');
    String? savedPassword = prefs.getString('savedPassword');
    bool? isSwitched = prefs.getBool('isSwitched');
 // salva as infromações do login
    if (savedLogin != null) {
      _loginController.text = savedLogin;
    }
    if (savedPassword != null) {
      _passwordController.text = savedPassword;
    }
    if (isSwitched != null) {
      setState(() {
        _isSwitched = isSwitched;
      });
    }
  }
  // Executa o login 
  Future<void> _login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String login = _loginController.text;
    final String password = _passwordController.text;
    acesso = 'http://186.201.46.50:7071'; //  URL para acesso ao tomcat
    await prefs.setString('acesso', acesso!);

    final response = await http.post(
      Uri.parse('$acesso/snsistemasb2b-api/api/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'login': login, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Salvar codcliente e token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('codCliente', data['codCliente'].toString());
      await prefs.setString('token', data['token']);

      // Salvar login e senha se o switch estiver ativado
      if (_isSwitched) {
        await prefs.setString('savedLogin', login);
        await prefs.setString('savedPassword', password);
        await prefs.setBool('isSwitched', true);
      } else {
        await prefs.remove('savedLogin');
        await prefs.remove('savedPassword');
        await prefs.setBool('isSwitched', false);
      }

      setState(() {
        _message = 'Login bem-sucedido!';
      });
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      final errorData = jsonDecode(response.body);
      setState(() {
        _message = errorData['userMessage'] ?? 'Erro ao fazer login.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgoundsecondary,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Center(
              child: Image.asset('assets/app_logo.png',
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.6),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  LoginField(usernameController: _loginController),
                  const SizedBox(height: 26.0),
                  SenhaField(passwordController: _passwordController),
                  const SizedBox(height: 40.0),
                  Row(
                    children: [
                      _rememberMeSwitch(),
                      const SizedBox(width: 24.0),
                      Text('Lembrar de mim', style: AppTextStyles.bodyText),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 40.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.15,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                        child:
                            Text('Continuar', style: AppTextStyles.botomText),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(_message, style: TextStyle(color: Colors.red)),
                  _buildFooterLinks(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text('Desenvolvido por SOHO',
                style: AppTextStyles.bodyText),
          ),
        ),
      ),
    );
  }
 // Switch para salvar login e senha 
  GestureDetector _rememberMeSwitch() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSwitched = !_isSwitched;
        });
      },
      child: Container(
        width: 35.0,
        height: 15.0,
        decoration: BoxDecoration(
          color: _isSwitched ? AppColors.primary.withOpacity(0.4) : Colors.grey,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: _isSwitched ? 15.0 : -3.0,
              top: -3,
              child: Container(
                width: 21.0,
                height: 21.0,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 1,
                    ),
                  ],
                  color: _isSwitched ? AppColors.primary : Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
   // Ainda não funciona essa parte
  Row _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        Text(
          'Esqueci minha senha',
          style: TextStyle(
            decoration: TextDecoration.underline,
            fontSize: 16,
            color: Color.fromARGB(157, 0, 0, 0),
          ),
        ),
        Text(
          'Cadastre-se',
          style: TextStyle(
            decoration: TextDecoration.underline,
            fontSize: 16,
            color: Color.fromARGB(157, 0, 0, 0),
          ),
        ),
      ],
    );
  }
}
