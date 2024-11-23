import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
    _user = FirebaseAuth.instance.currentUser;
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    if (_user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['nome'] ?? 'Usuário';
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getCars() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('cars').get();
      List<Map<String, dynamic>> carsList = [];
      querySnapshot.docs.forEach((doc) {
        carsList.add(doc.data() as Map<String, dynamic>);
      });
      return carsList;
    } catch (e) {
      print("Erro ao buscar carros: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
      ),
      drawer: StandartDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Carros cadastrados:', style: TextStyle(fontSize: 20)),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getCars(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar carros'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Nenhum carro cadastrado.'));
                  } else {
                    List<Map<String, dynamic>> cars = snapshot.data!;
                    return ListView.builder(
                      itemCount: cars.length,
                      itemBuilder: (context, index) {
                        var car = cars[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(car['name'] ?? 'Nome desconhecido'),
                            subtitle: Text('Modelo: ${car['model'] ?? 'Desconhecido'}'),
                            trailing: Text(car['year'] ?? 'Ano desconhecido'),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
