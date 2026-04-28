import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/mobile_frame.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/auth_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? errorText;

  Future<void> _register() async {
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (fullName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      setState(() {
        errorText = 'Completa todos los campos.';
      });
      return;
    }

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
            'fullName': fullName,
            'phone': phone,
            'email': email,
            'role': 'paciente',
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorText = e.message ?? 'Error al registrar usuario.';
      });
    } catch (_) {
      setState(() {
        errorText = 'Ocurrió un error inesperado.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileFrame(
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F6F9),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.04,
                  child: Center(
                    child: Text(
                      'M',
                      style: GoogleFonts.inter(
                        fontSize: 430,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.78),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 6),
                        const AuthLogo(),
                        const SizedBox(height: 18),
                        Text(
                          'MYDENT',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'CREA TU CUENTA CLÍNICA',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 34),

                        if (errorText != null)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 18),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              errorText!,
                              style: GoogleFonts.inter(
                                color: AppColors.error,
                                fontSize: 14,
                              ),
                            ),
                          ),

                        CustomTextField(
                          label: 'Nombre completo',
                          hint: 'Ej. Alejandro Gómez',
                          icon: Icons.person_outline,
                          controller: _fullNameController,
                        ),
                        const SizedBox(height: 22),
                        CustomTextField(
                          label: 'Teléfono',
                          hint: '+34 000 000 000',
                          icon: Icons.phone_outlined,
                          controller: _phoneController,
                        ),
                        const SizedBox(height: 22),
                        CustomTextField(
                          label: 'Correo electrónico',
                          hint: 'usuario@mydent.com',
                          icon: Icons.mail_outline,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 22),
                        CustomTextField(
                          label: 'Contraseña',
                          hint: '••••••••',
                          icon: Icons.visibility_off_outlined,
                          controller: _passwordController,
                          obscureText: true,
                        ),
                        const SizedBox(height: 34),
                        PrimaryButton(
                          text: 'Registrarse  →',
                          onPressed: _register,
                        ),
                        const SizedBox(height: 30),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                            children: [
                              const TextSpan(text: '¿Ya tienes una cuenta? '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/login',
                                    );
                                  },
                                  child: Text(
                                    'Inicia sesión',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF0A6C99),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
