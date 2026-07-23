import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../services/empleado_service.dart';
import '../../models/empleado.dart';
import '../../widgets/forms/index.dart';

class EmpleadoForm extends StatefulWidget {
  final Empleado? empleado;

  EmpleadoForm({this.empleado});

  @override
  _EmpleadoFormState createState() => _EmpleadoFormState();
}

class _EmpleadoFormState extends State<EmpleadoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _telefonoController = TextEditingController();

  String _rolSeleccionado = 'empleado';
  bool _isLoading = false;
  bool _isEditing = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _restablecerPassword = false;

  String? _validarPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
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

  @override
  void initState() {
    super.initState();
    if (widget.empleado != null) {
      _isEditing = true;
      _nombreController.text = widget.empleado!.nombre;
      _emailController.text = widget.empleado!.email;
      _telefonoController.text = widget.empleado!.telefono;
      _rolSeleccionado = widget.empleado!.rol;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _guardarEmpleado() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final empleadoData = {
        'nombre': _nombreController.text.trim(),
        'email': _emailController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'rol': _rolSeleccionado,
      };

      if (!_isEditing) {
        empleadoData['password'] = _passwordController.text.trim();
      } else if (_restablecerPassword) {
        empleadoData['password'] = _passwordController.text.trim();
      }

      if (_isEditing) {
        await EmpleadoService.updateEmpleado(widget.empleado!.id, empleadoData);
        _mostrarMensaje('Empleado actualizado correctamente', true);
      } else {
        await EmpleadoService.createEmpleado(empleadoData);
        _mostrarMensaje('Empleado creado correctamente', true);
      }

      Navigator.pop(context, true);
    } catch (e) {
      _mostrarMensaje('Error: $e', false);
    } finally {
      setState(() => _isLoading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppColors.appBarGradient)),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'Editar Empleado' : 'Nuevo Empleado',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 2),
            Text(
              _isEditing
                  ? 'Modifica los datos del empleado'
                  : 'Ingresa los datos del nuevo empleado',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        centerTitle: false,
        titleSpacing: 20,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Container(
            color: Colors.grey[200],
            height: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Tarjeta del formulario
              FormCard(
                child: Column(
                  children: [
                    // Nombre completo
                    CustomTextField(
                      controller: _nombreController,
                      label: 'Nombre completo',
                      hintText: 'Ej: Juan Pérez García',
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre es requerido';
                        }
                        final palabras = value.trim().split(' ');
                        if (palabras.length < 2) {
                          return 'Ingresa al menos nombre y apellido';
                        }
                        return null;
                      },
                    ),

                    // Email
                    CustomTextField(
                      controller: _emailController,
                      label: 'Correo electrónico',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El email es requerido';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Ingresa un email válido';
                        }
                        return null;
                      },
                    ),

                    // Teléfono
                    CustomTextField(
                      controller: _telefonoController,
                      label: 'Teléfono',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    // Rol
                    CustomDropdown<String>(
                      value: _rolSeleccionado,
                      label: 'Rol',
                      icon: Icons.admin_panel_settings_outlined,
                      items: [
                        DropdownMenuItem(
                          value: 'admin',
                          child: Row(
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                color: AppColors.azulReal,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text('Administrador'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'empleado',
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: AppColors.azulCobalto,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text('Empleado'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _rolSeleccionado = value!;
                        });
                      },
                    ),

                    // Campos de contraseña (solo para nuevo empleado)
                    if (!_isEditing) ...[
                      SizedBox(height: 16),
                      Divider(),
                      SizedBox(height: 8),

                      // Contraseña
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Contraseña',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onSuffixTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        obscureText: _obscurePassword,
                        validator: _validarPassword,
                      ),

                      // Confirmar contraseña
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirmar contraseña',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onSuffixTap: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirma tu contraseña';
                          }
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                    ],

                    // Restablecer contraseña (solo al editar)
                    if (_isEditing) ...[
                      SizedBox(height: 16),
                      Divider(),
                      SizedBox(height: 8),
                      CheckboxListTile(
                        value: _restablecerPassword,
                        onChanged: (value) {
                          setState(() {
                            _restablecerPassword = value ?? false;
                            if (!_restablecerPassword) {
                              _passwordController.clear();
                              _confirmPasswordController.clear();
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Restablecer contraseña',
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                        subtitle: Text(
                          'Úsalo si el empleado olvidó su contraseña de acceso',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                      if (_restablecerPassword) ...[
                        SizedBox(height: 8),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Nueva contraseña',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          onSuffixTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          obscureText: _obscurePassword,
                          validator: _restablecerPassword ? _validarPassword : null,
                        ),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirmar nueva contraseña',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          onSuffixTap: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if (!_restablecerPassword) return null;
                            if (value == null || value.isEmpty) {
                              return 'Confirma la nueva contraseña';
                            }
                            if (value != _passwordController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancelar',
                      onPressed: () => Navigator.pop(context),
                      isOutlined: true,
                      color: AppColors.azulCobalto,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: _isEditing ? 'Actualizar' : 'Guardar',
                      onPressed: _guardarEmpleado,
                      isLoading: _isLoading,
                      icon: _isEditing ? Icons.update : Icons.save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}