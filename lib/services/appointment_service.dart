import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';

class AppointmentService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getMyAppointments() {
    final user = _auth.currentUser;

    if (user == null || user.phoneNumber == null) {
      return const Stream.empty();
    }

    return _db
        .collection('appointments')
        .where('patientPhone', isEqualTo: user.phoneNumber)
        .where('status', whereIn: ['programada', 'confirmada'])
        .snapshots();
  }

  Future<void> createAppointment({
    required String patientName,
    required String date,
    required String time,
    required String treatment,
    required String doctor,
    required String patientPhone,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/appointments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': user.uid,
        'patientPhone': patientPhone,
        'patientName': patientName,
        'date': date,
        'time': time,
        'treatment': treatment,
        'doctor': doctor,
      }),
    );

    if (response.statusCode == 201) {
      return;
    }

    final data = jsonDecode(response.body);

    throw Exception(data['message'] ?? 'No se pudo registrar la cita');
  }

  Future<bool> checkAvailability({
    required String date,
    required String time,
    required String doctor,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/appointments/check-availability'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'date': date, 'time': time, 'doctor': doctor}),
    );

    if (response.statusCode == 200) {
      return true;
    }

    if (response.statusCode == 409) {
      return false;
    }

    final data = jsonDecode(response.body);

    throw Exception(
      data['message'] ?? 'No se pudo verificar la disponibilidad',
    );
  }

  Future<void> cancelAppointment(String id) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/appointments/$id/cancel'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return;
    }

    final data = jsonDecode(response.body);

    throw Exception(data['message'] ?? 'No se pudo cancelar la cita');
  }

  Future<void> rescheduleAppointment({
    required String id,
    required String newDate,
    required String newTime,
    required String treatment,
    required String doctor,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/appointments/$id/reschedule'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'date': newDate,
        'time': newTime,
        'treatment': treatment,
        'doctor': doctor,
      }),
    );

    if (response.statusCode == 200) {
      return;
    }

    final data = jsonDecode(response.body);

    throw Exception(data['message'] ?? 'No se pudo reprogramar la cita');
  }

  Future<void> updateAppointmentStatus({
    required String id,
    required String status,
  }) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/appointments/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      return;
    }

    final data = jsonDecode(response.body);

    throw Exception(
      data['message'] ?? 'No se pudo actualizar el estado de la cita',
    );
  }
}
