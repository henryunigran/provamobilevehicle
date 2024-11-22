import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provamobilevehicle/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class _HomeScreenState extends State<HomeScreen> {
  User? _user;
  String _userName = "Usuário";

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _getUserData();
  }

  Future<void> _getUserData() async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();
    setState(() {
      _userName = userDoc['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Screen")),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_userName!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(_user?.email ?? "user@email.com", style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const Divider(),
            ListTile(title: const Text("Home")),
            ListTile(title: const Text("Meus veículos")),
            ListTile(title: const Text("Adicionar veículos")),
            ListTile(title: const Text("Histórico de abastecimentos")),
            ListTile(title: const Text("Perfil")),
            ListTile(
              title: const Text("Logout"),
              onTap: () async {
                await _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Bem-vindo, ${_userName ?? 'Usuário'}!'),
      ),
    );
  }
}
