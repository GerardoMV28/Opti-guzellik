import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/input_validation.dart';
import '../utils/auth_storage.dart';
import '../services/auth_service.dart';
import 'admin/dashboard_admin.dart';
import 'empleado/dashboard_empleado.dart';  // ✅ Agregar esta importación

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  List<String> _correosRecientes = [];

  @override
  void initState() {
    super.initState();
    _cargarCorreosRecientes();
  }

  Future<void> _cargarCorreosRecientes() async {
    final correos = await AuthStorage.getRecentEmails();
    if (!mounted) return;
    setState(() {
      _correosRecientes = correos;
      if (correos.isNotEmpty && _emailController.text.isEmpty) {
        _emailController.text = correos.first;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.azulMarino.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/Guzellik.jpeg',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.visibility,
                          size: 60,
                          color: AppColors.azulReal,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 40),
                  
                  // Título
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.white, AppColors.turquesa.withOpacity(0.8)],
                    ).createShader(bounds),
                    child: Text(
                      'Óptica Güzellik',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: AppColors.azulMarino.withOpacity(0.5),
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sistema de Punto de Venta',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 40),
                  
                  // Tarjeta de login
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.azulMarino.withOpacity(0.2),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.turquesa.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Campo Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Correo Electrónico',
                            labelStyle: TextStyle(color: AppColors.azulCobalto),
                            prefixIcon: Icon(Icons.email, color: AppColors.azulCobalto),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.azulCobalto.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.turquesa, width: 2),
                            ),
                          ),
                          validator: InputValidators.email,
                        ),
                        if (_correosRecientes.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: _correosRecientes.map((correo) {
                                return ActionChip(
                                  label: Text(
                                    correo,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  avatar: Icon(Icons.history, size: 16, color: AppColors.azulCobalto),
                                  backgroundColor: AppColors.azulCobalto.withOpacity(0.08),
                                  onPressed: () {
                                    setState(() {
                                      _emailController.text = correo;
                                      _emailController.selection = TextSelection.fromPosition(
                                        TextPosition(offset: correo.length),
                                      );
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                        SizedBox(height: 16),

                        // Campo Contraseña
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle: TextStyle(color: AppColors.azulCobalto),
                            prefixIcon: Icon(Icons.lock, color: AppColors.azulCobalto),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: AppColors.azulCobalto,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.azulCobalto.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.turquesa, width: 2),
                            ),
                          ),
                          validator: InputValidators.passwordLogin,
                        ),
                        SizedBox(height: 8),
                        
                        // Olvidé contraseña
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: Text('¿Olvidaste tu contraseña?'),
                                  content: Text(
                                    'Por seguridad, el restablecimiento de contraseña '
                                    'lo debe realizar un administrador desde el panel '
                                    'de Empleados de la óptica.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: Text('Entendido'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color: AppColors.azulCobalto,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        // Botón de login
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: AppColors.buttonGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.turquesa.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'INICIAR SESIÓN',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final result = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success']) {
        await AuthStorage.addRecentEmail(_emailController.text.trim());

        final user = result['user'];
        final nombreUsuario = user != null ? user['nombre'] : 'Usuario';
        final rolUsuario = user != null ? user['rol'] : 'sin_rol';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenido $nombreUsuario!'),
            backgroundColor: AppColors.turquesa,
            duration: Duration(seconds: 2),
          ),
        );
        
        // ✅ Redirigir según el rol
        if (rolUsuario == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminDashboard()),
          );
        } else {
          // ✅ Redirigir al dashboard de empleado (corregido)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => EmpleadoDashboard()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error al iniciar sesión'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}