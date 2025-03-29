import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:untitled6/history.dart';
import 'package:untitled6/login.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String dropdownValue = '';
  String? selectedTimeSlot;
  String? selectedDay;
  String? name;
  String? phone_number;
  List<String> services = [];
  List<String> timeSlots = [];
  List<String> day = [];
  String? dateType;
  String? bookingStatus;
  String currentUserID = FirebaseAuth.instance.currentUser?.uid ?? "";

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
    fetchBookingStatus();
    _setupBookingStatusListener();
  }

  void _setupBookingStatusListener() {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      _firestore
          .collection('appointments')
          .where('userID', isEqualTo: userEmail)
          .orderBy('date', descending: true)
          .limit(1)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            bookingStatus = snapshot.docs.first['status'] ?? 'Pending';
          });
        }
      });
    }
  }

  void fetchDataFromFirestore() async {
    try {
      final servicesSnapshot =
      await FirebaseFirestore.instance.collection('services').get();
      final timeSlotsSnapshot =
      await FirebaseFirestore.instance.collection('timeSlots').get();
      final daySnapshot =
      await FirebaseFirestore.instance.collection('day').get();

      setState(() {
        services =
            servicesSnapshot.docs.map((doc) => doc['name'] as String).toList();
        timeSlots = timeSlotsSnapshot.docs
            .map((doc) => doc['slot'] as String)
            .toList();
        day = daySnapshot.docs.map((doc) => doc['day'] as String).toList();
        if (services.isNotEmpty) {
          dropdownValue = services.first;
        }
      });
    } catch (e) {
      log('Error fetching data from Firestore: $e');
    }
  }

  Future<void> fetchBookingStatus() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('userID', isEqualTo: currentUserID)
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        bookingStatus = data['status'] ?? 'Pending';
      });
    }
  }


  Future<void> _bookAppointment() async {
    try {
      if (_formKey.currentState!.validate()) {
        if (selectedTimeSlot == null || dateType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a time slot and date')),
          );
          return;
        }

        _formKey.currentState!.save();

        DateTime selectedDate = DateTime.now();
        if (dateType == 'TOMORROW') {
          selectedDate = selectedDate.add(const Duration(days: 1));
        }
        String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);

        await _firestore.collection('appointments').add({
          'name': name,
          'service': dropdownValue,
          'timeSlot': selectedTimeSlot,
          'date': formattedDate,
          'userID': FirebaseAuth.instance.currentUser?.email,
          'phoneNUmber': phone_number,
          'status': 'Pending',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Booking request sent, please wait till your booking gets approved!')),
        );

        setState(() {
          name = null;
          dropdownValue = services.isNotEmpty ? services.first : '';
          selectedTimeSlot = null;
          selectedDay = null;
          dateType = null;
          phone_number = null;
        });

        _formKey.currentState!.reset();
        fetchBookingStatus().then((_) {
          setState(() {});
        });

      }
    } catch (e) {
      log('Error booking appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking appointment: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Book an appointment',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () => logout(context),
          tooltip: "Logout",
          color: Colors.white,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.history,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const historypage()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Name TextFormField
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        onSaved: (value) => name = value,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Phone number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your mobile number';
                          }
                          return null;
                        },
                        onSaved: (value) => phone_number = value,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        value: dropdownValue.isNotEmpty ? dropdownValue : null,
                        decoration: InputDecoration(
                          labelText: 'Service',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a service';
                          }
                          return null;
                        },
                        items: services.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select time slot',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Time Slot Selection
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: timeSlots.map((timeSlot) {
                        return ChoiceChip(
                          label: Text(timeSlot),
                          selected: selectedTimeSlot == timeSlot,
                          labelStyle: TextStyle(
                            color: selectedTimeSlot == timeSlot
                                ? Colors.white
                                : Colors.black,
                          ),
                          selectedColor: Colors.teal,
                          backgroundColor: Colors.grey.shade200,
                          onSelected: (bool selected) {
                            setState(() {
                              selectedTimeSlot = selected ? timeSlot : null;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 8),
                    // Time Slot Selection
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Date',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Wrap(
                      spacing: 8.0,
                      children: ['TODAY', 'TOMORROW'].map((type) {
                        return ChoiceChip(
                          label: Text(type),
                          selected: dateType == type,
                          onSelected: (bool selected) {
                            setState(() {
                              dateType = selected ? type : null;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                    const SizedBox(height: 60),
                    ElevatedButton(
                      onPressed: () async {

                        if (dateType == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a date (Today or Tomorrow)')),
                          );
                          return;
                        }

                        DateTime selectedDate = DateTime.now();
                        if (dateType == 'TOMORROW') {
                          selectedDate = selectedDate.add(const Duration(days: 1));
                        }

                        if (_formKey.currentState!.validate()) {
                          if (selectedTimeSlot == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a time slot')),
                            );
                            return;
                          }
                          _formKey.currentState!.save();
                          _bookAppointment();
                        }
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const historypage()));
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        backgroundColor: Colors.teal,
                      ),
                      child: const Text(
                        'Book Appointment',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
