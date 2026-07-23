import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class FormCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const FormCard({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.azulMarino.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(28),
        child: child,
      ),
    );
  }
}