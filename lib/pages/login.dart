import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xerp_motor/pages/home.dart';
import '../class/api_config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String usuario = _usuarioController.text;
      final String password = _passwordController.text;

      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/login-app'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'usuario': usuario, 'password': password}),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String token = responseData['access_token'];

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        print('Login bem-sucedido!');
        print('Token: $token');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falha no login. Tente novamente.'),
          ),
        );
        print('Falha no login. Tente novamente.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xff043259),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 360,
                      height: 115,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Seja bem vindo(a)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Faça login para acessar sua conta',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 80.0),
                      child: Image.asset(
                        "assets/img/logo_branca.png",
                      ),
                    ),
                  ],
                ),
              ),
              Form(
                key: _formKey,
                child: Container(
                  margin: const EdgeInsets.only(top: 35.0, left: 16.0, right: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _usuarioController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Usuário',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, digite seu usuário!';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _passwordController,
                            keyboardType: TextInputType.text,
                            validator: (senha) {
                              if (senha == null || senha.isEmpty) {
                                return 'Por favor, digite sua senha!';
                              } else if (senha.length < 5) {
                                return 'Por favor, senha maior que 5 caracteres';
                              }
                              return null;
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Senha',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20.0, left: 12.0, right: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFF043259),
                            ),
                            onPressed: _login,
                            child: const Text(
                              'ENTRAR',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                ),
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 10.0, right: 18.0),
                          child: GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Esqueceu sua senha?',
                              style: TextStyle(
                                color: Color(0xff043259),
                                fontSize: 14,
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 80.0),
                      child: Image.asset(
                        "assets/img/logo_down.png",
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
