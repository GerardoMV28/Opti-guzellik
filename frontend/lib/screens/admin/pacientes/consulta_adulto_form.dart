import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../services/paciente_service.dart';
import '../../../widgets/forms/index.dart';

class ConsultaAdultoForm extends StatefulWidget {
  final String pacienteId;

  ConsultaAdultoForm({required this.pacienteId});

  @override
  _ConsultaAdultoFormState createState() => _ConsultaAdultoFormState();
}

class _ConsultaAdultoFormState extends State<ConsultaAdultoForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores básicos
  final _motivoController = TextEditingController();
  final _movimientosOcularesController = TextEditingController();
  final _diagnosticoController = TextEditingController();
  final _recomendacionesController = TextEditingController();
  final _notasController = TextEditingController();
  final _sinLentesOD = TextEditingController();
  final _sinLentesOI = TextEditingController();
  final _sinLentesAO = TextEditingController();
  final _conLentesOD = TextEditingController();
  final _conLentesOI = TextEditingController();
  final _conLentesAO = TextEditingController();
  final _estenopeicaOD = TextEditingController();
  final _estenopeicaOI = TextEditingController();

  // Controladores para checkboxes de síntomas
  Map<String, bool> sintomas = {
    'enrojecimiento': false,
    'dificultadNoche': false,
    'comezon': false,
    'molestiaSol': false,
    'sensibilidadLuzArtificial': false,
    'lagrimeo': false,
    'malEnfoqueLejos': false,
    'malEnfoqueCerca': false,
    'molestiasComputadora': false,
    'lagana': false,
  };
  final _otrosSintomasController = TextEditingController();

  // Controladores para antecedentes
  Map<String, bool> antecedentes = {
    'alergias': false,
    'lenteOftalmico': false,
    'lenteContacto': false,
    'diabetico': false,
    'hipertension': false,
    'hipotension': false,
    'tiroides': false,
  };
  final _especificacionAlergiasController = TextEditingController();
  final _ultimaValoracionController = TextEditingController();

  // Controladores para tablas
  // AV Tabla
  final _avLejanaOD = TextEditingController();
  final _avLejanaOI = TextEditingController();
  final _avCercaOD = TextEditingController();
  final _avCercaOI = TextEditingController();
  final _avOtro = TextEditingController();

  // RX Anterior
  final _rxAntODEsf = TextEditingController();
  final _rxAntODCil = TextEditingController();
  final _rxAntODEje = TextEditingController();
  final _rxAntODAdd = TextEditingController();
  final _rxAntODAV = TextEditingController();

  final _rxAntOIEsf = TextEditingController();
  final _rxAntOICil = TextEditingController();
  final _rxAntOIEje = TextEditingController();
  final _rxAntOIAdd = TextEditingController();
  final _rxAntOIAV = TextEditingController();

  // Cover Test
  final _coverTestLejos = TextEditingController();
  final _coverTestCerca = TextEditingController();

  // Salud Ocular
  final _saludOcularOD = TextEditingController();
  final _saludOcularOI = TextEditingController();

  // Oftalmoscopía
  final _oftalmoscopiaOD = TextEditingController();
  final _oftalmoscopiaOI = TextEditingController();

  // Subjetivo
  final _subjetivoODEsf = TextEditingController();
  final _subjetivoODCil = TextEditingController();
  final _subjetivoODEje = TextEditingController();
  final _subjetivoODAdd = TextEditingController();
  final _subjetivoODAV = TextEditingController();

  final _subjetivoOIEsf = TextEditingController();
  final _subjetivoOICil = TextEditingController();
  final _subjetivoOIEje = TextEditingController();
  final _subjetivoOIAdd = TextEditingController();
  final _subjetivoOIAV = TextEditingController();

  // DNP y Altura
  final _dnpOD = TextEditingController();
  final _dnpOI = TextEditingController();
  final _alturaOD = TextEditingController();
  final _alturaOI = TextEditingController();

  // Puntos de Worth
  final _puntosWorth = TextEditingController();

  // RX Final
  final _rxFinalODEsf = TextEditingController();
  final _rxFinalODCil = TextEditingController();
  final _rxFinalODEje = TextEditingController();
  final _rxFinalODAdd = TextEditingController();
  final _rxFinalODAV = TextEditingController();

  final _rxFinalOIEsf = TextEditingController();
  final _rxFinalOICil = TextEditingController();
  final _rxFinalOIEje = TextEditingController();
  final _rxFinalOIAdd = TextEditingController();
  final _rxFinalOIAV = TextEditingController();

  // Control de expansión de secciones
  Map<String, bool> expandedSections = {
    'sintomas': true,
    'antecedentes': true,
    'avTabla': true,
    'rxAnterior': true,
    'coverTest': true,
    'saludOcular': true,
    'oftalmoscopia': true,
    'subjetivo': true,
    'dnpAltura': true,
    'rxFinal': true,
    'puntosWorth': true,
  };

  @override
  void dispose() {
    // Liberar todos los controladores
    _motivoController.dispose();
    _movimientosOcularesController.dispose();
    _diagnosticoController.dispose();
    _recomendacionesController.dispose();
    _notasController.dispose();
    _otrosSintomasController.dispose();
    _especificacionAlergiasController.dispose();
    _ultimaValoracionController.dispose();
    _avLejanaOD.dispose();
    _avLejanaOI.dispose();
    _avCercaOD.dispose();
    _avCercaOI.dispose();
    _avOtro.dispose();
    _rxAntODEsf.dispose();
    _rxAntODCil.dispose();
    _rxAntODEje.dispose();
    _rxAntODAdd.dispose();
    _rxAntODAV.dispose();
    _rxAntOIEsf.dispose();
    _rxAntOICil.dispose();
    _rxAntOIEje.dispose();
    _rxAntOIAdd.dispose();
    _rxAntOIAV.dispose();
    _coverTestLejos.dispose();
    _coverTestCerca.dispose();
    _saludOcularOD.dispose();
    _saludOcularOI.dispose();
    _oftalmoscopiaOD.dispose();
    _oftalmoscopiaOI.dispose();
    _subjetivoODEsf.dispose();
    _subjetivoODCil.dispose();
    _subjetivoODEje.dispose();
    _subjetivoODAdd.dispose();
    _subjetivoODAV.dispose();
    _subjetivoOIEsf.dispose();
    _subjetivoOICil.dispose();
    _subjetivoOIEje.dispose();
    _subjetivoOIAdd.dispose();
    _subjetivoOIAV.dispose();
    _dnpOD.dispose();
    _dnpOI.dispose();
    _alturaOD.dispose();
    _alturaOI.dispose();
    _puntosWorth.dispose();
    _rxFinalODEsf.dispose();
    _rxFinalODCil.dispose();
    _rxFinalODEje.dispose();
    _rxFinalODAdd.dispose();
    _rxFinalODAV.dispose();
    _rxFinalOIEsf.dispose();
    _rxFinalOICil.dispose();
    _rxFinalOIEje.dispose();
    _rxFinalOIAdd.dispose();
    _rxFinalOIAV.dispose();
    super.dispose();
  }

  Future<void> _guardarConsulta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Construir objeto de consulta
      final consultaData = {
        'fecha': DateTime.now().toIso8601String(),
        'especialista': 'Dr. Charly',
        'motivoConsulta': _motivoController.text.trim(),
        'tipoPaciente': 'adulto',

        // Síntomas
        'sintomas': {
          'enrojecimiento': sintomas['enrojecimiento'],
          'dificultadNoche': sintomas['dificultadNoche'],
          'comezon': sintomas['comezon'],
          'molestiaSol': sintomas['molestiaSol'],
          'sensibilidadLuzArtificial': sintomas['sensibilidadLuzArtificial'],
          'lagrimeo': sintomas['lagrimeo'],
          'malEnfoqueLejos': sintomas['malEnfoqueLejos'],
          'malEnfoqueCerca': sintomas['malEnfoqueCerca'],
          'molestiasComputadora': sintomas['molestiasComputadora'],
          'lagana': sintomas['lagana'],
          'otros': _otrosSintomasController.text.trim(),
        },

        // Antecedentes
        'antecedentes': {
          'alergias': antecedentes['alergias'],
          'especificacionAlergias': _especificacionAlergiasController.text
              .trim(),
          'lenteOftalmico': antecedentes['lenteOftalmico'],
          'lenteContacto': antecedentes['lenteContacto'],
          'diabetico': antecedentes['diabetico'],
          'hipertension': antecedentes['hipertension'],
          'hipotension': antecedentes['hipotension'],
          'tiroides': antecedentes['tiroides'],
          'ultimaValoracion': _ultimaValoracionController.text.trim(),
        },

        // AV Tabla - ACTUALIZADO
        'avTabla': {
          // Mantén los campos antiguos si los necesitas
          'lejana': {
            'od': _avLejanaOD.text.trim(),
            'oi': _avLejanaOI.text.trim(),
          },
          'cerca': {'od': _avCercaOD.text.trim(), 'oi': _avCercaOI.text.trim()},
          'otro': _avOtro.text.trim(),

          // AGREGAR los nuevos campos
          'sin_lentes': {
            'od': _sinLentesOD.text.trim(),
            'oi': _sinLentesOI.text.trim(),
            'ao': _sinLentesAO.text.trim(),
          },
          'con_lentes': {
            'od': _conLentesOD.text.trim(),
            'oi': _conLentesOI.text.trim(),
            'ao': _conLentesAO.text.trim(),
          },
          'estenopeica': {
            'od': _estenopeicaOD.text.trim(),
            'oi': _estenopeicaOI.text.trim(),
          },
        },

        // RX Anterior
        'rxAnterior': {
          'od': {
            'esf': _rxAntODEsf.text.trim(),
            'cil': _rxAntODCil.text.trim(),
            'eje': _rxAntODEje.text.trim(),
            'add': _rxAntODAdd.text.trim(),
            'av': _rxAntODAV.text.trim(),
          },
          'oi': {
            'esf': _rxAntOIEsf.text.trim(),
            'cil': _rxAntOICil.text.trim(),
            'eje': _rxAntOIEje.text.trim(),
            'add': _rxAntOIAdd.text.trim(),
            'av': _rxAntOIAV.text.trim(),
          },
        },

        // Cover Test
        'coverTest': {
          'lejos': _coverTestLejos.text.trim(),
          'cerca': _coverTestCerca.text.trim(),
        },

        'movimientosOculares': _movimientosOcularesController.text.trim(),

        // Salud Ocular
        'saludOcular': {
          'od': _saludOcularOD.text.trim(),
          'oi': _saludOcularOI.text.trim(),
        },

        // Oftalmoscopía
        'oftalmoscopia': {
          'od': _oftalmoscopiaOD.text.trim(),
          'oi': _oftalmoscopiaOI.text.trim(),
        },

        // Subjetivo
        'subjetivo': {
          'od': {
            'esf': _subjetivoODEsf.text.trim(),
            'cil': _subjetivoODCil.text.trim(),
            'eje': _subjetivoODEje.text.trim(),
            'add': _subjetivoODAdd.text.trim(),
            'av': _subjetivoODAV.text.trim(),
          },
          'oi': {
            'esf': _subjetivoOIEsf.text.trim(),
            'cil': _subjetivoOICil.text.trim(),
            'eje': _subjetivoOIEje.text.trim(),
            'add': _subjetivoOIAdd.text.trim(),
            'av': _subjetivoOIAV.text.trim(),
          },
        },

        // DNP y Altura
        'dnpAltura': {
          'od': {'dnp': _dnpOD.text.trim(), 'altura': _alturaOD.text.trim()},
          'oi': {'dnp': _dnpOI.text.trim(), 'altura': _alturaOI.text.trim()},
        },

        'puntosWorth': _puntosWorth.text.trim(),

        // RX Final
        'rxFinal': {
          'od': {
            'esf': _rxFinalODEsf.text.trim(),
            'cil': _rxFinalODCil.text.trim(),
            'eje': _rxFinalODEje.text.trim(),
            'add': _rxFinalODAdd.text.trim(),
            'av': _rxFinalODAV.text.trim(),
          },
          'oi': {
            'esf': _rxFinalOIEsf.text.trim(),
            'cil': _rxFinalOICil.text.trim(),
            'eje': _rxFinalOIEje.text.trim(),
            'add': _rxFinalOIAdd.text.trim(),
            'av': _rxFinalOIAV.text.trim(),
          },
        },

        // Diagnóstico y recomendaciones
        'diagnostico': _diagnosticoController.text.trim(),
        'recomendaciones': _recomendacionesController.text.trim(),
        'notasAdicionales': _notasController.text.trim(),
        'productosRecetados': [],
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
          'Nueva Consulta - Adulto',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Información Básica
              _buildSeccionBasica(),
              SizedBox(height: 16),
              // Síntomas
              _buildSeccionSintomas(),
              SizedBox(height: 16),

              // Antecedentes
              _buildSeccionAntecedentes(),
              SizedBox(height: 16),

              // AV Tabla
              _buildSeccionAVTabla(),
              SizedBox(height: 16),

              // RX Anterior
              _buildSeccionRXAnterior(),
              SizedBox(height: 16),

              // Cover Test y Movimientos Oculares
              _buildSeccionCoverTest(),
              SizedBox(height: 16),

              // Salud Ocular y Oftalmoscopía
              _buildSeccionSaludOcular(),
              SizedBox(height: 16),

              // Subjetivo
              _buildSeccionSubjetivo(),
              SizedBox(height: 16),

              // DNP y Altura
              _buildSeccionDNPAltura(),
              SizedBox(height: 16),

              // Puntos de Worth
              _buildSeccionPuntosWorth(),
              SizedBox(height: 16),

              // RX Final
              _buildSeccionRXFinal(),
              SizedBox(height: 16),

              // Diagnóstico y Recomendaciones
              _buildSeccionDiagnostico(),
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

  // SECCIÓN 1: Información Básica
  Widget _buildSeccionBasica() {
    return FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información de la Consulta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.azulReal,
            ),
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: _motivoController,
            label: 'Motivo de consulta',
            prefixIcon: Icons.chat_outlined,
            maxLines: 3,
            validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
          ),
        ],
      ),
    );
  }

  // SECCIÓN 2: Síntomas
  Widget _buildSeccionSintomas() {
    return GestureDetector(
      onTap: () {
        setState(() {
          expandedSections['sintomas'] = !expandedSections['sintomas']!;
        });
      },
      child: FormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Síntomas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulReal,
                  ),
                ),
                Icon(
                  expandedSections['sintomas']!
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.azulReal,
                ),
              ],
            ),
            if (expandedSections['sintomas']!) ...[
              SizedBox(height: 16),
              _buildSintomasGrid(),
              SizedBox(height: 16),
              CustomTextField(
                controller: _otrosSintomasController,
                label: 'Otros síntomas',
                hintText: 'Especificar otros síntomas',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSintomasGrid() {
    final List<Map<String, dynamic>> sintomasList = [
      {
        'key': 'enrojecimiento',
        'label': 'Enrojecimiento',
        'icon': Icons.water_drop,
      },
      {'key': 'dificultadNoche', 'label': 'Noche', 'icon': Icons.nightlight},
      {'key': 'comezon', 'label': 'Comezón', 'icon': Icons.healing},
      {'key': 'molestiaSol', 'label': 'Sol', 'icon': Icons.wb_sunny},
      {
        'key': 'sensibilidadLuzArtificial',
        'label': 'Luz artificial',
        'icon': Icons.lightbulb,
      },
      {'key': 'lagrimeo', 'label': 'Lagrimeo', 'icon': Icons.water},
      {
        'key': 'malEnfoqueLejos',
        'label': 'Lejos',
        'icon': Icons.visibility_off,
      },
      {'key': 'malEnfoqueCerca', 'label': 'Cerca', 'icon': Icons.visibility},
      {
        'key': 'molestiasComputadora',
        'label': 'Computadora',
        'icon': Icons.computer,
      },
      {'key': 'lagana', 'label': 'Lagaña', 'icon': Icons.science},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sintomasList.map((Map<String, dynamic> item) {
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item['icon'] as IconData,
                size: 16,
                color: sintomas[item['key'] as String]!
                    ? Colors.white
                    : AppColors.azulCobalto,
              ),
              SizedBox(width: 4),
              Text(item['label'] as String),
            ],
          ),
          selected: sintomas[item['key'] as String]!,
          onSelected: (bool selected) {
            setState(() {
              sintomas[item['key'] as String] = selected;
            });
          },
          selectedColor: AppColors.turquesa,
          checkmarkColor: Colors.white,
          backgroundColor: Colors.grey[100],
          labelStyle: TextStyle(
            color: sintomas[item['key'] as String]!
                ? Colors.white
                : Colors.black87,
            fontSize: 12,
          ),
        );
      }).toList(),
    );
  }

  // SECCIÓN 3: Antecedentes Personales
  Widget _buildSeccionAntecedentes() {
    return GestureDetector(
      onTap: () {
        setState(() {
          expandedSections['antecedentes'] = !expandedSections['antecedentes']!;
        });
      },
      child: FormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Antecedentes Personales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulReal,
                  ),
                ),
                Icon(
                  expandedSections['antecedentes']!
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.azulReal,
                ),
              ],
            ),
            if (expandedSections['antecedentes']!) ...[
              SizedBox(height: 16),
              _buildAntecedentesGrid(),
              if (antecedentes['alergias']!) ...[
                SizedBox(height: 8),
                CustomTextField(
                  controller: _especificacionAlergiasController,
                  label: 'Especificar alergias',
                ),
              ],
              SizedBox(height: 8),
              CustomTextField(
                controller: _ultimaValoracionController,
                label: 'Última valoración visual',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAntecedentesGrid() {
    final List<Map<String, dynamic>> antecedentesList = [
      {'key': 'alergias', 'label': 'Alergias', 'icon': Icons.clean_hands},
      {
        'key': 'lenteOftalmico',
        'label': 'Lente oftálmico',
        'icon': Icons.remove_red_eye,
      },
      {
        'key': 'lenteContacto',
        'label': 'Lente Contacto',
        'icon': Icons.contactless,
      },
      {'key': 'diabetico', 'label': 'Diabético', 'icon': Icons.medication},
      {
        'key': 'hipertension',
        'label': 'Hipertensión',
        'icon': Icons.favorite_border,
      },
      {'key': 'hipotension', 'label': 'Hipotensión', 'icon': Icons.favorite},
      {'key': 'tiroides', 'label': 'Tiroides', 'icon': Icons.monitor_heart},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: antecedentesList.map((Map<String, dynamic> item) {
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item['icon'] as IconData,
                size: 16,
                color: antecedentes[item['key'] as String]!
                    ? Colors.white
                    : AppColors.azulCobalto,
              ),
              SizedBox(width: 4),
              Text(item['label'] as String),
            ],
          ),
          selected: antecedentes[item['key'] as String]!,
          onSelected: (bool selected) {
            setState(() {
              antecedentes[item['key'] as String] = selected;
            });
          },
          selectedColor: AppColors.turquesa,
          checkmarkColor: Colors.white,
          backgroundColor: Colors.grey[100],
          labelStyle: TextStyle(
            color: antecedentes[item['key'] as String]!
                ? Colors.white
                : Colors.black87,
            fontSize: 12,
          ),
        );
      }).toList(),
    );
  }

  // SECCIÓN 4: AV Tabla
  // SECCIÓN 4: AV Tabla - VERSIÓN CORREGIDA
  Widget _buildSeccionAVTabla() {
    return GestureDetector(
      onTap: () {
        setState(() {
          expandedSections['avTabla'] = !expandedSections['avTabla']!;
        });
      },
      child: FormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Agudeza Visual (AV)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulReal,
                  ),
                ),
                Icon(
                  expandedSections['avTabla']!
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.azulReal,
                ),
              ],
            ),
            if (expandedSections['avTabla']!) ...[
              SizedBox(height: 16),

              // SIN LENTES
              Text('SIN LENTES', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Table(
                border: TableBorder.all(color: Colors.grey[300]!),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[100]),
                    children: [
                      _buildTableHeader(''),
                      _buildTableHeader('OD'),
                      _buildTableHeader('OI'),
                      _buildTableHeader('AO'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('Valor', isHeader: true),
                      _buildTableInput(_sinLentesOD),
                      _buildTableInput(_sinLentesOI),
                      _buildTableInput(_sinLentesAO),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 16),

              // CON LENTES
              Text('CON LENTES', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Table(
                border: TableBorder.all(color: Colors.grey[300]!),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[100]),
                    children: [
                      _buildTableHeader(''),
                      _buildTableHeader('OD'),
                      _buildTableHeader('OI'),
                      _buildTableHeader('AO'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('Valor', isHeader: true),
                      _buildTableInput(_conLentesOD),
                      _buildTableInput(_conLentesOI),
                      _buildTableInput(_conLentesAO),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 16),

              // ESTENOPEICA
              Text(
                'ESTENOPEICA',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Table(
                border: TableBorder.all(color: Colors.grey[300]!),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[100]),
                    children: [
                      _buildTableHeader(''),
                      _buildTableHeader('OD'),
                      _buildTableHeader('OI'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('Valor', isHeader: true),
                      _buildTableInput(_estenopeicaOD),
                      _buildTableInput(_estenopeicaOI),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 16),
              CustomTextField(controller: _avOtro, label: 'Observaciones AV'),
            ],
          ],
        ),
      ),
    );
  }

  // SECCIÓN 5: RX Anterior
  Widget _buildSeccionRXAnterior() {
    return GestureDetector(
      onTap: () {
        setState(() {
          expandedSections['rxAnterior'] = !expandedSections['rxAnterior']!;
        });
      },
      child: FormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RX Anterior',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulReal,
                  ),
                ),
                Icon(
                  expandedSections['rxAnterior']!
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.azulReal,
                ),
              ],
            ),
            if (expandedSections['rxAnterior']!) ...[
              SizedBox(height: 16),
              Table(
                border: TableBorder.all(color: Colors.grey[300]!),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[100]),
                    children: [
                      _buildTableHeader(''),
                      _buildTableHeader('ESF'),
                      _buildTableHeader('CIL'),
                      _buildTableHeader('EJE'),
                      _buildTableHeader('ADD'),
                      _buildTableHeader('AV'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('OD', isHeader: true),
                      _buildTableInput(_rxAntODEsf),
                      _buildTableInput(_rxAntODCil),
                      _buildTableInput(_rxAntODEje),
                      _buildTableInput(_rxAntODAdd),
                      _buildTableInput(_rxAntODAV),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('OI', isHeader: true),
                      _buildTableInput(_rxAntOIEsf),
                      _buildTableInput(_rxAntOICil),
                      _buildTableInput(_rxAntOIEje),
                      _buildTableInput(_rxAntOIAdd),
                      _buildTableInput(_rxAntOIAV),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // SECCIÓN 6: Cover Test y Movimientos Oculares
  Widget _buildSeccionCoverTest() {
    return GestureDetector(
      onTap: () {
        setState(() {
          expandedSections['coverTest'] = !expandedSections['coverTest']!;
        });
      },
      child: FormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cover Test',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulReal,
                  ),
                ),
                Icon(
                  expandedSections['coverTest']!
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.azulReal,
                ),
              ],
            ),
            if (expandedSections['coverTest']!) ...[
              SizedBox(height: 16),
              Table(
                border: TableBorder.all(color: Colors.grey[300]!),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[100]),
                    children: [
                      _buildTableHeader('LEJOS'),
                      _buildTableHeader('CERCA'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableInput(_coverTestLejos),
                      _buildTableInput(_coverTestCerca),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _movimientosOcularesController,
                label: 'Movimientos Oculares',
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // SECCIÓN 7: Salud Ocular y Oftalmoscopía
  Widget _buildSeccionSaludOcular() {
    return GestureDetector(
      onTap: () {
        setState(() {
          expandedSections['saludOcular'] = !expandedSections['saludOcular']!;
        });
      },
      child: FormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Salud Ocular y Oftalmoscopía',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulReal,
                  ),
                ),
                Icon(
                  expandedSections['saludOcular']!
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.azulReal,
                ),
              ],
            ),
            if (expandedSections['saludOcular']!) ...[
              SizedBox(height: 16),
              Text(
                'Salud Ocular',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _saludOcularOD,
                      label: 'OD',
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: CustomTextField(
                      controller: _saludOcularOI,
                      label: 'OI',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Oftalmoscopía',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _oftalmoscopiaOD,
                      label: 'OD',
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: CustomTextField(
                      controller: _oftalmoscopiaOI,
                      label: 'OI',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // SECCIÓN 8: Subjetivo
  Widget _buildSeccionSubjetivo() {
    return GestureDetector(
      onTap: () {
        setState(() {
          expandedSections['subjetivo'] = !expandedSections['subjetivo']!;
        });
      },
      child: FormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subjetivo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulReal,
                  ),
                ),
                Icon(
                  expandedSections['subjetivo']!
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.azulReal,
                ),
              ],
            ),
            if (expandedSections['subjetivo']!) ...[
              SizedBox(height: 16),
              Table(
                border: TableBorder.all(color: Colors.grey[300]!),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[100]),
                    children: [
                      _buildTableHeader(''),
                      _buildTableHeader('ESF'),
                      _buildTableHeader('CIL'),
                      _buildTableHeader('EJE'),
                      _buildTableHeader('ADD'),
                      _buildTableHeader('AV'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('OD', isHeader: true),
                      _buildTableInput(_subjetivoODEsf),
                      _buildTableInput(_subjetivoODCil),
                      _buildTableInput(_subjetivoODEje),
                      _buildTableInput(_subjetivoODAdd),
                      _buildTableInput(_subjetivoODAV),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('OI', isHeader: true),
                      _buildTableInput(_subjetivoOIEsf),
                      _buildTableInput(_subjetivoOICil),
                      _buildTableInput(_subjetivoOIEje),
                      _buildTableInput(_subjetivoOIAdd),
                      _buildTableInput(_subjetivoOIAV),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // SECCIÓN 9: DNP y Altura
  Widget _buildSeccionDNPAltura() {
    return GestureDetector(
      onTap: () {
        setState(() {
          expandedSections['dnpAltura'] = !expandedSections['dnpAltura']!;
        });
      },
      child: FormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DNP y Altura',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulReal,
                  ),
                ),
                Icon(
                  expandedSections['dnpAltura']!
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.azulReal,
                ),
              ],
            ),
            if (expandedSections['dnpAltura']!) ...[
              SizedBox(height: 16),
              Table(
                border: TableBorder.all(color: Colors.grey[300]!),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[100]),
                    children: [
                      _buildTableHeader(''),
                      _buildTableHeader('DNP'),
                      _buildTableHeader('ALTURA'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('OD', isHeader: true),
                      _buildTableInput(_dnpOD),
                      _buildTableInput(_alturaOD),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('OI', isHeader: true),
                      _buildTableInput(_dnpOI),
                      _buildTableInput(_alturaOI),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // SECCIÓN 10: Puntos de Worth
  Widget _buildSeccionPuntosWorth() {
    return GestureDetector(
      onTap: () {
        setState(() {
          expandedSections['puntosWorth'] = !expandedSections['puntosWorth']!;
        });
      },
      child: FormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Puntos de Worth',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulReal,
                  ),
                ),
                Icon(
                  expandedSections['puntosWorth']!
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.azulReal,
                ),
              ],
            ),
            if (expandedSections['puntosWorth']!) ...[
              SizedBox(height: 16),
              CustomTextField(
                controller: _puntosWorth,
                label: 'Puntos de Worth - LEJOS',
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // SECCIÓN 11: RX Final
  Widget _buildSeccionRXFinal() {
    return GestureDetector(
      onTap: () {
        setState(() {
          expandedSections['rxFinal'] = !expandedSections['rxFinal']!;
        });
      },
      child: FormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RX Final',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulReal,
                  ),
                ),
                Icon(
                  expandedSections['rxFinal']!
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.azulReal,
                ),
              ],
            ),
            if (expandedSections['rxFinal']!) ...[
              SizedBox(height: 16),
              Table(
                border: TableBorder.all(color: Colors.grey[300]!),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[100]),
                    children: [
                      _buildTableHeader(''),
                      _buildTableHeader('ESF'),
                      _buildTableHeader('CIL'),
                      _buildTableHeader('EJE'),
                      _buildTableHeader('ADD'),
                      _buildTableHeader('AV'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('OD', isHeader: true),
                      _buildTableInput(_rxFinalODEsf),
                      _buildTableInput(_rxFinalODCil),
                      _buildTableInput(_rxFinalODEje),
                      _buildTableInput(_rxFinalODAdd),
                      _buildTableInput(_rxFinalODAV),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('OI', isHeader: true),
                      _buildTableInput(_rxFinalOIEsf),
                      _buildTableInput(_rxFinalOICil),
                      _buildTableInput(_rxFinalOIEje),
                      _buildTableInput(_rxFinalOIAdd),
                      _buildTableInput(_rxFinalOIAV),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // SECCIÓN 12: Diagnóstico y Recomendaciones
  Widget _buildSeccionDiagnostico() {
    return FormCard(
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
    );
  }

  // Widgets auxiliares para tablas
  Widget _buildTableHeader(String text) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableInput(TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}
