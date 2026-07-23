// lib/screens/empleado/clientes/registro_cliente_empleado.dart
import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../services/paciente_service.dart';
import '../../../widgets/forms/index.dart';
import '../../admin/pacientes/consulta_adulto_form.dart';
import '../../admin/pacientes/consulta_infante_form.dart';

class RegistroClienteEmpleado extends StatefulWidget {
  @override
  _RegistroClienteEmpleadoState createState() => _RegistroClienteEmpleadoState();
}

class _RegistroClienteEmpleadoState extends State<RegistroClienteEmpleado> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Variables para selección
  String? _tipoPaciente; // 'adulto' o 'infante'
  
  // Datos del paciente (simplificados)
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();  
  final _observacionesController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _guardarTodo() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tipoPaciente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecciona el tipo de paciente'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Crear el paciente
      final pacienteData = {
        'nombre': _nombreController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'observaciones': _observacionesController.text.trim(),
      };

      final nuevoPaciente = await PacienteService.createPaciente(pacienteData);
      
      // 2. Navegar al formulario de consulta correspondiente
      if (_tipoPaciente == 'adulto') {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConsultaAdultoForm(pacienteId: nuevoPaciente.id),
          ),
        );
        if (result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cliente y consulta creados correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConsultaInfanteForm(pacienteId: nuevoPaciente.id),
          ),
        );
        if (result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cliente y consulta creados correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      }
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppColors.appBarGradient)),
        foregroundColor: Colors.white,
        title: Text(
          'Registrar Cliente',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Tipo de paciente (primera decisión)
              FormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo de Paciente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulReal,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _tipoPaciente = 'adulto';
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _tipoPaciente == 'adulto'
                                    ? AppColors.turquesa
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _tipoPaciente == 'adulto'
                                      ? AppColors.turquesa
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: _tipoPaciente == 'adulto'
                                        ? Colors.white
                                        : Colors.grey[700],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'ADULTO',
                                    style: TextStyle(
                                      color: _tipoPaciente == 'adulto'
                                          ? Colors.white
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _tipoPaciente = 'infante';
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _tipoPaciente == 'infante'
                                    ? AppColors.turquesa
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _tipoPaciente == 'infante'
                                      ? AppColors.turquesa
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.child_care,
                                    color: _tipoPaciente == 'infante'
                                        ? Colors.white
                                        : Colors.grey[700],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'INFANTE',
                                    style: TextStyle(
                                      color: _tipoPaciente == 'infante'
                                          ? Colors.white
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Datos del paciente
              FormCard(
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nombreController,
                      label: 'Nombre completo',
                      prefixIcon: Icons.person_outline,
                      validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: _telefonoController,
                      label: 'Teléfono',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: _observacionesController,
                      label: 'Observaciones',
                      prefixIcon: Icons.note_outlined,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              Text(
                'Al continuar, se registrará al cliente y se abrirá el formulario de consulta correspondiente',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
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
                      text: 'Continuar',
                      onPressed: _guardarTodo,
                      isLoading: _isLoading,
                      icon: Icons.arrow_forward,
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