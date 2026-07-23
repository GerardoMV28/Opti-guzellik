import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/forms/index.dart';

class ConfiguracionScreen extends StatefulWidget {
  @override
  _ConfiguracionScreenState createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordActualController = TextEditingController();
  final _passwordNuevaController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();

  bool _obscureActual = true;
  bool _obscureNueva = true;
  bool _obscureConfirmar = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordActualController.dispose();
    _passwordNuevaController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  String? _validarPasswordNueva(String? value) {
    if (value == null || value.isEmpty) {
      return 'La nueva contraseña es requerida';
    }
    if (value.length < 8) {
      return 'Mínimo 8 caracteres';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'Debe incluir al menos una letra';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Debe incluir al menos un número';
    }
    return null;
  }

  void _mostrarMensaje(String mensaje, bool esExito) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esExito ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _cambiarPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final resultado = await AuthService.changePassword(
      _passwordActualController.text,
      _passwordNuevaController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (resultado['success'] == true) {
      _passwordActualController.clear();
      _passwordNuevaController.clear();
      _confirmarPasswordController.clear();
      _mostrarMensaje('Contraseña actualizada correctamente', true);
    } else {
      _mostrarMensaje(resultado['message'] ?? 'No se pudo cambiar la contraseña', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cambiar mi contraseña',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.azulReal,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Actualiza la contraseña con la que inicias sesión.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordActualController,
                    label: 'Contraseña actual',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _obscureActual
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onSuffixTap: () => setState(() => _obscureActual = !_obscureActual),
                    obscureText: _obscureActual,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu contraseña actual';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  CustomTextField(
                    controller: _passwordNuevaController,
                    label: 'Nueva contraseña',
                    prefixIcon: Icons.lock_reset,
                    suffixIcon: _obscureNueva
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onSuffixTap: () => setState(() => _obscureNueva = !_obscureNueva),
                    obscureText: _obscureNueva,
                    validator: _validarPasswordNueva,
                  ),
                  SizedBox(height: 12),
                  CustomTextField(
                    controller: _confirmarPasswordController,
                    label: 'Confirmar nueva contraseña',
                    prefixIcon: Icons.lock_reset,
                    suffixIcon: _obscureConfirmar
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onSuffixTap: () => setState(() => _obscureConfirmar = !_obscureConfirmar),
                    obscureText: _obscureConfirmar,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirma la nueva contraseña';
                      }
                      if (value != _passwordNuevaController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  CustomButton(
                    text: 'Actualizar contraseña',
                    onPressed: _cambiarPassword,
                    isLoading: _isLoading,
                    icon: Icons.check,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
