import 'package:flutter/material.dart';
import 'package:provamobilevehicle/screens/modules/standart_drawer.dart';

class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: StandartDrawer(),
      body: Center(child: Text("Meus veículos"),),
    );
  }
}
