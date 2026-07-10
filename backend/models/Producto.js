const mongoose = require('mongoose');

const productoSchema = new mongoose.Schema({
  tipo: { 
    type: String, 
    enum: ['armazon', 'mica', 'lente_contacto', 'accesorio'],
    required: true 
  },
  codigo: { type: String, required: true, unique: true },
  nombre: { type: String, required: true },
  descripcion: String,
  marca: String,
  modelo: String,
  imagenes: [String],
  
  // Precios
  precios: {
    costo: { type: Number, required: true },
    precio_venta: { type: Number, required: true }
  },
  
  // Stock
  stock: { type: Number, default: 0 },
  stock_minimo: { type: Number, default: 5 },
  
  // Campos específicos para armazones
  armazon: {
    material: String,
    color: String,
    forma: String,
    medidas: {
      alto: Number,
      ancho: Number,
      puente: Number,
      varilla: Number
    },
    genero: { type: String, enum: ['hombre', 'mujer', 'unisex'] }
  },
  
  // Campos específicos para micas
  mica: {
    presentacion: String,
    material: String,
    color: String,
    tratamientos: [String],
    serie: String,
    rango_graduacion: String,
    fabricante: String
  },

  // Campos específicos para lentes de contacto
  lente_contacto: {
    tipo: String,
    marca_lc: String,
    diseno: String,
    material: String,
    reemplazo: String,
    parametros: String,
    color: String
  },
  
  activo: { type: Boolean, default: true },
  fecha_alta: { type: Date, default: Date.now },
  fecha_modificacion: Date
});


module.exports = mongoose.model('Producto', productoSchema);