import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Firebase configuration
const firebaseConfig = FirebaseOptions(
    apiKey: "AIzaSyBP6C-7Gmn_xFB5GPZmnunp6l4M69kmRlE",
    authDomain: "lab31-b6279.firebaseapp.com",
    projectId: "lab31-b6279",
    storageBucket: "lab31-b6279.firebasestorage.app",
    messagingSenderId: "437812111863",
    appId: "1:437812111863:web:b0f53fadf5c1dfe8ef66f2",
    measurementId: "G-4DM365HX6W");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the configuration
  await Firebase.initializeApp(options: firebaseConfig);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FIREBASE LAB3',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SensorListScreen(),
    );
  }
}
 
class Sensor {
  final String id;
  final String name;
  final double value;

  Sensor({required this.id, required this.name, required this.value});

  // Convert Sensor to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
    };
  }

  // Create Sensor from Firestore
  factory Sensor.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Sensor(
      id: doc.id,
      name: data['name'] ?? '',
      value: data['value'] ?? 0.0,
    );
  }
}

class SensorListScreen extends StatefulWidget {
  @override
  _SensorListScreenState createState() => _SensorListScreenState();
}

class _SensorListScreenState extends State<SensorListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  Future<List<Sensor>> _fetchSensors() async {
    try {
      final snapshot = await _firestore.collection('sensors').get();
      return snapshot.docs.map((doc) => Sensor.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      print('Firebase error: ${e.message}');
      throw 'Failed to load sensors: ${e.message}';
    } catch (e) {
      print('Unknown error: $e');
      throw 'Failed to load sensors';
    }
  }

  Future<void> _addSensor() async {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final double value = double.parse(_valueController.text);

      final newSensor = Sensor(id: '', name: name, value: value);
      await _firestore.collection('sensors').add(newSensor.toMap());

      _nameController.clear();
      _valueController.clear();

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensors'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Text field for Sensor Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Sensor Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a sensor name.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  // Text field for Sensor Value
                  TextFormField(
                    controller: _valueController,
                    decoration: InputDecoration(
                      labelText: 'Sensor Value',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a sensor value.';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  // Button to Add Sensor
                  ElevatedButton(
                    onPressed: _addSensor,
                    child: Text('Add Sensor'),
                  ),
                ],
              ),
            ),
          ),

          // Display List of Sensors
          Expanded(
            child: FutureBuilder<List<Sensor>>(
              future: _fetchSensors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No sensors available.'));
                }

                final sensors = snapshot.data!;

                return ListView.builder(
                  itemCount: sensors.length,
                  itemBuilder: (context, index) {
                    final sensor = sensors[index];
                    return ListTile(
                      title: Text(sensor.name),
                      subtitle: Text('Value: ${sensor.value}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
