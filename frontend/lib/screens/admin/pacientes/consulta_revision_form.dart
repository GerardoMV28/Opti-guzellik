import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../services/paciente_service.dart';
import '../../../widgets/forms/index.dart';
import '../../../widgets/pacientes/agudeza_visual_widget.dart';

class ConsultaRevisionForm extends StatefulWidget {
  final String pacienteId;
  final String tipoPaciente; // 'adulto' o 'infante'

  ConsultaRevisionForm({
    required this.pacienteId,
    required this.tipoPaciente,
  });

  @override
  _ConsultaRevisionFormState createState() => _ConsultaRevisionFormState();
}

class _ConsultaRevisionFormState extends State<ConsultaRevisionForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores
  final _motivoController = TextEditingController();
  
  // Agudeza visual
  Map<String, dynamic> _agudezaVisual = {
    'sin_lentes': {'od': '20/20', 'oi': '20/20', 'ao': '20/20'},
    'con_lentes': {'od': '20/20', 'oi': '20/20', 'ao': '20/20'},
    'estenopeica': {'od': '20/20', 'oi': '20/20'},
  };

  // RX Final
  final _rxFinalODEsf = TextEditingController();
  final _rxFinalODCil = TextEditingController();
  final _rxFinalODEje = TextEditingController();
  final _rxFinalODAdd = TextEditingController();
  final _rxFinalODAV = TextEditingController();
  final _rxFinalODDNP = TextEditingController();

  final _rxFinalOIEsf = TextEditingController();
  final _rxFinalOICil = TextEditingController();
  final _rxFinalOIEje = TextEditingController();
  final _rxFinalOIAdd = TextEditingController();
  final _rxFinalOIAV = TextEditingController();
  final _rxFinalOIDNP = TextEditingController();

  @override
  void dispose() {
    _motivoController.dispose();
    _rxFinalODEsf.dispose();
    _rxFinalODCil.dispose();
    _rxFinalODEje.dispose();
    _rxFinalODAdd.dispose();
    _rxFinalODAV.dispose();
    _rxFinalODDNP.dispose();
    _rxFinalOIEsf.dispose();
    _rxFinalOICil.dispose();
    _rxFinalOIEje.dispose();
    _rxFinalOIAdd.dispose();
    _rxFinalOIAV.dispose();
    _rxFinalOIDNP.dispose();
    super.dispose();
  }

  Future<void> _guardarRevision() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final consultaData = {
        'fecha': DateTime.now().toIso8601String(),
        'especialista': 'Dr. Charly',
        'tipoPaciente': widget.tipoPaciente,
        'esRevision': true, // Marcador para identificar que es revisión
        
        // Solo estos 3 campos
        'motivoConsulta': _motivoController.text.trim(),
        'agudezaVisual': _agudezaVisual,
        'rxFinal': {
          'od': {
            'esf': _rxFinalODEsf.text.trim(),
            'cil': _rxFinalODCil.text.trim(),
            'eje': _rxFinalODEje.text.trim(),
            'add': _rxFinalODAdd.text.trim(),
            'av': _rxFinalODAV.text.trim(),
            'dnp': _rxFinalODDNP.text.trim(),
          },
          'oi': {
            'esf': _rxFinalOIEsf.text.trim(),
            'cil': _rxFinalOICil.text.trim(),
            'eje': _rxFinalOIEje.text.trim(),
            'add': _rxFinalOIAdd.text.trim(),
            'av': _rxFinalOIAV.text.trim(),
            'dnp': _rxFinalOIDNP.text.trim(),
          },
        },
      };

      await PacienteService.addConsulta(widget.pacienteId, consultaData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Revisión guardada correctamente'),
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
          'Revisión - ${widget.tipoPaciente == 'adulto' ? 'Adulto' : 'Infantil'}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Motivo de consulta
              FormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Motivo de consulta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulReal,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _motivoController,
                      decoration: InputDecoration(
                        hintText: '¿Por qué viene a revisión?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Agudeza Visual
              FormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agudeza Visual',
                      style: TextStyle(
                        fontSize: 16,
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

              SizedBox(height: 16),

              // RX Final
              FormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RX Final (Nueva Graduación)',
                      style: TextStyle(
                        fontSize: 16,
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
                          Text('OD', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _buildInputField(_rxFinalODEsf, 'Esf')),
                              SizedBox(width: 4),
                              Expanded(child: _buildInputField(_rxFinalODCil, 'Cil')),
                              SizedBox(width: 4),
                              Expanded(child: _buildInputField(_rxFinalODEje, 'Eje')),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(child: _buildInputField(_rxFinalODAdd, 'Add')),
                              SizedBox(width: 4),
                              Expanded(child: _buildInputField(_rxFinalODAV, 'AV')),
                              SizedBox(width: 4),
                              Expanded(child: _buildInputField(_rxFinalODDNP, 'DNP')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
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
                          Text('OI', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _buildInputField(_rxFinalOIEsf, 'Esf')),
                              SizedBox(width: 4),
                              Expanded(child: _buildInputField(_rxFinalOICil, 'Cil')),
                              SizedBox(width: 4),
                              Expanded(child: _buildInputField(_rxFinalOIEje, 'Eje')),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(child: _buildInputField(_rxFinalOIAdd, 'Add')),
                              SizedBox(width: 4),
                              Expanded(child: _buildInputField(_rxFinalOIAV, 'AV')),
                              SizedBox(width: 4),
                              Expanded(child: _buildInputField(_rxFinalOIDNP, 'DNP')),
                            ],
                          ),
                        ],
                      ),
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
                      text: 'Guardar Revisión',
                      onPressed: _guardarRevision,
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

  Widget _buildInputField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      textAlign: TextAlign.center,
    );
  }
}