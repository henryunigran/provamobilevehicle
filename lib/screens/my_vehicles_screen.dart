import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provamobilevehicle/screens/modules/standart_drawer.dart';
import 'package:provamobilevehicle/screens/modules/vehicle_info_screen.dart';

class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
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
      } else {
        print("Usuário não encontrado.");
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getMyCars() async {
    try {
      if (_user == null) {
        print("Usuário não logado.");
        return [];
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('mycars')
          .get();

      List<Map<String, dynamic>> myCarsList = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> carData = doc.data() as Map<String, dynamic>;
        carData['id'] = doc.id;
        carData['liters'] = carData['liters'] ?? 0;
        carData['kilometrage'] = carData['kilometrage'] ?? 0;
        carData['average'] = carData['average'] ?? 0;
        myCarsList.add(carData);
      }

      return myCarsList;
    } catch (e) {
      print("Erro ao buscar meus carros: $e");
      return [];
    }
  }

  Future<void> _deleteCar(String carId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('mycars')
          .doc(carId)
          .delete();

      await FirebaseFirestore.instance
          .collection('cars')
          .doc(carId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Carro excluído com sucesso'),
      ));
      setState(() {});
    } catch (e) {
      print("Erro ao excluir carro: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Erro ao excluir o carro'),
      ));
    }
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> car) {
    final TextEditingController nameController =
    TextEditingController(text: car['name']);
    final TextEditingController modelController =
    TextEditingController(text: car['model']);
    final TextEditingController litersController =
    TextEditingController(text: car['liters'].toString());
    final TextEditingController kilometrageController =
    TextEditingController(text: car['kilometrage'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Editar Informações do Carro"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Nome"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(labelText: "Modelo"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: litersController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Litros"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: kilometrageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Quilometragem"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedName = nameController.text.trim();
                final updatedModel = modelController.text.trim();
                final updatedLiters =
                double.tryParse(litersController.text.trim());
                final updatedKilometrage =
                int.tryParse(kilometrageController.text.trim());

                if (updatedLiters == null || updatedKilometrage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Insira valores válidos.")),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_user!.uid)
                      .collection('mycars')
                      .doc(car['id'])
                      .update({
                    'name': updatedName,
                    'model': updatedModel,
                    'liters': updatedLiters,
                    'kilometrage': updatedKilometrage,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Informações atualizadas com sucesso."),
                  ));
                  Navigator.pop(context);
                  setState(() {});
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Erro ao atualizar o carro: $error"),
                    ),
                  );
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Veículos"),
      ),
      drawer: StandartDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getMyCars(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Erro ao carregar seus carros'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('Você não tem carros cadastrados.'));
                  } else {
                    List<Map<String, dynamic>> myCars = snapshot.data!;
                    return ListView.builder(
                      itemCount: myCars.length,
                      itemBuilder: (context, index) {
                        var car = myCars[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(car['name'] ?? 'Nome desconhecido'),
                            subtitle:
                            Text('Modelo: ${car['model'] ?? 'Desconhecido'}'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VehicleInfoScreen(car: car),
                                ),
                              );
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditDialog(context, car);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteCar(car['id']);
                                  },
                                ),
                              ],
                            ),
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
