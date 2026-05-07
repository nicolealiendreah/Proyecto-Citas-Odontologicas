import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/mobile_frame.dart';
import '../services/appointment_service.dart';
import '../widgets/app_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageAppointmentsScreen extends StatelessWidget {
  const ManageAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MobileFrame(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 30),

                Text(
                  'MIS CITAS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: const Color(0xFF0F6B93),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Citas Próximas',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Administra tus citas y tratamientos próximos.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 28),
                _buildWeeklySummary(context),

                const SizedBox(height: 28),
                _buildSectionTitle('PRÓXIMAS CITAS'),
                const SizedBox(height: 18),

                StreamBuilder(
                  stream: AppointmentService().getMyAppointments(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No tienes citas próximas.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    final citas = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      final status = (data['status'] ?? '')
                          .toString()
                          .toLowerCase()
                          .trim();

                      final fechaHoraCita = _parseAppointmentDateTime(
                        data['date'],
                        data['time'],
                      );

                      final esFutura = fechaHoraCita.isAfter(DateTime.now());

                      return esFutura &&
                          status != 'cancelada' &&
                          status != 'completada';
                    }).toList();

                    if (citas.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No tienes citas próximas.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: citas.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: _buildAppointmentCard(
                            context: context,
                            appointmentId: doc.id,
                            accentColor: const Color(0xFF0F7892),
                            patientName: data['patientName'] ?? 'Paciente',
                            time: '${data['date']} - ${data['time']}',
                            treatment: data['treatment'] ?? '',
                            treatmentColor: const Color(0xFF0F7892),
                            patientIcon: Icons.person,
                            patientIconColor: const Color(0xFF0F7892),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const AppNavBar(currentIndex: 1),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.medical_services_outlined,
              color: AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'MYDENT',
              style: GoogleFonts.inter(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.notifications_none, color: Color(0xFF94A3B8)),
            const SizedBox(width: 10),
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklySummary(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.68),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen Semanal',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tienes 12 citas confirmadas para los\npróximos 7 días. El 40% son\ncirugías complejas.',
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: 180,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/appointments');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.event_available_outlined),
              label: Text(
                'Nueva Cita',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFFDCECF5),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              '12',
              style: GoogleFonts.inter(
                fontSize: 64,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFA8CBDD),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 1,
          color: const Color(0xFFE2E8F0),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard({
    required BuildContext context,
    required String appointmentId,
    required Color accentColor,
    required String patientName,
    required String time,
    required String treatment,
    required Color treatmentColor,
    required IconData patientIcon,
    required Color patientIconColor,
  }) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 190,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 0),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.72),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F4F7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          patientIcon,
                          color: patientIconColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patientName,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 15,
                                        color: Color(0xFF4B5563),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          time,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            height: 1.4,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.medical_services_outlined,
                                        size: 15,
                                        color: treatmentColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          treatment,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            height: 1.4,
                                            color: treatmentColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/appointments',
                              arguments: appointmentId,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFD1D5DB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text(
                            'Reprogramar',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await AppointmentService().cancelAppointment(
                              appointmentId,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFF2CACA)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime _parseDate(dynamic fechaRaw) {
    if (fechaRaw is Timestamp) {
      return fechaRaw.toDate();
    }

    if (fechaRaw is String) {
      return DateTime.tryParse(fechaRaw) ?? DateTime.now();
    }

    return DateTime.now();
  }

  DateTime _parseAppointmentDateTime(dynamic fechaRaw, dynamic horaRaw) {
    final fecha = _parseDate(fechaRaw);
    final horaTexto = (horaRaw ?? '').toString().trim();

    if (horaTexto.isEmpty) {
      return DateTime(fecha.year, fecha.month, fecha.day);
    }

    int hour = 0;
    int minute = 0;

    if (horaTexto.toUpperCase().contains('AM') ||
        horaTexto.toUpperCase().contains('PM')) {
      final isPM = horaTexto.toUpperCase().contains('PM');

      final cleanTime = horaTexto
          .replaceAll(RegExp(r'AM|PM', caseSensitive: false), '')
          .trim();

      final parts = cleanTime.split(':');
      hour = int.tryParse(parts[0]) ?? 0;
      minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
    } else {
      final parts = horaTexto.split(':');
      hour = int.tryParse(parts[0]) ?? 0;
      minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    }

    return DateTime(fecha.year, fecha.month, fecha.day, hour, minute);
  }
}
