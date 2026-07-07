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
  otro: String
}, { _id: false });

// Esquema para RX Anterior
const rxAnteriorSchema = new mongoose.Schema({
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
  productosRecetados: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Producto' }]
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