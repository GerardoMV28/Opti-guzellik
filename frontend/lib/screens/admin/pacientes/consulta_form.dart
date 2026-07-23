import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../services/paciente_service.dart';
import '../../../widgets/forms/index.dart';
import '../../../widgets/pacientes/agudeza_visual_widget.dart';

class ConsultaForm extends StatefulWidget {
  final String pacienteId;

  ConsultaForm({required this.pacienteId});

  @override
  _ConsultaFormState createState() => _ConsultaFormState();
}

class _ConsultaFormState extends State<ConsultaForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores básicos
  final _motivoController = TextEditingController();
  final _movimientosOcularesController = TextEditingController();
  final _retinoscopiaController = TextEditingController();
  final _diagnosticoController = TextEditingController();
  final _recomendacionesController = TextEditingController();
  final _notasController = TextEditingController();
  
  // Datos de agudeza visual
  Map<String, dynamic> _agudezaVisual = {
    'sin_lentes': {'od': '20/20', 'oi': '20/20', 'ao': '20/20'},
    'con_lentes': {'od': '20/20', 'oi': '20/20', 'ao': '20/20'},
    'estenopeica': {'od': '20/20', 'oi': '20/20'},
  };

  // Datos de queratometría
  final _queratometriaODController = TextEditingController();
  final _queratometriaOIController = TextEditingController();

  // Datos de graduación
  final _odEsferaController = TextEditingController();
  final _odCilindroController = TextEditingController();
  final _odEjeController = TextEditingController();
  final _odAdicionController = TextEditingController();
  final _odDipController = TextEditingController();
  
  final _oiEsferaController = TextEditingController();
  final _oiCilindroController = TextEditingController();
  final _oiEjeController = TextEditingController();
  final _oiAdicionController = TextEditingController();
  final _oiDipController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _motivoController.dispose();
    _movimientosOcularesController.dispose();
    _retinoscopiaController.dispose();
    _diagnosticoController.dispose();
    _recomendacionesController.dispose();
    _notasController.dispose();
    _queratometriaODController.dispose();
    _queratometriaOIController.dispose();
    _odEsferaController.dispose();
    _odCilindroController.dispose();
    _odEjeController.dispose();
    _odAdicionController.dispose();
    _odDipController.dispose();
    _oiEsferaController.dispose();
    _oiCilindroController.dispose();
    _oiEjeController.dispose();
    _oiAdicionController.dispose();
    _oiDipController.dispose();
    super.dispose();
  }

  Future<void> _guardarConsulta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final consultaData = {
        'fecha': DateTime.now().toIso8601String(),
        'especialista': 'Dr. Charly', // TODO: Obtener del usuario logueado
        'motivo_consulta': _motivoController.text.trim(),
        'agudeza_visual': _agudezaVisual,
        'movimientos_oculares': _movimientosOcularesController.text.trim(),
        'retinoscopia': _retinoscopiaController.text.trim(),
        'queratometria': {
          'od': _queratometriaODController.text.trim(),
          'oi': _queratometriaOIController.text.trim(),
        },
        'graduacion_final': {
          'od': {
            'esfera': _odEsferaController.text.trim(),
            'cilindro': _odCilindroController.text.trim(),
            'eje': _odEjeController.text.trim(),
            'adicion': _odAdicionController.text.trim(),
            'dip': _odDipController.text.trim(),
          },
          'oi': {
            'esfera': _oiEsferaController.text.trim(),
            'cilindro': _oiCilindroController.text.trim(),
            'eje': _oiEjeController.text.trim(),
            'adicion': _oiAdicionController.text.trim(),
            'dip': _oiDipController.text.trim(),
          },
        },
        'diagnostico': _diagnosticoController.text.trim(),
        'recomendaciones': _recomendacionesController.text.trim(),
        'notas_adicionales': _notasController.text.trim(),
        'productos_recetados': [], // Se llenará después desde el POS
      };

      
      await PacienteService.addConsulta(widget.pacienteId, consultaData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Consulta guardada correctamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
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
          'Nueva Consulta',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
        titleSpacing: 20,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Motivo de consulta
              FormCard(
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _motivoController,
                      label: 'Motivo de consulta',
                      prefixIcon: Icons.chat_outlined,
                      maxLines: 3,
                      validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),

              // Agudeza Visual
              FormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agudeza Visual',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulReal,
                      ),
                    ),
                    SizedBox(height: 16),
                    AgudezaVisualWidget(
                      onChanged: (values) {
                        setState(() {
                          _agudezaVisual = values;
                        });
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Exámenes
              FormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exámenes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulReal,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Movimientos oculares
                    CustomTextField(
                      controller: _movimientosOcularesController,
                      label: 'Movimientos oculares',
                      prefixIcon: Icons.remove_red_eye_outlined,
                      maxLines: 2,
                    ),

                    // Retinoscopia
                    CustomTextField(
                      controller: _retinoscopiaController,
                      label: 'Retinoscopia',
                      prefixIcon: Icons.science_outlined,
                      maxLines: 2,
                    ),

                    // Queratometría
                    Text(
                      'Queratometría',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _queratometriaODController,
                            label: 'OD',
                            hintText: 'Ej: 42.50/43.00',
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _queratometriaOIController,
                            label: 'OI',
                            hintText: 'Ej: 42.75/43.25',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Graduación Final
              FormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Graduación Final',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulReal,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Ojo Derecho
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ojo Derecho (OD)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.azulCobalto,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _odEsferaController,
                                  label: 'Esfera',
                                  hintText: 'Ej: -2.00',
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: CustomTextField(
                                  controller: _odCilindroController,
                                  label: 'Cilindro',
                                  hintText: 'Ej: -0.75',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _odEjeController,
                                  label: 'Eje',
                                  hintText: 'Ej: 180',
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: CustomTextField(
                                  controller: _odAdicionController,
                                  label: 'Adición',
                                  hintText: 'Ej: +2.00',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          CustomTextField(
                            controller: _odDipController,
                            label: 'DIP (Distancia Interpupilar)',
                            hintText: 'Ej: 64',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Ojo Izquierdo
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ojo Izquierdo (OI)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.azulCobalto,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _oiEsferaController,
                                  label: 'Esfera',
                                  hintText: 'Ej: -2.25',
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: CustomTextField(
                                  controller: _oiCilindroController,
                                  label: 'Cilindro',
                                  hintText: 'Ej: -0.50',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _oiEjeController,
                                  label: 'Eje',
                                  hintText: 'Ej: 175',
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: CustomTextField(
                                  controller: _oiAdicionController,
                                  label: 'Adición',
                                  hintText: 'Ej: +2.00',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          CustomTextField(
                            controller: _oiDipController,
                            label: 'DIP (Distancia Interpupilar)',
                            hintText: 'Ej: 64',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Diagnóstico y Recomendaciones
              FormCard(
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _diagnosticoController,
                      label: 'Diagnóstico',
                      prefixIcon: Icons.assignment_outlined,
                      maxLines: 2,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: _recomendacionesController,
                      label: 'Recomendaciones',
                      prefixIcon: Icons.lightbulb_outline,
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: _notasController,
                      label: 'Notas adicionales',
                      prefixIcon: Icons.note_outlined,
                      maxLines: 3,
                    ),
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
                      text: 'Guardar Consulta',
                      onPressed: _guardarConsulta,
                      isLoading: _isLoading,
                      icon: Icons.save,
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