import 'package:flutter/material.dart';
import 'package:provamobilevehicle/screens/modules/standart_drawer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: StandartDrawer(),
      body: Center(child: Text("Tela de perfil"),),
    );
  }
}
