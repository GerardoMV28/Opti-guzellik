import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../services/paciente_service.dart';
import '../../../widgets/forms/index.dart';

class ConsultaInfanteForm extends StatefulWidget {
  final String pacienteId;

  ConsultaInfanteForm({required this.pacienteId});

  @override
  _ConsultaInfanteFormState createState() => _ConsultaInfanteFormState();
}

class _ConsultaInfanteFormState extends State<ConsultaInfanteForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores básicos
  final _motivoController = TextEditingController();
  final _padreTutorController = TextEditingController();
  final _edadController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _anioEscolarController = TextEditingController();
  
  // Sexo
  String _sexoSeleccionado = 'masculino';
  final List<String> _opcionesSexo = ['masculino', 'femenino'];

  // Síntomas específicos de infantes
  Map<String, bool> sintomasInfante = {
    'enrojecimiento': false,
    'comezon': false,
    'dolorCabeza': false,
    'lagrimeoArdor': false,
    'pierdeEquilibrio': false,
    'tropieza': false,
    'acercaObjetos': false,
    'chocaObjetos': false,
    'natural': false,
    'entrecierraOjos': false,
    'escrituraIrregular': false,
    'desempenoEscolar': false,
    'noSintomas': false,
    'cesarea': false,
  };
  final _otrosSintomasController = TextEditingController();

  // Tipo de parto y complicaciones
  String _tipoParto = 'natural';
  final List<String> _opcionesParto = ['natural', 'cesárea', 'inducido'];
  final _complicacionesController = TextEditingController();

  // Antecedentes familiares
  String? _estrabismoFamiliar;
  final _lazoFamiliarController = TextEditingController();

  // Golpes
  String? _golpeOjos;
  final _especifiqueGolpeController = TextEditingController();

  // Antecedentes personales
  Map<String, bool> antecedentesInfante = {
    'diabetico': false,
    'hipertenso': false,
    'alergias': false,
    'enfermedadesCronicas': false,
  };
  final _ultimoExamenController = TextEditingController();
  final _especifiqueAlergiasController = TextEditingController();

  // AV Tabla
  final _avLejanaOD = TextEditingController();
  final _avLejanaOI = TextEditingController();
  final _avCercaOD = TextEditingController();
  final _avCercaOI = TextEditingController();
  final _avOtro = TextEditingController();

  // RX Anterior (completo)
  final _rxAntODEsf = TextEditingController();
  final _rxAntODCil = TextEditingController();
  final _rxAntODEje = TextEditingController();
  final _rxAntODAdd = TextEditingController();
  final _rxAntODAV = TextEditingController();
  final _rxAntODDNP = TextEditingController();

  final _rxAntOIEsf = TextEditingController();
  final _rxAntOICil = TextEditingController();
  final _rxAntOIEje = TextEditingController();
  final _rxAntOIAdd = TextEditingController();
  final _rxAntOIAV = TextEditingController();
  final _rxAntOIDNP = TextEditingController();

  // Equilibrio a un pie
  String _equilibrioPie = 'medio';
  final List<String> _opcionesEquilibrio = ['alto', 'medio', 'deficiente'];

  // Cover Test
  final _coverTestLejos = TextEditingController();
  final _coverTestCerca = TextEditingController();

  // Movimientos Oculares
  final _movimientosOcularesController = TextEditingController();

  // Salud Ocular
  final _saludOcularOD = TextEditingController();
  final _saludOcularOI = TextEditingController();

  // Oftalmoscopía
  final _oftalmoscopiaOD = TextEditingController();
  final _oftalmoscopiaOI = TextEditingController();

  // Puntos de Worth
  final _puntosWorthController = TextEditingController();

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

  // Requiere Terapia
  final _requiereTerapiaController = TextEditingController();

  // Tratamiento y Recomendaciones
  final _tratamientoPatologiaController = TextEditingController();
  final _recomendacionesController = TextEditingController();

  // Control de expansión de secciones
  Map<String, bool> expandedSections = {
    'basicos': true,
    'sintomas': true,
    'antecedentes': true,
    'avTabla': true,
    'rxAnterior': true,
    'examenes': true,
    'rxFinal': true,
    'terapia': true,
  };

  @override
  void dispose() {
    // Liberar todos los controladores
    _motivoController.dispose();
    _padreTutorController.dispose();
    _edadController.dispose();
    _telefonoController.dispose();
    _anioEscolarController.dispose();
    _otrosSintomasController.dispose();
    _complicacionesController.dispose();
    _lazoFamiliarController.dispose();
    _especifiqueGolpeController.dispose();
    _ultimoExamenController.dispose();
    _especifiqueAlergiasController.dispose();
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
    _rxAntODDNP.dispose();
    _rxAntOIEsf.dispose();
    _rxAntOICil.dispose();
    _rxAntOIEje.dispose();
    _rxAntOIAdd.dispose();
    _rxAntOIAV.dispose();
    _rxAntOIDNP.dispose();
    _coverTestLejos.dispose();
    _coverTestCerca.dispose();
    _movimientosOcularesController.dispose();
    _saludOcularOD.dispose();
    _saludOcularOI.dispose();
    _oftalmoscopiaOD.dispose();
    _oftalmoscopiaOI.dispose();
    _puntosWorthController.dispose();
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
    _requiereTerapiaController.dispose();
    _tratamientoPatologiaController.dispose();
    _recomendacionesController.dispose();
    super.dispose();
  }

  Future<void> _guardarConsulta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final consultaData = {
        'fecha': DateTime.now().toIso8601String(),
        'especialista': 'Dr. Charly',
        'tipoPaciente': 'infante',
        
        // Datos básicos
        'motivoConsulta': _motivoController.text.trim(),
        'padreTutor': _padreTutorController.text.trim(),
        'edad': int.tryParse(_edadController.text),
        'telefono': _telefonoController.text.trim(),
        'sexo': _sexoSeleccionado,
        'anioEscolar': _anioEscolarController.text.trim(),

        // Síntomas
        'sintomasInfante': {
          'enrojecimiento': sintomasInfante['enrojecimiento'],
          'comezon': sintomasInfante['comezon'],
          'dolorCabeza': sintomasInfante['dolorCabeza'],
          'lagrimeoArdor': sintomasInfante['lagrimeoArdor'],
          'pierdeEquilibrio': sintomasInfante['pierdeEquilibrio'],
          'tropieza': sintomasInfante['tropieza'],
          'acercaObjetos': sintomasInfante['acercaObjetos'],
          'chocaObjetos': sintomasInfante['chocaObjetos'],
          'natural': sintomasInfante['natural'],
          'entrecierraOjos': sintomasInfante['entrecierraOjos'],
          'escrituraIrregular': sintomasInfante['escrituraIrregular'],
          'desempenoEscolar': sintomasInfante['desempenoEscolar'],
          'noSintomas': sintomasInfante['noSintomas'],
          'cesarea': sintomasInfante['cesarea'],
          'otros': _otrosSintomasController.text.trim(),
        },

        // Parto
        'tipoParto': _tipoParto,
        'complicaciones': _complicacionesController.text.trim(),

        // Antecedentes familiares
        'estrabismoFamiliar': _estrabismoFamiliar == 'si',
        'lazoFamiliar': _lazoFamiliarController.text.trim(),

        // Golpes
        'golpeOjos': _golpeOjos == 'si',
        'especifiqueGolpe': _especifiqueGolpeController.text.trim(),

        // Antecedentes personales
        'antecedentesInfante': {
          'diabetico': antecedentesInfante['diabetico'],
          'hipertenso': antecedentesInfante['hipertenso'],
          'alergias': antecedentesInfante['alergias'],
          'enfermedadesCronicas': antecedentesInfante['enfermedadesCronicas'],
          'especifiqueAlergias': _especifiqueAlergiasController.text.trim(),
        },
        'ultimoExamen': _ultimoExamenController.text.trim(),

        // AV Tabla
        'avTabla': {
          'lejana': {
            'od': _avLejanaOD.text.trim(),
            'oi': _avLejanaOI.text.trim(),
          },
          'cerca': {
            'od': _avCercaOD.text.trim(),
            'oi': _avCercaOI.text.trim(),
          },
          'otro': _avOtro.text.trim(),
        },

        // RX Anterior
        'rxAnterior': {
          'od': {
            'esf': _rxAntODEsf.text.trim(),
            'cil': _rxAntODCil.text.trim(),
            'eje': _rxAntODEje.text.trim(),
            'add': _rxAntODAdd.text.trim(),
            'av': _rxAntODAV.text.trim(),
            'dnp': _rxAntODDNP.text.trim(),
          },
          'oi': {
            'esf': _rxAntOIEsf.text.trim(),
            'cil': _rxAntOICil.text.trim(),
            'eje': _rxAntOIEje.text.trim(),
            'add': _rxAntOIAdd.text.trim(),
            'av': _rxAntOIAV.text.trim(),
            'dnp': _rxAntOIDNP.text.trim(),
          },
        },

        // Equilibrio
        'equilibrioPie': _equilibrioPie,

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

        // Puntos de Worth
        'puntosWorth': _puntosWorthController.text.trim(),

        // RX Final
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

        // Terapia y tratamiento
        'requiereTerapia': _requiereTerapiaController.text.trim(),
        'tratamientoPatologia': _tratamientoPatologiaController.text.trim(),
        'recomendaciones': _recomendacionesController.text.trim(),
      };

      await PacienteService.addConsulta(widget.pacienteId, consultaData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Consulta infantil guardada correctamente'),
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
          'Nueva Consulta - Infantil',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSeccionBasica(),
              SizedBox(height: 16),
              _buildSeccionSintomas(),
              SizedBox(height: 16),
              _buildSeccionParto(),
              SizedBox(height: 16),
              _buildSeccionAntecedentesFamiliares(),
              SizedBox(height: 16),
              _buildSeccionAntecedentesPersonales(),
              SizedBox(height: 16),
              _buildSeccionAVTabla(),
              SizedBox(height: 16),
              _buildSeccionRXAnterior(),
              SizedBox(height: 16),
              _buildSeccionExamenes(),
              SizedBox(height: 16),
              _buildSeccionRXFinal(),
              SizedBox(height: 16),
              _buildSeccionTerapia(),
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

  // SECCIÓN 1: Datos Básicos
  Widget _buildSeccionBasica() {
    return GestureDetector(
      onTap: () {
        setState(() {
          expandedSections['basicos'] = !expandedSections['basicos']!;
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
                  'Datos del Paciente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulReal,
                  ),
                ),
                Icon(
                  expandedSections['basicos']!
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.azulReal,
                ),
              ],
            ),
            if (expandedSections['basicos']!) ...[
              SizedBox(height: 16),
              CustomTextField(
                controller: _motivoController,
                label: 'Motivo de consulta',
                prefixIcon: Icons.chat_outlined,
                maxLines: 2,
                validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _padreTutorController,
                label: 'Padre o Tutor',
                prefixIcon: Icons.family_restroom,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _edadController,
                      label: 'Edad',
                      prefixIcon: Icons.numbers,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: CustomDropdown<String>(
                      value: _sexoSeleccionado,
                      label: 'Sexo',
                      icon: Icons.wc,
                      items: _opcionesSexo.map((sexo) {
                        return DropdownMenuItem(
                          value: sexo,
                          child: Text(sexo),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _sexoSeleccionado = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _telefonoController,
                label: 'Teléfono',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _anioEscolarController,
                label: 'Año escolar',
                prefixIcon: Icons.school_outlined,
              ),
            ],
          ],
        ),
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
      {'key': 'enrojecimiento', 'label': 'Enrojecimiento', 'icon': Icons.water_drop},
      {'key': 'comezon', 'label': 'Comezón', 'icon': Icons.healing},
      {'key': 'dolorCabeza', 'label': 'Dolor de cabeza', 'icon': Icons.headset_mic_outlined},
      {'key': 'lagrimeoArdor', 'label': 'Lagrimeo/Ardor', 'icon': Icons.water},
      {'key': 'pierdeEquilibrio', 'label': 'Pierde equilibrio', 'icon': Icons.balance},
      {'key': 'tropieza', 'label': 'Se tropieza', 'icon': Icons.warning},
      {'key': 'acercaObjetos', 'label': 'Se acerca a objetos', 'icon': Icons.zoom_in},
      {'key': 'chocaObjetos', 'label': 'Choca con objetos', 'icon': Icons.emergency},
      {'key': 'natural', 'label': 'Natural', 'icon': Icons.thumb_up},
      {'key': 'entrecierraOjos', 'label': 'Entrecierra ojos', 'icon': Icons.visibility_off},
      {'key': 'escrituraIrregular', 'label': 'Escritura irregular', 'icon': Icons.edit},
      {'key': 'desempenoEscolar', 'label': 'Desempeño escolar', 'icon': Icons.school},
      {'key': 'noSintomas', 'label': 'No hay síntomas', 'icon': Icons.check_circle},
      {'key': 'cesarea', 'label': 'Cesárea', 'icon': Icons.child_care},
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
                color: sintomasInfante[item['key'] as String]!
                    ? Colors.white
                    : AppColors.azulCobalto,
              ),
              SizedBox(width: 4),
              Text(item['label'] as String),
            ],
          ),
          selected: sintomasInfante[item['key'] as String]!,
          onSelected: (bool selected) {
            setState(() {
              sintomasInfante[item['key'] as String] = selected;
            });
          },
          selectedColor: AppColors.turquesa,
          checkmarkColor: Colors.white,
          backgroundColor: Colors.grey[100],
          labelStyle: TextStyle(
            color: sintomasInfante[item['key'] as String]!
                ? Colors.white
                : Colors.black87,
            fontSize: 12,
          ),
        );
      }).toList(),
    );
  }

  // SECCIÓN 3: Tipo de Parto
  Widget _buildSeccionParto() {
    return FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipo de Parto',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.azulReal,
            ),
          ),
          SizedBox(height: 16),
          CustomDropdown<String>(
            value: _tipoParto,
            label: 'Seleccione tipo de parto',
            icon: Icons.child_care,
            items: _opcionesParto.map((tipo) {
              return DropdownMenuItem(
                value: tipo,
                child: Text(tipo),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _tipoParto = value!;
              });
            },
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: _complicacionesController,
            label: 'Complicaciones',
            hintText: 'Describa si hubo complicaciones',
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // SECCIÓN 4: Antecedentes Familiares
  Widget _buildSeccionAntecedentesFamiliares() {
    return FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Antecedentes Familiares',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.azulReal,
            ),
          ),
          SizedBox(height: 16),
          Text('¿Antecedentes de estrabismo en la familia?'),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text('Sí'),
                  value: 'si',
                  groupValue: _estrabismoFamiliar,
                  onChanged: (value) {
                    setState(() {
                      _estrabismoFamiliar = value;
                    });
                  },
                  activeColor: AppColors.turquesa,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: Text('No'),
                  value: 'no',
                  groupValue: _estrabismoFamiliar,
                  onChanged: (value) {
                    setState(() {
                      _estrabismoFamiliar = value;
                    });
                  },
                  activeColor: AppColors.turquesa,
                ),
              ),
            ],
          ),
          if (_estrabismoFamiliar == 'si') ...[
            SizedBox(height: 8),
            CustomTextField(
              controller: _lazoFamiliarController,
              label: 'Lazo familiar',
              hintText: 'Ej: primo, tío, etc.',
            ),
          ],
          SizedBox(height: 16),
          Text('¿Ha sufrido algún golpe en los ojos o en la cabeza?'),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text('Sí'),
                  value: 'si',
                  groupValue: _golpeOjos,
                  onChanged: (value) {
                    setState(() {
                      _golpeOjos = value;
                    });
                  },
                  activeColor: AppColors.turquesa,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: Text('No'),
                  value: 'no',
                  groupValue: _golpeOjos,
                  onChanged: (value) {
                    setState(() {
                      _golpeOjos = value;
                    });
                  },
                  activeColor: AppColors.turquesa,
                ),
              ),
            ],
          ),
          if (_golpeOjos == 'si') ...[
            SizedBox(height: 8),
            CustomTextField(
              controller: _especifiqueGolpeController,
              label: 'Especifique',
              hintText: 'Describa el golpe',
            ),
          ],
        ],
      ),
    );
  }

  // SECCIÓN 5: Antecedentes Personales
  Widget _buildSeccionAntecedentesPersonales() {
    return FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Antecedentes Personales',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.azulReal,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: antecedentesInfante['diabetico'],
                    onChanged: (value) {
                      setState(() {
                        antecedentesInfante['diabetico'] = value!;
                      });
                    },
                    activeColor: AppColors.turquesa,
                  ),
                  Text('Diabético'),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: antecedentesInfante['hipertenso'],
                    onChanged: (value) {
                      setState(() {
                        antecedentesInfante['hipertenso'] = value!;
                      });
                    },
                    activeColor: AppColors.turquesa,
                  ),
                  Text('Hipertenso'),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: antecedentesInfante['alergias'],
                    onChanged: (value) {
                      setState(() {
                        antecedentesInfante['alergias'] = value!;
                      });
                    },
                    activeColor: AppColors.turquesa,
                  ),
                  Text('Alergias'),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: antecedentesInfante['enfermedadesCronicas'],
                    onChanged: (value) {
                      setState(() {
                        antecedentesInfante['enfermedadesCronicas'] = value!;
                      });
                    },
                    activeColor: AppColors.turquesa,
                  ),
                  Text('Enfermedades Crónicas'),
                ],
              ),
            ],
          ),
          if (antecedentesInfante['alergias']!) ...[
            SizedBox(height: 8),
            CustomTextField(
              controller: _especifiqueAlergiasController,
              label: 'Especifique alergias',
            ),
          ],
          SizedBox(height: 16),
          CustomTextField(
            controller: _ultimoExamenController,
            label: 'Último examen visual',
            hintText: 'Fecha del último examen',
          ),
        ],
      ),
    );
  }

  // SECCIÓN 6: AV Tabla
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
              Table(
                border: TableBorder.all(color: Colors.grey[300]!),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[100]),
                    children: [
                      _buildTableHeader(''),
                      _buildTableHeader('LEJANA'),
                      _buildTableHeader('CERCA'),
                      _buildTableHeader('(Otro)'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('OD', isHeader: true),
                      _buildTableInput(_avLejanaOD),
                      _buildTableInput(_avCercaOD),
                      _buildTableInput(_avOtro),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('OI', isHeader: true),
                      _buildTableInput(_avLejanaOI),
                      _buildTableInput(_avCercaOI),
                      _buildTableInput(_avOtro),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              CustomTextField(
                controller: _avOtro,
                label: 'Observaciones AV',
              ),
            ],
          ],
        ),
      ),
    );
  }

  // SECCIÓN 7: RX Anterior
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
                      _buildTableHeader('DNP'),
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
                      _buildTableInput(_rxAntODDNP),
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
                      _buildTableInput(_rxAntOIDNP),
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

  // SECCIÓN 8: Exámenes (Cover Test, Equilibrio, etc.)
  Widget _buildSeccionExamenes() {
    return GestureDetector(
      onTap: () {
        setState(() {
          expandedSections['examenes'] = !expandedSections['examenes']!;
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
                  'Exámenes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulReal,
                  ),
                ),
                Icon(
                  expandedSections['examenes']!
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.azulReal,
                ),
              ],
            ),
            if (expandedSections['examenes']!) ...[
              SizedBox(height: 16),
              Text('Equilibrio a un Pie', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              CustomDropdown<String>(
                value: _equilibrioPie,
                label: 'Seleccione nivel',
                icon: Icons.balance,
                items: _opcionesEquilibrio.map((nivel) {
                  return DropdownMenuItem(
                    value: nivel,
                    child: Text(nivel),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _equilibrioPie = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              Text('Cover Test', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
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
              SizedBox(height: 16),
              Text('Salud Ocular', style: TextStyle(fontWeight: FontWeight.bold)),
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
              Text('Oftalmoscopía', style: TextStyle(fontWeight: FontWeight.bold)),
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
              SizedBox(height: 16),
              CustomTextField(
                controller: _puntosWorthController,
                label: 'Puntos de Worth - Lejos',
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // SECCIÓN 9: RX Final
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
                      _buildTableHeader('DNP'),
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
                      _buildTableInput(_rxFinalODDNP),
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
                      _buildTableInput(_rxFinalOIDNP),
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

  // SECCIÓN 10: Terapia y Tratamiento
  Widget _buildSeccionTerapia() {
    return GestureDetector(
      onTap: () {
        setState(() {
          expandedSections['terapia'] = !expandedSections['terapia']!;
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
                  'Terapia y Tratamiento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulReal,
                  ),
                ),
                Icon(
                  expandedSections['terapia']!
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.azulReal,
                ),
              ],
            ),
            if (expandedSections['terapia']!) ...[
              SizedBox(height: 16),
              CustomTextField(
                controller: _requiereTerapiaController,
                label: 'Requiere Terapia',
                hintText: 'Describa si requiere terapia',
                maxLines: 2,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _tratamientoPatologiaController,
                label: 'Tratamiento a patología',
                maxLines: 2,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _recomendacionesController,
                label: 'Recomendaciones',
                prefixIcon: Icons.lightbulb_outline,
                maxLines: 3,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widgets auxiliares para tablas
  Widget _buildTableHeader(String text) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
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
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableInput(TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.all(2),
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        ),
        style: TextStyle(fontSize: 11),
      ),
    );
  }
}