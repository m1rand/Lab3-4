import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sensor.dart';

class FirestoreHandler {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Додавання сенсора в Firestore
  Future<void> addSensorToFirestore(Sensor sensor) async {
    await _firestore.collection('sensors').add(sensor.toMap());
  }

  // Отримання сенсорів з Firestore
  Future<List<Sensor>> getSensorsFromFirestore() async {
    QuerySnapshot snapshot = await _firestore.collection('sensors').get();
    return snapshot.docs.map((doc) {
      return Sensor.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }
}
