const mongoose = require('mongoose');

// Esquema para síntomas (checkboxes)
const sintomasSchema = new mongoose.Schema({
  enrojecimiento: { type: Boolean, default: false },
  dificultadNoche: { type: Boolean, default: false },
  comezon: { type: Boolean, default: false },
  molestiaSol: { type: Boolean, default: false },
  sensibilidadLuzArtificial: { type: Boolean, default: false },
  lagrimeo: { type: Boolean, default: false },
  malEnfoqueLejos: { type: Boolean, default: false },
  malEnfoqueCerca: { type: Boolean, default: false },
  molestiasComputadora: { type: Boolean, default: false },
  lagana: { type: Boolean, default: false },
  otros: String
}, { _id: false });

// Esquema para antecedentes personales
const antecedentesSchema = new mongoose.Schema({
  alergias: { type: Boolean, default: false },
  especificacionAlergias: String,
  lenteOftalmico: { type: Boolean, default: false },
  lenteContacto: { type: Boolean, default: false },
  diabetico: { type: Boolean, default: false },
  hipertension: { type: Boolean, default: false },
  hipotension: { type: Boolean, default: false },
  tiroides: { type: Boolean, default: false },
  ultimaValoracion: String
}, { _id: false });

// Esquema para tabla AV (Agudeza Visual)
const avTablaSchema = new mongoose.Schema({
  lejana: { od: String, oi: String },
  cerca: { od: String, oi: String },
  otro: String,
  sin_lentes: { od: String, oi: String, ao: String },
  con_lentes: { od: String, oi: String, ao: String },
  estenopeica: { od: String, oi: String }
}, { _id: false });

// Agudeza visual como campo independiente (usado en revisiones)
const agudezaVisualSchema = new mongoose.Schema({
  sin_lentes: { od: String, oi: String, ao: String },
  con_lentes: { od: String, oi: String, ao: String },
  estenopeica: { od: String, oi: String }
}, { _id: false });

// Esquema para RX Anterior
const rxAnteriorSchema = new mongoose.Schema({
  od: {
    esf: String,
    cil: String,
    eje: String,
    add: String,
    av: String,
    dnp: String
  },
  oi: {
    esf: String,
    cil: String,
    eje: String,
    add: String,
    av: String,
    dnp: String
  }
}, { _id: false });

// Síntomas específicos de consulta infantil
const sintomasInfanteSchema = new mongoose.Schema({
  enrojecimiento: { type: Boolean, default: false },
  comezon: { type: Boolean, default: false },
  dolorCabeza: { type: Boolean, default: false },
  lagrimeoArdor: { type: Boolean, default: false },
  pierdeEquilibrio: { type: Boolean, default: false },
  tropieza: { type: Boolean, default: false },
  acercaObjetos: { type: Boolean, default: false },
  chocaObjetos: { type: Boolean, default: false },
  natural: { type: Boolean, default: false },
  entrecierraOjos: { type: Boolean, default: false },
  escrituraIrregular: { type: Boolean, default: false },
  desempenoEscolar: { type: Boolean, default: false },
  noSintomas: { type: Boolean, default: false },
  cesarea: { type: Boolean, default: false },
  otros: String
}, { _id: false });

// Antecedentes personales específicos de consulta infantil
const antecedentesInfanteSchema = new mongoose.Schema({
  diabetico: { type: Boolean, default: false },
  hipertenso: { type: Boolean, default: false },
  alergias: { type: Boolean, default: false },
  enfermedadesCronicas: { type: Boolean, default: false },
  especifiqueAlergias: String
}, { _id: false });

// Esquema para Cover Test
const coverTestSchema = new mongoose.Schema({
  lejos: String,
  cerca: String
}, { _id: false });

// Esquema para Salud Ocular
const saludOcularSchema = new mongoose.Schema({
  od: String,
  oi: String
}, { _id: false });

// Esquema para Oftalmoscopía
const oftalmoscopiaSchema = new mongoose.Schema({
  od: String,
  oi: String
}, { _id: false });

// Esquema para Subjetivo
const subjetivoSchema = new mongoose.Schema({
  od: {
    esf: String,
    cil: String,
    eje: String,
    add: String,
    av: String
  },
  oi: {
    esf: String,
    cil: String,
    eje: String,
    add: String,
    av: String
  }
}, { _id: false });

// Esquema para DNP y Altura
const dnpAlturaSchema = new mongoose.Schema({
  od: { dnp: String, altura: String },
  oi: { dnp: String, altura: String }
}, { _id: false });

// Esquema para RX Final
const rxFinalSchema = new mongoose.Schema({
  od: {
    esf: String,
    cil: String,
    eje: String,
    add: String,
    av: String,
    dnp: String
  },
  oi: {
    esf: String,
    cil: String,
    eje: String,
    add: String,
    av: String,
    dnp: String
  }
}, { _id: false });

// ESQUEMA PRINCIPAL DE CONSULTA (ACTUALIZADO)
const consultaSchema = new mongoose.Schema({
  // Información básica
  fecha: { type: Date, default: Date.now },
  especialista: String,
  motivoConsulta: String,
  
  // Tipo de paciente (adulto/infante)
  tipoPaciente: { type: String, enum: ['adulto', 'infante'], default: 'adulto' },
  
  // Síntomas
  sintomas: sintomasSchema,
  
  // Antecedentes personales
  antecedentes: antecedentesSchema,
  
  // Tablas clínicas
  avTabla: avTablaSchema,
  rxAnterior: rxAnteriorSchema,
  coverTest: coverTestSchema,
  movimientosOculares: String,
  saludOcular: saludOcularSchema,
  oftalmoscopia: oftalmoscopiaSchema,
  subjetivo: subjetivoSchema,
  dnpAltura: dnpAlturaSchema,
  puntosWorth: String,
  rxFinal: rxFinalSchema,
  
  // Diagnóstico y recomendaciones (los que ya teníamos)
  diagnostico: String,
  recomendaciones: String,
  notasAdicionales: String,
  productosRecetados: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Producto' }],

  // Marcador explícito de revisión (vs. consulta inicial)
  esRevision: { type: Boolean, default: false },
  // Agudeza visual enviada como campo independiente (formulario de revisión)
  agudezaVisual: agudezaVisualSchema,

  // Campos específicos de la consulta infantil
  padreTutor: String,
  edad: Number,
  telefono: String,
  sexo: { type: String, enum: ['masculino', 'femenino'] },
  anioEscolar: String,
  sintomasInfante: sintomasInfanteSchema,
  tipoParto: String,
  complicaciones: String,
  estrabismoFamiliar: Boolean,
  lazoFamiliar: String,
  golpeOjos: Boolean,
  especifiqueGolpe: String,
  antecedentesInfante: antecedentesInfanteSchema,
  ultimoExamen: String,
  equilibrioPie: String,
  requiereTerapia: String,
  tratamientoPatologia: String
});

// Esquema de Paciente (se mantiene igual)
const pacienteSchema = new mongoose.Schema({
  fecha_registro: { type: Date, default: Date.now },
  nombre: { type: String, required: true },
  telefono: { type: String, required: true },
  direccion: String,
  edad: Number,
  como_se_entero: String,
  observaciones: String,
  consultas: [consultaSchema],
  ventas: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Venta' }],
  activo: { type: Boolean, default: true }
});

module.exports = mongoose.model('Paciente', pacienteSchema);