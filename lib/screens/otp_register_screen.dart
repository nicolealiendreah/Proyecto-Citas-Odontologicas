import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/app_colors.dart';
import '../core/mobile_frame.dart';
import '../widgets/auth_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class OtpRegisterScreen extends StatefulWidget {
  final String verificationId;
  final String phone;

  const OtpRegisterScreen({
    super.key,
    required this.verificationId,
    required this.phone,
  });

  @override
  State<OtpRegisterScreen> createState() => _OtpRegisterScreenState();
}

class _OtpRegisterScreenState extends State<OtpRegisterScreen> {
  final _codeController = TextEditingController();

  bool isLoading = false;
  String? errorText;

  Future<void> _verifyCode() async {
    final smsCode = _codeController.text.trim();

    if (smsCode.isEmpty) {
      setState(() {
        errorText = 'Ingresa el código de verificación.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      if (user == null) {
        setState(() {
          isLoading = false;
          errorText = 'No se pudo registrar el usuario.';
        });
        return;
      }

      await _saveUserIfNotExists(user);

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorText = e.message ?? 'Código incorrecto.';
      });
    } catch (e) {
      setState(() {
        errorText = 'Error real: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUserIfNotExists(User user) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      await userRef.set({
        'uid': user.uid,
        'phone': widget.phone,
        'role': 'paciente',
        'createdAt': FieldValue.serverTimestamp(),

        // Para el flujo simulado del carnet
        'carnetVerified': false,
        'profileCompleted': false,
        'carnetFrontUploaded': false,
        'carnetBackUploaded': false,
      });
    } else {
      await userRef.update({
        'phone': widget.phone,
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
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
                          'VERIFICAR TELÉFONO',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Enviamos un código SMS a ${widget.phone}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 30),

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
                          label: 'Código SMS',
                          hint: 'Ej. 123456',
                          icon: Icons.sms_outlined,
                          controller: _codeController,
                        ),

                        const SizedBox(height: 34),

                        PrimaryButton(
                          text: isLoading
                              ? 'Verificando...'
                              : 'Verificar código  →',
                          onPressed: isLoading ? () {} : _verifyCode,
                        ),

                        const SizedBox(height: 22),

                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          child: Text(
                            'Cambiar número de teléfono',
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
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
