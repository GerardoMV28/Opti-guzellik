const mongoose = require('mongoose');

const itemVentaSchema = new mongoose.Schema({
  producto_id: { type: String, required: true },
  tipo: { type: String, required: true },
  nombre: { type: String, required: true },
  codigo: { type: String, required: true },
  cantidad: { type: Number, required: true, min: 1 },
  precio_unitario: { type: mongoose.Schema.Types.Decimal128, required: true },
  descuento: { type: mongoose.Schema.Types.Decimal128, default: 0 },
  subtotal: { type: mongoose.Schema.Types.Decimal128, required: true },
  graduacion: {
    od: { esfera: String, cilindro: String, eje: String, adicion: String },
    oi: { esfera: String, cilindro: String, eje: String, adicion: String }
  },
  armazon_detalle: {
    color: String,
    medidas: String,
    costo_armazon: Number
  }
}, { _id: true });

const historialEstadoSchema = new mongoose.Schema({
  estado: { type: String, required: true },
  fecha: { type: Date, default: Date.now },
  nota: String,
  actualizado_por: String
}, { _id: true });

// ✅ MOVER abonoSchema ANTES de ventaSchema
const abonoSchema = new mongoose.Schema({
  monto: { type: Number, required: true },
  fecha: { type: Date, default: Date.now },
  forma_pago: { type: String, enum: ['efectivo', 'tarjeta', 'transferencia'] },
  registrado_por: String,
  nota: String
}, { _id: true });

const ventaSchema = new mongoose.Schema({
  folio: { type: String, unique: true },
  fecha: { type: Date, default: Date.now },
  vendedor: { type: String, required: true },
  vendedor_id: { type: String },
  
  paciente_id: { type: String },
  paciente_nombre: { type: String },
  paciente_telefono: { type: String },
  
  consulta_id: { type: String },
  
  productos: [itemVentaSchema],
  
  subtotal: { type: mongoose.Schema.Types.Decimal128, required: true },
  descuento_total: { type: mongoose.Schema.Types.Decimal128, default: 0 },
  total: { type: mongoose.Schema.Types.Decimal128, required: true },
  
  anticipo: { type: mongoose.Schema.Types.Decimal128, default: 0 },
  saldo_pendiente: { type: mongoose.Schema.Types.Decimal128, default: 0 },
  fecha_limite_pago: Date,
  
  forma_pago: { type: String, enum: ['efectivo', 'tarjeta', 'transferencia', 'mixto'], required: true },
  detalle_pago_mixto: {
    efectivo: mongoose.Schema.Types.Decimal128,
    tarjeta: mongoose.Schema.Types.Decimal128,
    transferencia: mongoose.Schema.Types.Decimal128
  },
  
  fecha_entrega: Date,
  estado: { 
    type: String, 
    enum: ['por_enviar', 'laboratorio', 'garantia', 'cortesia', 'reproceso', 'listo_entrega', 'entregado', 'cancelado'],
    default: 'por_enviar'
  },
  
  historial_estados: [historialEstadoSchema],
  
  // ✅ AGREGAR historial_abonos
  historial_abonos: [abonoSchema],
  
  factura: {
    requiere_factura: { type: Boolean, default: false },
    rfc: String,
    razon_social: String,
    cfdi: String,
    fecha_facturacion: Date,
    archivo_pdf: String
  },
  
  notificaciones: {
    whatsapp_enviado: { type: Boolean, default: false },
    whatsapp_fecha: Date,
    email_enviado: { type: Boolean, default: false },
    email_fecha: Date
  },
  
  notas: String,
  
  activo: { type: Boolean, default: true }
}, {
  timestamps: { createdAt: 'fecha_creacion', updatedAt: 'fecha_actualizacion' },
  toJSON: {
    transform: function(doc, ret) {
      function convertDecimals(obj) {
        if (obj === null || obj === undefined) return obj;
        if (obj.constructor && obj.constructor.name === 'Decimal128') {
          return parseFloat(obj.toString());
        }
        if (obj.constructor && (obj.constructor.name === 'ObjectId' || obj._bsontype === 'ObjectID' || obj._bsontype === 'ObjectId')) {
          return obj.toString();
        }
        if (obj instanceof Date) {
          return obj.toISOString();
        }
        if (Array.isArray(obj)) {
          return obj.map(convertDecimals);
        }
        if (typeof obj === 'object') {
          if (mongoose.Types.ObjectId.isValid(obj) && typeof obj.toString === 'function' && obj.toString().length === 24) {
            const str = obj.toString();
            if (/^[0-9a-fA-F]{24}$/.test(str)) {
              return str;
            }
          }
          const result = {};
          for (const key of Object.keys(obj)) {
            result[key] = convertDecimals(obj[key]);
          }
          return result;
        }
        return obj;
      }
      return convertDecimals(ret);
    }
  },
  toObject: {
    transform: function(doc, ret) {
      function convertDecimals(obj) {
        if (obj === null || obj === undefined) return obj;
        if (obj.constructor && obj.constructor.name === 'Decimal128') {
          return parseFloat(obj.toString());
        }
        if (obj.constructor && (obj.constructor.name === 'ObjectId' || obj._bsontype === 'ObjectID' || obj._bsontype === 'ObjectId')) {
          return obj.toString();
        }
        if (obj instanceof Date) {
          return obj.toISOString();
        }
        if (Array.isArray(obj)) {
          return obj.map(convertDecimals);
        }
        if (typeof obj === 'object') {
          if (mongoose.Types.ObjectId.isValid(obj) && typeof obj.toString === 'function' && obj.toString().length === 24) {
            const str = obj.toString();
            if (/^[0-9a-fA-F]{24}$/.test(str)) {
              return str;
            }
          }
          const result = {};
          for (const key of Object.keys(obj)) {
            result[key] = convertDecimals(obj[key]);
          }
          return result;
        }
        return obj;
      }
      return convertDecimals(ret);
    }
  }
});

// Generar folio automático antes de guardar
ventaSchema.pre('save', async function(next) {
  if (this.isNew) {
    const year = new Date().getFullYear();
    const count = await mongoose.model('Venta').countDocuments();
    this.folio = `V-${year}-${(count + 1).toString().padStart(5, '0')}`;
  }
  next();
});

module.exports = mongoose.model('Venta', ventaSchema);