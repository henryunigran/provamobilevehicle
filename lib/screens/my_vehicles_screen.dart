import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provamobilevehicle/screens/modules/standart_drawer.dart';

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

      print("UID do usuário logado: ${_user!.uid}");

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('mycars')
          .get();

      print("Número de carros encontrados: ${querySnapshot.docs.length}");

      List<Map<String, dynamic>> myCarsList = [];
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> carData = doc.data() as Map<String, dynamic>;
        carData['id'] = doc.id;
        myCarsList.add(carData);
      });

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Carro excluído com sucesso'),
      ));
      setState(() {});
    } catch (e) {
      print("Erro ao excluir carro: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao excluir o carro'),
      ));
    }
  }

  Future<void> _editCar(String carId, String? name, String? model, String? year) async {
    TextEditingController _nameController = TextEditingController(text: name ?? '');
    TextEditingController _modelController = TextEditingController(text: model ?? '');
    TextEditingController _yearController = TextEditingController(text: year ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Editar Carro"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Nome do Carro"),
              ),
              TextField(
                controller: _modelController,
                decoration: InputDecoration(labelText: "Modelo do Carro"),
              ),
              TextField(
                controller: _yearController,
                decoration: InputDecoration(labelText: "Ano do Carro"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_user!.uid)
                      .collection('mycars')
                      .doc(carId)
                      .update({
                    'name': _nameController.text,
                    'model': _modelController.text,
                    'year': _yearController.text,
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Carro atualizado com sucesso'),
                  ));
                  setState(() {});
                } catch (e) {
                  print("Erro ao editar carro: $e");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Erro ao editar o carro'),
                  ));
                }
              },
              child: Text("Salvar"),
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
            Text('Bem-vindo, $_userName!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text('Seus carros:', style: TextStyle(fontSize: 20)),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getMyCars(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar seus carros'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Você não tem carros cadastrados.'));
                  } else {
                    List<Map<String, dynamic>> myCars = snapshot.data!;
                    return ListView.builder(
                      itemCount: myCars.length,
                      itemBuilder: (context, index) {
                        var car = myCars[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(car['name'] ?? 'Nome desconhecido'),
                            subtitle: Text('Modelo: ${car['model'] ?? 'Desconhecido'}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _editCar(car['id'], car['name'], car['model'], car['year']);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
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
