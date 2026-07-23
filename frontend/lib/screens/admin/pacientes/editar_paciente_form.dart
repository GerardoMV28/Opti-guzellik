import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../services/paciente_service.dart';
import '../../../models/pacientes/paciente_model.dart';
import '../../../widgets/forms/index.dart';

class EditarPacienteForm extends StatefulWidget {
  final Paciente paciente;

  const EditarPacienteForm({Key? key, required this.paciente}) : super(key: key);

  @override
  _EditarPacienteFormState createState() => _EditarPacienteFormState();
}

class _EditarPacienteFormState extends State<EditarPacienteForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _observacionesController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.paciente.nombre);
    _telefonoController = TextEditingController(text: widget.paciente.telefono);
    _observacionesController = TextEditingController(text: widget.paciente.observaciones);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await PacienteService.updatePaciente(widget.paciente.id, {
        'nombre': _nombreController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'observaciones': _observacionesController.text.trim(),
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: Text('Editar Paciente'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
                      text: 'Guardar cambios',
                      onPressed: _guardar,
                      isLoading: _isLoading,
                      icon: Icons.check,
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