import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/mobile_frame.dart';
import '../widgets/app_nav_bar.dart';
import '../services/appointment_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime focusedMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();
  String selectedTime = '11:15';

  final List<Map<String, String>> timeSlots = [
    {'time': '09:00', 'period': 'Mañana', 'label': 'Disponible'},
    {'time': '10:30', 'period': 'Mañana', 'label': 'Disponible'},
    {'time': '11:15', 'period': 'Mañana', 'label': 'Recomendado para ti'},
    {'time': '15:00', 'period': 'Tarde', 'label': 'Disponible'},
    {'time': '17:45', 'period': 'Tarde', 'label': 'Disponible'},
  ];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    String? appointmentId;
    String selectedTreatment = 'Consulta Odontológica';

    if (args is String) {
      appointmentId = args;
    } else if (args is Map<String, dynamic>) {
      appointmentId = args['appointmentId'];
      selectedTreatment = args['treatment'] ?? 'Consulta Odontológica';
    }

    final isReschedule = appointmentId != null;

    return MobileFrame(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 26),
                Text(
                  'RESERVA DE TURNOS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.9,
                    color: const Color(0xFF0F6B93),
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Selecciona tu\n',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: 'Próxima Consulta',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F6B93),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildCalendarCard(),
                const SizedBox(height: 22),
                _buildAvailableSlotsCard(
                  isReschedule: isReschedule,
                  appointmentId: appointmentId,
                  selectedTreatment: selectedTreatment,
                ),
                const SizedBox(height: 22),
                _buildUrgencyCard(),
                const SizedBox(height: 22),
                _buildDoctorCard(),
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
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF9FD8F6),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                'JD',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(
      focusedMonth.year,
      focusedMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;

    final startWeekday = firstDayOfMonth.weekday; // lunes = 1
    final previousMonthLastDay = DateTime(
      focusedMonth.year,
      focusedMonth.month,
      0,
    ).day;

    final monthNames = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    final currentMonthTitle =
        '${monthNames[focusedMonth.month - 1]} ${focusedMonth.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                currentMonthTitle,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const Spacer(),

              GestureDetector(
                onTap: () {
                  setState(() {
                    focusedMonth = DateTime(
                      focusedMonth.year,
                      focusedMonth.month - 1,
                    );
                  });
                },
                child: const Icon(Icons.chevron_left, size: 22),
              ),

              const SizedBox(width: 12),

              GestureDetector(
                onTap: () {
                  setState(() {
                    focusedMonth = DateTime(
                      focusedMonth.year,
                      focusedMonth.month + 1,
                    );
                  });
                },
                child: const Icon(Icons.chevron_right, size: 22),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM']
                .map(
                  (e) => Text(
                    e,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFFB0B7C3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 18,
            runSpacing: 18,
            children: [
              ...List.generate(startWeekday - 1, (index) {
                final day = previousMonthLastDay - (startWeekday - 2) + index;
                return _calendarNumber('$day', faded: true);
              }),

              ...List.generate(daysInMonth, (index) {
                final day = index + 1;
                final date = DateTime(
                  focusedMonth.year,
                  focusedMonth.month,
                  day,
                );

                final isSelected =
                    selectedDate.year == date.year &&
                    selectedDate.month == date.month &&
                    selectedDate.day == date.day;

                final isPast = date.isBefore(
                  DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                  ),
                );

                return GestureDetector(
                  onTap: isPast
                      ? null
                      : () {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFAEDDF8)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isPast ? const Color(0xFFD0D5DD) : Colors.black,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.info_outline, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Los horarios se actualizan en tiempo real según cancelaciones.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendarNumber(String text, {bool faded = false}) {
    return SizedBox(
      width: 24,
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: faded ? const Color(0xFFD0D5DD) : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableSlotsCard({
    required bool isReschedule,
    required String? appointmentId,
    required String selectedTreatment,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F6B93),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Horarios Libres',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFAEDDF8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '8 DISPONIBLES',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...timeSlots.map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTimeSlot(slot),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: () async {
                final formattedDate =
                    '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

                const doctor = 'Dr. Marcos Reys';

                try {
                  if (!isReschedule) {
                    final available = await AppointmentService()
                        .checkAvailability(
                          date: formattedDate,
                          time: selectedTime,
                          doctor: doctor,
                        );
                    if (!mounted) return;

                    if (!available) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'El horario seleccionado ya no está disponible',
                          ),
                        ),
                      );
                      return;
                    }
                  }
                  if (!mounted) return;
                  Navigator.pushNamed(
                    context,
                    '/confirm-appointment',
                    arguments: {
                      'isReschedule': isReschedule,
                      'appointmentId': appointmentId,
                      'date': formattedDate,
                      'time': selectedTime,
                      'treatment': selectedTreatment,
                      'doctor': doctor,
                    },
                  );
                } catch (e) {
                  final message = e.toString().replaceFirst('Exception: ', '');

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: const Color.fromARGB(50, 0, 0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Confirmar Selección  →',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(Map<String, String> slot) {
    final isSelected = slot['time'] == selectedTime;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTime = slot['time']!;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color.fromARGB(30, 0, 0, 0),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0E2F58)
                    : const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                slot['time']!,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot['period']!,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    slot['label']!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : const Color(0xFF8A9099),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle,
              color: isSelected ? Colors.white : const Color(0xFF7D8189),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgencyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 28, 26, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF98D7F5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Urgencias 24hs',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0B567C),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Si tienes un dolor agudo, no\nesperes. Contamos con atención\nprioritaria.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF25617D),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              'Llamar Ahora',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.medical_services, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. Marcos Reys',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Especialista en Implantología',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '"Nuestra prioridad es que vuelvas a\nsonreír con total confianza y sin dolor."',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF333333),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
