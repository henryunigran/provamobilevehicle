import 'package:flutter/material.dart';
import 'package:provamobilevehicle/screens/modules/standart_drawer.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: StandartDrawer(),
      body: Center(child: Text("Registro de veículos"),),
    );
  }
}
