import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provamobilevehicle/screens/add_vehicle_screen.dart';
import 'package:provamobilevehicle/screens/history_screen.dart';
import 'package:provamobilevehicle/screens/home_screen.dart';
import 'package:provamobilevehicle/screens/login_screen.dart';
import 'package:provamobilevehicle/screens/my_vehicles_screen.dart';
import 'package:provamobilevehicle/screens/profile_screen.dart';

class StandartDrawer extends StatefulWidget {
  const StandartDrawer({super.key});

  @override
  State<StandartDrawer> createState() => _StandartDrawerState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class _StandartDrawerState extends State<StandartDrawer> {

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
    return Drawer(
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
          ListTile(title: const Text("Home"), onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
          }),
          ListTile(title: const Text("Meus veículos"), onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>MyVehiclesScreen()));
          },),
          ListTile(title: const Text("Adicionar veículos"), onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>AddVehicleScreen()));
          },),
          ListTile(title: const Text("Histórico de abastecimentos"), onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>HistoryScreen()));
          },),
          ListTile(title: const Text("Perfil"), onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen()));
          },),
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
    );
  }
}
