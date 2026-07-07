import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final String? Function(T?)? validator;
  final IconData? icon;

  const CustomDropdown({
    Key? key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    this.validator,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.azulReal,
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonFormField<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              validator: validator,
              decoration: InputDecoration(
                prefixIcon: icon != null
                    ? Icon(icon, color: AppColors.azulCobalto, size: 20)
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              dropdownColor: Colors.white,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.azulCobalto),
            ),
          ),
        ],
      ),
    );
  }
}