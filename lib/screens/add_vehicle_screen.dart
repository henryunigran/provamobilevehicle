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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _litersController = TextEditingController();
  final TextEditingController _kilometrageController = TextEditingController();
  final TextEditingController _averageController = TextEditingController();

  Future<void> _addVehicle() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String uid = user.uid;

        String name = _nameController.text;
        String model = _modelController.text;
        String year = _yearController.text;
        String placa = _placaController.text;
        double liters = double.tryParse(_litersController.text) ?? 0.0;
        int kilometrage = int.tryParse(_kilometrageController.text) ?? 0;
        double average = double.tryParse(_averageController.text) ?? 0.0;

        DocumentReference carRef = await FirebaseFirestore.instance.collection('cars').add({
          'name': name,
          'model': model,
          'year': year,
          'placa': placa,
          'liters': liters,
          'kilometrage': kilometrage,
          'average': average,
          'createdAt': FieldValue.serverTimestamp(),
        });

        String carId = carRef.id;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('mycars')
            .doc(carId)
            .set({
          'name': name,
          'model': model,
          'year': year,
          'placa': placa,
          'liters': liters,
          'kilometrage': kilometrage,
          'average': average,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veículo cadastrado com sucesso!')),
        );

        _nameController.clear();
        _modelController.clear();
        _yearController.clear();
        _placaController.clear();
        _litersController.clear();
        _kilometrageController.clear();
        _averageController.clear();
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
        title: const Text("Registrar veículo"),
      ),
      drawer: const StandartDrawer(),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(
                    labelText: 'Modelo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Informe o modelo' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(
                    labelText: 'Ano',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Informe o ano' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _placaController,
                  decoration: const InputDecoration(
                    labelText: 'Placa',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Informe a placa' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _litersController,
                  decoration: const InputDecoration(
                    labelText: 'Litros iniciais',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Informe os litros' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _kilometrageController,
                  decoration: const InputDecoration(
                    labelText: 'Quilometragem inicial',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Informe a quilometragem'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _averageController,
                  decoration: const InputDecoration(
                    labelText: 'Média inicial',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Informe a média' : null,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Cadastrar"),
        icon: const Icon(Icons.add),
        onPressed: _addVehicle,
      ),
    );
  }
}
