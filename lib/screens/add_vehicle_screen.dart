import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provamobilevehicle/screens/modules/standart_drawer.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  GlobalKey _formkey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _modelController = TextEditingController();
  TextEditingController _yearController = TextEditingController();
  TextEditingController _placaController = TextEditingController();

  Future<void> _addVehicle() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String uid = user.uid;

        String name = _nameController.text;
        String model = _modelController.text;
        String year = _yearController.text;
        String placa = _placaController.text;

        await FirebaseFirestore.instance.collection('cars').add({
          'name': name,
          'model': model,
          'year': year,
          'placa': placa,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('mycars')
            .add({
          'name': name,
          'model': model,
          'year': year,
          'placa': placa,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veículo cadastrado com sucesso!')),
        );

        _nameController.clear();
        _modelController.clear();
        _yearController.clear();
        _placaController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário não autenticado!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar o veículo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrar veículo"),
      ),
      drawer: StandartDrawer(),
      body: Form(
        key: _formkey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _modelController,
                decoration: InputDecoration(
                  labelText: 'Modelo',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(
                  labelText: 'Ano',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _placaController,
                decoration: InputDecoration(
                  labelText: 'Placa',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Cadastrar"),
        icon: Icon(Icons.add),
        onPressed: _addVehicle,
      ),
    );
  }
}
