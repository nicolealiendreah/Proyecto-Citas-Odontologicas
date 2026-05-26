import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/mobile_frame.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/app_nav_bar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final phone = user?.phoneNumber;

    if (user == null || phone == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

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
                const SizedBox(height: 34),
                Text(
                  'Historial de Citas',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Consulta el registro detallado de tus\ntratamientos y visitas anteriores.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 30),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('appointments')
                      .where('patientPhone', isEqualTo: phone)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Text(
                        'Aún no tienes citas en tu historial.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
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

                      final yaPaso = fechaHoraCita.isBefore(DateTime.now());

                      return status == 'cancelada' ||
                          status == 'completada' ||
                          yaPaso;
                    }).toList();
                    if (citas.isEmpty) {
                      return Text(
                        'Aún no tienes citas en tu historial.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      );
                    }
                    return Column(
                      children: citas.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        DateTime fecha;

                        final fechaRaw = data['date'];

                        if (fechaRaw is Timestamp) {
                          fecha = fechaRaw.toDate();
                        } else if (fechaRaw is String) {
                          fecha = DateTime.parse(fechaRaw);
                        } else {
                          fecha = DateTime.now();
                        }
                        final status = (data['status'] ?? '')
                            .toString()
                            .toLowerCase()
                            .trim();
                        final tratamiento =
                            (data['treatment'] ?? 'Consulta odontológica')
                                .toString();
                        final doctor = (data['doctor'] ?? 'Odontólogo')
                            .toString();
                        final hora = (data['time'] ?? '').toString();

                        final fechaHoraCita = _parseAppointmentDateTime(
                          data['date'],
                          data['time'],
                        );

                        final yaPaso = fechaHoraCita.isBefore(DateTime.now());
                        final esCancelada = status == 'cancelada';

                        final estadoVisible = esCancelada
                            ? 'CANCELADA'
                            : yaPaso
                            ? 'COMPLETADA'
                            : status.toUpperCase();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: _buildHistoryCard(
                            day: fecha.day.toString().padLeft(2, '0'),
                            month: _monthName(fecha.month),
                            title: tratamiento,
                            time: hora,
                            doctor: doctor,
                            status: estadoVisible,
                            statusColor: esCancelada
                                ? const Color(0xFFFAD4D0)
                                : const Color(0xFFD8F3DC),
                            statusTextColor: esCancelada
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF16A34A),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 22),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _downloadFullReport(context, phone),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD9E1E8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.download_outlined,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Descargar Reporte Completo',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const AppNavBar(currentIndex: 2),
      ),
    );
  }

  Future<void> _downloadFullReport(BuildContext context, String phone) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('patientPhone', isEqualTo: phone)
          .get();

      final citas = snapshot.docs.where((doc) {
        final data = doc.data();

        final status = (data['status'] ?? '').toString().toLowerCase().trim();

        final fechaHoraCita = _parseAppointmentDateTime(
          data['date'],
          data['time'],
        );

        final yaPaso = fechaHoraCita.isBefore(DateTime.now());

        return status == 'cancelada' || status == 'completada' || yaPaso;
      }).toList();

      if (citas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No hay citas en el historial para generar el reporte.',
            ),
          ),
        );
        return;
      }

      citas.sort((a, b) {
        final fechaA = _parseDate(a.data()['date']);
        final fechaB = _parseDate(b.data()['date']);
        return fechaB.compareTo(fechaA);
      });

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context pdfContext) {
            return [
              pw.Text(
                'MYDENT',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'Reporte completo de historial de citas',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Generado el: ${_formatDate(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 24),

              pw.TableHelper.fromTextArray(
                headers: ['Fecha', 'Hora', 'Tratamiento', 'Doctor', 'Estado'],
                data: citas.map((doc) {
                  final data = doc.data();

                  final fecha = _parseDate(data['date']);
                  final hora = (data['time'] ?? '').toString();
                  final tratamiento =
                      (data['treatment'] ?? 'Consulta odontológica').toString();
                  final doctor = (data['doctor'] ?? 'Odontólogo').toString();
                  final rawStatus = (data['status'] ?? '')
                      .toString()
                      .toLowerCase()
                      .trim();

                  final fechaHoraCita = _parseAppointmentDateTime(
                    data['date'],
                    data['time'],
                  );

                  final yaPaso = fechaHoraCita.isBefore(DateTime.now());

                  final status = rawStatus == 'cancelada'
                      ? 'CANCELADA'
                      : yaPaso
                      ? 'COMPLETADA'
                      : rawStatus.toUpperCase();

                  return [
                    _formatDate(fecha),
                    hora,
                    tratamiento,
                    doctor,
                    status,
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey800,
                ),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(8),
              ),

              pw.SizedBox(height: 24),
              pw.Text(
                'Total de citas en historial: ${citas.length}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ];
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'reporte_historial_citas_mydent.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar el reporte: $e')),
      );
    }
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
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
              width: 32,
              height: 32,
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required bool dark,
  }) {
    return Container(
      width: double.infinity,
      height: 126,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: dark ? AppColors.primary : Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: dark ? Colors.white : const Color(0xFF0F6B93),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: dark ? Colors.white : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: const Color(0xFF6AA5C0),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String day,
    required String month,
    required String title,
    required String time,
    required String doctor,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
    Color titleColor = AppColors.textPrimary,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  month,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: statusTextColor,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          time,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF667085),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person,
                          size: 14,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          doctor,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF667085),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'ENE',
      'FEB',
      'MAR',
      'ABR',
      'MAY',
      'JUN',
      'JUL',
      'AGO',
      'SEP',
      'OCT',
      'NOV',
      'DIC',
    ];

    return months[month - 1];
  }
}
