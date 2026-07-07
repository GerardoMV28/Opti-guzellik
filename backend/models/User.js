const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  nombre: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  rol: { type: String, enum: ['admin', 'empleado'], default: 'empleado' },
  telefono: String,
  activo: { type: Boolean, default: true },
  fecha_registro: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Usuario', userSchema); 