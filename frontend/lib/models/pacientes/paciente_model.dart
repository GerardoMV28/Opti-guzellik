class Consulta {
  final String id;
  final DateTime fecha;
  final String especialista;
  final String motivoConsulta;
  final String tipoPaciente; // 'adulto' o 'infante'
  final bool esRevision;

  // Síntomas
  final Map<String, dynamic>? sintomas;
  final String? otrosSintomas;
  
  // Antecedentes
  final Map<String, dynamic>? antecedentes;
  final String? especificacionAlergias;
  final String? ultimaValoracion;
  
  // Agudeza visual
  final Map<String, dynamic>? agudezaVisual;
  
  // Exámenes
  final String movimientosOculares;
  final String retinoscopia;
  final Map<String, String>? queratometria;
  
  // Cover Test
  final Map<String, dynamic>? coverTest;
  
  // Salud Ocular
  final Map<String, dynamic>? saludOcular;
  
  // Oftalmoscopía
  final Map<String, dynamic>? oftalmoscopia;
  
  // RX Anterior
  final Map<String, dynamic>? rxAnterior;
  
  // Subjetivo
  final Map<String, dynamic>? subjetivo;
  
  // DNP y Altura
  final Map<String, dynamic>? dnpAltura;
  
  // Puntos de Worth
  final String? puntosWorth;
  
  // RX Final
  final Map<String, dynamic>? rxFinal;
  
  // Graduación final (para compatibilidad)
  final Map<String, dynamic> graduacionFinal;
  
  final String diagnostico;
  final String recomendaciones;
  final List<String> productosRecetados;
  final String notasAdicionales;

  Consulta({
    required this.id,
    required this.fecha,
    required this.especialista,
    required this.motivoConsulta,
    this.tipoPaciente = 'adulto',
    this.esRevision = false,
    this.sintomas,
    this.otrosSintomas,
    this.antecedentes,
    this.especificacionAlergias,
    this.ultimaValoracion,
    this.agudezaVisual,
    required this.movimientosOculares,
    required this.retinoscopia,
    this.queratometria,
    this.coverTest,
    this.saludOcular,
    this.oftalmoscopia,
    this.rxAnterior,
    this.subjetivo,
    this.dnpAltura,
    this.puntosWorth,
    this.rxFinal,
    required this.graduacionFinal,
    required this.diagnostico,
    required this.recomendaciones,
    required this.productosRecetados,
    required this.notasAdicionales,
  });

  factory Consulta.fromJson(Map<String, dynamic> json) {
    return Consulta(
      id: json['_id'] ?? '',
      fecha: json['fecha'] != null 
          ? DateTime.parse(json['fecha']) 
          : DateTime.now(),
      especialista: json['especialista'] ?? '',
      motivoConsulta: json['motivoConsulta'] ?? json['motivo_consulta'] ?? '',
      tipoPaciente: json['tipoPaciente'] ?? json['tipo_paciente'] ?? 'adulto',
      esRevision: json['esRevision'] ?? false,

      // Síntomas
      sintomas: json['sintomas'],
      otrosSintomas: json['sintomas']?['otros'] ?? '',
      
      // Antecedentes
      antecedentes: json['antecedentes'],
      especificacionAlergias: json['antecedentes']?['especificacionAlergias'] ?? 
                              json['antecedentes']?['especificacion_alergias'] ?? '',
      ultimaValoracion: json['antecedentes']?['ultimaValoracion'] ?? 
                        json['antecedentes']?['ultima_valoracion'] ?? '',
      
      agudezaVisual: json['agudeza_visual'] ?? json['agudezaVisual'] ?? json['avTabla'],
      movimientosOculares: json['movimientos_oculares'] ?? json['movimientosOculares'] ?? '',
      retinoscopia: json['retinoscopia'] ?? '',
      queratometria: Map<String, String>.from(json['queratometria'] ?? {}),
      
      // Nuevos campos
      coverTest: json['coverTest'] ?? json['cover_test'],
      saludOcular: json['saludOcular'] ?? json['salud_ocular'],
      oftalmoscopia: json['oftalmoscopia'],
      rxAnterior: json['rxAnterior'] ?? json['rx_anterior'],
      subjetivo: json['subjetivo'],
      dnpAltura: json['dnpAltura'] ?? json['dnp_altura'],
      puntosWorth: json['puntosWorth'] ?? json['puntos_worth'] ?? '',
      rxFinal: json['rxFinal'] ?? json['rx_final'],
      
      graduacionFinal: json['graduacion_final'] ?? json['graduacionFinal'] ?? {},
      diagnostico: json['diagnostico'] ?? '',
      recomendaciones: json['recomendaciones'] ?? '',
      productosRecetados: List<String>.from(json['productos_recetados'] ?? json['productosRecetados'] ?? []),
      notasAdicionales: json['notas_adicionales'] ?? json['notasAdicionales'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha.toIso8601String(),
      'especialista': especialista,
      'motivo_consulta': motivoConsulta,
      'tipo_paciente': tipoPaciente,
      'sintomas': sintomas,
      'antecedentes': antecedentes,
      'agudeza_visual': agudezaVisual,
      'movimientos_oculares': movimientosOculares,
      'retinoscopia': retinoscopia,
      'queratometria': queratometria,
      'cover_test': coverTest,
      'salud_ocular': saludOcular,
      'oftalmoscopia': oftalmoscopia,
      'rx_anterior': rxAnterior,
      'subjetivo': subjetivo,
      'dnp_altura': dnpAltura,
      'puntos_worth': puntosWorth,
      'rx_final': rxFinal,
      'graduacion_final': graduacionFinal,
      'diagnostico': diagnostico,
      'recomendaciones': recomendaciones,
      'productos_recetados': productosRecetados,
      'notas_adicionales': notasAdicionales,
    };
  }
}

class Paciente {
  final String id;
  final DateTime fechaRegistro;
  final String nombre;
  final String telefono;
  final String email;
  final String direccion;
  final DateTime? fechaNacimiento;
  final int? edad;
  final String comoSeEntero;
  final String observaciones;
  final List<Consulta> consultas;
  final List<String> ventas;
  final bool activo;

  Paciente({
    required this.id,
    required this.fechaRegistro,
    required this.nombre,
    required this.telefono,
    required this.email,
    required this.direccion,
    this.fechaNacimiento,
    this.edad,
    required this.comoSeEntero,
    required this.observaciones,
    required this.consultas,
    required this.ventas,
    required this.activo,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['_id'] ?? json['id'] ?? '',
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'])
          : DateTime.now(),
      nombre: json['nombre'] ?? '',
      telefono: json['telefono'] ?? '',
      email: json['email'] ?? '',
      direccion: json['direccion'] ?? '',
      fechaNacimiento: json['fecha_nacimiento'] != null
          ? DateTime.parse(json['fecha_nacimiento'])
          : null,
      edad: json['edad'],
      comoSeEntero: json['como_se_entero'] ?? '',
      observaciones: json['observaciones'] ?? '',
      consultas: (json['consultas'] as List?)
          ?.map((c) => Consulta.fromJson(c))
          .toList() ?? [],
      ventas: List<String>.from(json['ventas'] ?? []),
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
      'edad': edad,
      'como_se_entero': comoSeEntero,
      'observaciones': observaciones,
      'consultas': consultas.map((c) => c.toJson()).toList(),
      'ventas': ventas,
      'activo': activo,
    };
  }
}