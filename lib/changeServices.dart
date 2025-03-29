import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageServices extends StatefulWidget {
  const ManageServices({super.key});

  @override
  State<ManageServices> createState() => _ManageServicesState();
}

class _ManageServicesState extends State<ManageServices> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _serviceController = TextEditingController();

  Future<List<Map<String, dynamic>>> fetchServices() async {
    QuerySnapshot snapshot = await _firestore.collection('services').get();
    List<Map<String, dynamic>> services = [];

    for (int i = 0; i < snapshot.docs.length; i++) {
      var doc = snapshot.docs[i];
      String id = doc.id;
      String name = doc['name'];

      services.add({'id': id, 'name': name});
    }

    return services;
  }

  Future<void> updateService(String docId, String newName) async {
    await _firestore.collection('services').doc(docId).update({'name': newName});
    setState(() {});
  }

  Future<void> deleteService(String docId) async {
    await _firestore.collection('services').doc(docId).delete();
    setState(() {});
  }

  Future<void> addService(String name) async {
    await _firestore.collection('services').add({'name': name});
    setState(() {});
  }

  void _showEditDialog(String docId, String currentName) {
    _serviceController.text = currentName;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Service"),
          content: TextField(
            controller: _serviceController,
            decoration: const InputDecoration(hintText: "Enter new service name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (_serviceController.text.isNotEmpty) {
                  updateService(docId, _serviceController.text);
                }
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void _showAddServiceDialog() {
    _serviceController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Service"),
          content: TextField(
            controller: _serviceController,
            decoration: const InputDecoration(hintText: "Enter service name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (_serviceController.text.isNotEmpty) {
                  addService(_serviceController.text);
                }
                Navigator.pop(context);
              },
              child: const Text("Add"),
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
        title: const Text("Manage Services", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white,),
            onPressed: _showAddServiceDialog,
          ),
        ],
      ),
      body: FutureBuilder(
        future: fetchServices(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No services available"));
          }

          List<Map<String, dynamic>> services = snapshot.data!;
          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text("${services[index]['id']}: ${services[index]['name']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditDialog(services[index]['id'], services[index]['name']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteService(services[index]['id']),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
