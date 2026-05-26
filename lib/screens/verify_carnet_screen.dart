import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyCarnetScreen extends StatefulWidget {
  const VerifyCarnetScreen({super.key});

  @override
  State<VerifyCarnetScreen> createState() => _VerifyCarnetScreenState();
}

class _VerifyCarnetScreenState extends State<VerifyCarnetScreen> {
  bool frontUploaded = false;
  bool backUploaded = false;
  bool isLoading = false;

  String? fullName;
  String? ci;

  final List<String> randomNames = [
    'Nicole Aliendre',
    'María Fernanda Rojas',
    'Camila Vargas',
    'Andrea Salazar',
    'Valeria Méndez',
    'Daniela Herrera',
    'Sofía Gutiérrez',
  ];

  void simulateCarnetScan() {
    final random = Random();

    setState(() {
      frontUploaded = true;
      backUploaded = true;
      fullName = randomNames[random.nextInt(randomNames.length)];
      ci = '${10000000 + random.nextInt(89999999)}';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datos extraídos del carnet correctamente'),
      ),
    );
  }

  Future<void> saveCarnetData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (!frontUploaded || !backUploaded || fullName == null || ci == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero debes escanear el carnet'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fullName': fullName,
        'ci': ci,
        'profileCompleted': true,
        'carnetVerified': true,
        'carnetFrontUploaded': true,
        'carnetBackUploaded': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Carnet verificado correctamente'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar datos: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget buildStatusCard() {
    if (fullName == null || ci == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: const Text(
          'Aún no se extrajeron datos del carnet.',
          style: TextStyle(fontSize: 15),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F6EF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E7D32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified, color: Color(0xFF2E7D32)),
              SizedBox(width: 8),
              Text(
                'Datos extraídos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Nombre: $fullName'),
          const SizedBox(height: 6),
          Text('CI: $ci'),
        ],
      ),
    );
  }

  Widget buildCarnetStatus({
    required String title,
    required bool uploaded,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
      decoration: BoxDecoration(
        color: uploaded ? const Color(0xFFE8F6EF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: uploaded ? const Color(0xFF2E7D32) : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            uploaded ? Icons.check_circle : Icons.credit_card,
            color: uploaded ? const Color(0xFF2E7D32) : Colors.grey,
          ),
          const SizedBox(width: 10),
          Text(
            uploaded ? '$title escaneado' : title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSave = frontUploaded && backUploaded && fullName != null && ci != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar carnet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Escaneo simulado del carnet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Presiona el botón para simular la lectura del anverso y reverso del carnet. El sistema generará nombre y CI automáticamente.',
            ),

            const SizedBox(height: 24),

            buildCarnetStatus(
              title: 'Anverso del carnet',
              uploaded: frontUploaded,
            ),

            const SizedBox(height: 12),

            buildCarnetStatus(
              title: 'Reverso del carnet',
              uploaded: backUploaded,
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: isLoading ? null : simulateCarnetScan,
              icon: const Icon(Icons.document_scanner),
              label: const Text('Escanear carnet'),
            ),

            const SizedBox(height: 24),

            buildStatusCard(),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: isLoading || !canSave ? null : saveCarnetData,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Guardar verificación'),
            ),
          ],
        ),
      ),
    );
  }
}