import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xerp_motor/pages/cadastro_ticktet.dart';
import 'package:xerp_motor/pages/home.dart';
import 'package:xerp_motor/pages/listall.dart';
import 'package:xerp_motor/pages/login.dart';
import 'package:xerp_motor/pages/ticket_list.dart';
import 'package:xerp_motor/pages/abastecimento.dart';
import 'package:xerp_motor/pages/assinatura.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _defaultHome = const LoginPage();

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token != null) {
      setState(() {
        _defaultHome = const HomePage();
      });
    } else {
      setState(() {
        _defaultHome = const LoginPage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _defaultHome,
      routes: {
        '/home': (context) => const HomePage(),
        '/ticket': (context) => const CadTicket(),
        '/login': (context) => const LoginPage(),
        '/listall': (context) => const TicketListAllPage(),
        '/abastecimento': (context) => const AbastecimentoPage(),
        '/assinatura': (context) => const AssinaturaPage(),
      },
    );
  }
}
