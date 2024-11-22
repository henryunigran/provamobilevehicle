import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provamobilevehicle/screens/login_screen.dart';
import 'package:provamobilevehicle/screens/modules/standart_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  User? _user;
  String _userName = "Usuário";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Screen")),
      drawer: StandartDrawer(),
      body: Center(
        child: Text('Bem-vindo, ${_userName ?? 'Usuário'}!'),
      ),
    );
  }
}
