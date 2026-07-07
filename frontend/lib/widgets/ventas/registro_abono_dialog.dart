import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../services/venta_service.dart';
import '../forms/index.dart';
import 'package:intl/intl.dart';

class RegistroAbonoDialog extends StatefulWidget {
  final String ventaId;
  final double saldoPendiente;
  final Function onAbonoRegistrado;

  const RegistroAbonoDialog({
    Key? key,
    required this.ventaId,
    required this.saldoPendiente,
    required this.onAbonoRegistrado,
  }) : super(key: key);

  @override
  _RegistroAbonoDialogState createState() => _RegistroAbonoDialogState();
}

class _RegistroAbonoDialogState extends State<RegistroAbonoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _notaController = TextEditingController();
  String _formaPago = 'efectivo';
  bool _isLoading = false;

  final NumberFormat _moneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  void dispose() {
    _montoController.dispose();
    _notaController.dispose();
    super.dispose();
  }

  Future<void> _registrarAbono() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final monto = double.parse(_montoController.text);
      
      if (monto > widget.saldoPendiente) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El monto no puede exceder el saldo pendiente'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      await VentaService.registrarAbono(
        widget.ventaId,
        monto,
        _formaPago,
        _notaController.text.trim(),
      );

      widget.onAbonoRegistrado();
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Abono registrado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.payments, color: AppColors.turquesa),
          SizedBox(width: 8),
          Text('Registrar Abono'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Saldo pendiente:'),
                  Text(
                    _moneda.format(widget.saldoPendiente),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _montoController,
              label: 'Monto del abono',
              prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Requerido';
                final monto = double.tryParse(value);
                if (monto == null || monto <= 0) return 'Monto inválido';
                return null;
              },
            ),
            SizedBox(height: 16),
            CustomDropdown<String>(
              value: _formaPago,
              label: 'Forma de pago',
              icon: Icons.payment,
              items: [
                DropdownMenuItem(value: 'efectivo', child: Text('Efectivo')),
                DropdownMenuItem(value: 'tarjeta', child: Text('Tarjeta')),
                DropdownMenuItem(value: 'transferencia', child: Text('Transferencia')),
              ],
              onChanged: (value) {
                setState(() {
                  _formaPago = value!;
                });
              },
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _notaController,
              label: 'Nota (opcional)',
              prefixIcon: Icons.note_outlined,
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _registrarAbono,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.turquesa,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Registrar Abono'),
        ),
      ],
    );
  }
}