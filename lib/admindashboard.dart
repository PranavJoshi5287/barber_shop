import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled6/changeServices.dart';
import 'package:untitled6/changeSlots.dart';
import 'package:untitled6/login.dart';

class Admindashboard extends StatefulWidget {
  const Admindashboard({super.key});

  @override
  State<Admindashboard> createState() => _AdmindashboardState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;

void logout(BuildContext context) {
  _auth.signOut().then((_) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  });
}

class _AdmindashboardState extends State<Admindashboard> {
  CollectionReference bookings = FirebaseFirestore.instance.collection('appointments');

  void updateStatus(String docId, String status, String userId) {
    bookings.doc(docId).update({'status': status}).then((_) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .doc(docId)
          .update({'status': status});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.logout, color: Colors.white),
          onPressed: () => logout(context),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Change Slots') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeSlots()));
              } else if (value == 'Change Services') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ManageServices()));
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 'Change Slots', child: Text('Change Slots')),
                PopupMenuItem(value: 'Change Services', child: Text('Change Services')),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: bookings.orderBy('date').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No booking history found."));
          }

          return ListView(
            children: snapshot.data!.docs.map((document) {
              var data = document.data() as Map<String, dynamic>;
              if (data['status'] != 'Approved' && data['status'] != 'Pending') {
                return SizedBox();
              }
              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date: ${data['date'] ?? 'Unknown'}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                      Text("Name: ${data['name'] ?? 'N/A'}"),
                      Text("Phone: ${data['phoneNUmber'] ?? 'N/A'}"),
                      Text("Service: ${data['service'] ?? 'N/A'}"),
                      Text("Time Slot: ${data['timeSlot'] ?? 'N/A'}"),
                      Text("User ID: ${data['userID'] ?? 'N/A'}"),
                      Text(
                        "Status: ${data['status'] ?? 'Pending'}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: data['status'] == 'Approved' ? Colors.green : Colors.yellow,
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              updateStatus(document.id, 'Approved', data['userID']);
                            },
                            child: Text("Approve"),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              updateStatus(document.id, 'Declined', data['userID']);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: Text("Decline"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
