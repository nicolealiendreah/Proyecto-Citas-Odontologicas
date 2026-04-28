import 'package:flutter/material.dart';

class MobileFrame extends StatelessWidget {
  final Widget child;

  const MobileFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;

        if (!isWide) return child;

        return Container(
          color: const Color(0xFFDDE5EB),
          alignment: Alignment.center,
          child: Container(
            width: 390,
            height: 844,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(35, 0, 0, 0),
                  blurRadius: 30,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
    );
  }
}
