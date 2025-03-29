import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangeSlots extends StatefulWidget {
  const ChangeSlots({super.key});

  @override
  State<ChangeSlots> createState() => _ChangeSlotsState();
}

class _ChangeSlotsState extends State<ChangeSlots> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _newSlotController = TextEditingController();

  Future<List<Map<String, dynamic>>> fetchSlots() async {
    QuerySnapshot snapshot = await _firestore.collection('timeSlots').get();
    List<Map<String, dynamic>> slots = [];

    for (int i = 0; i < snapshot.docs.length; i++) {
      var doc = snapshot.docs[i];
      String id = doc.id;
      String slot = doc['slot'];

      slots.add({'id': id, 'slot': slot});
    }

    return slots;
  }

  Future<void> updateSlot(String docId, String newTime) async {
    await _firestore.collection('timeSlots').doc(docId).update({'slot': newTime});
  }

  Future<void> deleteSlot(String docId) async {
    await _firestore.collection('timeSlots').doc(docId).delete();
    setState(() {});
  }

  Future<void> addSlot(String slotTime) async {
    DocumentReference newDoc = await _firestore.collection('timeSlots').add({'slot': slotTime});
    setState(() {});
  }

  Future<void> _pickTime(BuildContext context, String docId, String currentTime) async {
    List<String> times = currentTime.split('-');
    List<String> startParts = times[0].trim().split(':');
    List<String> endParts = times[1].trim().split(':');

    TimeOfDay initialStart = TimeOfDay(
      hour: int.parse(startParts[0]),
      minute: int.parse(startParts[1]),
    );

    TimeOfDay? pickedStart = await showTimePicker(
      context: context,
      initialTime: initialStart,
    );

    if (pickedStart != null) {
      TimeOfDay? pickedEnd = await showTimePicker(
        context: context,
        initialTime: pickedStart,
      );

      if (pickedEnd != null) {
        String formattedTime = "${pickedStart.hour}:${pickedStart.minute} - ${pickedEnd.hour}:${pickedEnd.minute}";
        await updateSlot(docId, formattedTime);
        setState(() {});
      }
    }
  }

  void _showAddSlotDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Time Slot"),
          content: TextField(
            controller: _newSlotController,
            decoration: const InputDecoration(hintText: "Enter time"),
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
                if (_newSlotController.text.isNotEmpty) {
                  addSlot(_newSlotController.text);
                }
                _newSlotController.clear();
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
        title: const Text("Manage Time Slots", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white,),
            onPressed: _showAddSlotDialog,
          ),
        ],
      ),
      body: FutureBuilder(
        future: fetchSlots(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No time slots available"));
          }

          List<Map<String, dynamic>> slots = snapshot.data!;
          return ListView.builder(
            itemCount: slots.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text("${slots[index]['id']}: ${slots[index]['slot']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _pickTime(context, slots[index]['id'], slots[index]['slot']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteSlot(slots[index]['id']),
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
