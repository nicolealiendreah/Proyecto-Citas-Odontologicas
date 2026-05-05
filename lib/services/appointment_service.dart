import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getMyAppointments() {
    final uid = _auth.currentUser!.uid;

    return _db
        .collection('appointments')
        .where('userId', isEqualTo: uid)
        .where('status', whereIn: ['confirmada', 'reprogramada'])
        .snapshots();
  }

  Future<void> createAppointment({
    required String patientName,
    required String date,
    required String time,
    required String treatment,
    required String doctor,
  }) async {
    final uid = _auth.currentUser!.uid;

    final exists = await _db
        .collection('appointments')
        .where('date', isEqualTo: date)
        .where('time', isEqualTo: time)
        .where('status', whereIn: ['confirmada', 'reprogramada'])
        .get();

    if (exists.docs.isNotEmpty) {
      throw Exception('Ese horario ya no está disponible.');
    }

    await _db.collection('appointments').add({
      'userId': uid,
      'patientName': patientName,
      'date': date,
      'time': time,
      'treatment': treatment,
      'doctor': doctor,
      'status': 'confirmada',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelAppointment(String id) async {
    await _db.collection('appointments').doc(id).update({
      'status': 'cancelada',
    });
  }

  Future<void> rescheduleAppointment({
    required String id,
    required String newDate,
    required String newTime,
    required String treatment,
    required String doctor,
  }) async {
    await _db.collection('appointments').doc(id).update({
      'date': newDate,
      'time': newTime,
      'treatment': treatment,
      'doctor': doctor,
      'status': 'reprogramada',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
