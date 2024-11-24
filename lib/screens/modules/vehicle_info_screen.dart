import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VehicleInfoScreen extends StatefulWidget {
  final Map<String, dynamic> car;

  const VehicleInfoScreen({Key? key, required this.car}) : super(key: key);

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  late Map<String, dynamic> car;

  @override
  void initState() {
    super.initState();
    car = widget.car;
  }

  void _showFuelDialog(BuildContext context) {
    final TextEditingController litersController = TextEditingController();
    final TextEditingController kilometrageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Abastecer Veículo"),
              const SizedBox(height: 16),
              TextField(
                controller: litersController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Litros abastecidos",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: kilometrageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Quilometragem atual",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final liters = double.tryParse(litersController.text);
                  final kilometrage = int.tryParse(kilometrageController.text);

                  if (liters == null || kilometrage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Por favor, insira valores válidos.")),
                    );
                    return;
                  }

                  _updateCarData(context, liters, kilometrage);
                },
                child: const Text("Salvar"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateCarData(BuildContext context, double liters, int kilometrage) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String uid = user.uid;

        // Obter o documento atual do carro
        DocumentSnapshot carDoc = await FirebaseFirestore.instance
            .collection('cars')
            .doc(car['id'])
            .get();

        if (carDoc.exists) {
          final data = carDoc.data() as Map<String, dynamic>;
          final previousKilometrage = data['kilometrage'] ?? 0;

          // Atualizar os valores do carro no Firestore
          await FirebaseFirestore.instance
              .collection('cars')
              .doc(car['id'])
              .set({
            'liters': FieldValue.increment(liters),
            'kilometrage': kilometrage,
            'average': FieldValue.increment(0), // Será recalculado abaixo
          }, SetOptions(merge: true));

          // Calcular a nova média
          if (previousKilometrage > 0) {
            final average = (kilometrage - previousKilometrage) / liters;

            // Atualizar a média no documento do carro
            await FirebaseFirestore.instance
                .collection('cars')
                .doc(car['id'])
                .update({'average': average});

            // Atualizar a coleção `mycars` do usuário
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('mycars')
                .doc(car['id'])
                .set({
              'average': average,
              'kilometrage': kilometrage,
              'liters': FieldValue.increment(liters),
            }, SetOptions(merge: true));
          }
        }

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dados atualizados com sucesso!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuário não autenticado!")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao atualizar os dados: $error")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(car['name'] ?? 'Veículo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nome: ${car['name'] ?? 'Desconhecido'}"),
            Text("Modelo: ${car['model'] ?? 'Desconhecido'}"),
            Text("Ano: ${car['year'] ?? 'Desconhecido'}"),
            Text("Placa: ${car['placa'] ?? 'Desconhecido'}"),
            Text("Kilometragem: ${car['kilometrage'] ?? 'Não informado'}"),
            Text("Litros abastecidos: ${car['liters'] ?? 'Não informado'}"),
            Text("Média de consumo: ${car['average']?.toStringAsFixed(2) ?? 'Não informado'}"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showFuelDialog(context),
              child: const Text("Abastecer"),
            ),
          ],
        ),
      ),
    );
  }
}
