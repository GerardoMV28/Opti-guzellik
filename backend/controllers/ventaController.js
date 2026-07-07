const Venta = require('../models/Venta');
const Producto = require('../models/Producto');
const mongoose = require('mongoose');

// Obtener todas las ventas
exports.getVentas = async (req, res) => {
  try {
    const ventas = await Venta.find({ activo: true })
      .sort({ fecha: -1 })
      .populate('vendedor_id', 'nombre')
      .populate('paciente_id', 'nombre telefono');
    
    res.json(ventas);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Obtener ventas por rango de fechas
exports.getVentasByFecha = async (req, res) => {
  try {
    const { inicio, fin } = req.query;
    
    if (!inicio || !fin) {
      return res.status(400).json({ message: 'Se requieren fechas de inicio y fin' });
    }
    
    const fechaInicio = new Date(inicio);
    const fechaFin = new Date(fin);
    fechaFin.setHours(23, 59, 59, 999);
    
    const ventas = await Venta.find({
      fecha: { $gte: fechaInicio, $lte: fechaFin },
      activo: true
    }).sort({ fecha: -1 });
    
    res.json(ventas);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Obtener venta por ID
exports.getVentaById = async (req, res) => {
  try {
    const venta = await Venta.findById(req.params.id)
      .populate('vendedor_id', 'nombre')
      .populate('paciente_id', 'nombre telefono');
    
    if (!venta) {
      return res.status(404).json({ message: 'Venta no encontrada' });
    }
    
    res.json(venta);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Crear venta (SIN TRANSACCIONES - pero con validación previa)
exports.createVenta = async (req, res) => {
  try {
    
    // 1. Validar datos básicos
    if (!req.body.productos || req.body.productos.length === 0) {
      return res.status(400).json({ message: 'La venta debe tener al menos un producto' });
    }

    if (req.body.paciente_id != null && req.body.paciente_id !== '') {
      if (!mongoose.Types.ObjectId.isValid(req.body.paciente_id)) {
        return res.status(400).json({ message: 'paciente_id inválido' });
      }
    }
    
    // 2. PRIMERO: Verificar stock disponible para TODOS los productos
    const productosAActualizar = [];
    
    for (const item of req.body.productos) {
      if (!item.producto_id || !mongoose.Types.ObjectId.isValid(item.producto_id)) {
        return res.status(400).json({ message: 'producto_id inválido en una línea de la venta' });
      }
      
      const producto = await Producto.findById(item.producto_id);
      if (!producto) {
        return res.status(404).json({ 
          message: `Producto ${item.nombre} no encontrado` 
        });
      }
      
      const stockActual = producto.stock;
      
      if (stockActual < item.cantidad) {
        return res.status(400).json({ 
          message: `Stock insuficiente para ${item.nombre}. Disponible: ${stockActual}, Solicitado: ${item.cantidad}` 
        });
      }
      
      // Guardar para actualizar después
      productosAActualizar.push({
        id: item.producto_id,
        nombre: producto.nombre,
        stockActual: stockActual,
        cantidad: item.cantidad,
        nuevoStock: stockActual - item.cantidad
      });
    }
    
    const numVal = (v) => {
      if (v == null || v === '') return 0;
      if (typeof v === 'number') return v;
      if (typeof v === 'string') return parseFloat(v) || 0;
      if (v.$numberDecimal != null) return parseFloat(v.$numberDecimal) || 0;
      if (typeof v.toString === 'function') return parseFloat(v.toString()) || 0;
      return 0;
    };

    // Validar líneas de producto (descuentos y subtotales)
    let sumaBruta = 0;
    let sumaDescuentosLinea = 0;
    for (const item of req.body.productos) {
      const pu = numVal(item.precio_unitario);
      const cant = parseInt(item.cantidad, 10) || 0;
      const desc = numVal(item.descuento);
      const sub = numVal(item.subtotal);
      const bruto = pu * cant;
      sumaBruta += bruto;
      sumaDescuentosLinea += desc;
      if (desc < 0 || desc > bruto + 0.02) {
        return res.status(400).json({
          message: `Descuento inválido para ${item.nombre || 'producto'} (máx. ${bruto.toFixed(2)})`
        });
      }
      const esperado = bruto - desc;
      if (Math.abs(sub - esperado) > 0.02) {
        return res.status(400).json({
          message: `Subtotal inconsistente para ${item.nombre || 'producto'}`
        });
      }
    }

    const subtotalReq = numVal(req.body.subtotal);
    const descTotalReq = numVal(req.body.descuento_total);
    const totalReq = numVal(req.body.total);
    if (Math.abs(subtotalReq - sumaBruta) > 0.05) {
      return res.status(400).json({ message: 'Subtotal de venta no coincide con la suma de productos' });
    }
    if (Math.abs(descTotalReq - sumaDescuentosLinea) > 0.05) {
      return res.status(400).json({ message: 'Descuento total no coincide con la suma de descuentos por línea' });
    }
    if (Math.abs(totalReq - (sumaBruta - descTotalReq)) > 0.05) {
      return res.status(400).json({ message: 'Total de venta incorrecto' });
    }

    // 3. Preparar datos de la venta
    const ventaData = {
      fecha: req.body.fecha || new Date(),
      vendedor: req.body.vendedor,
      vendedor_id: req.body.vendedor_id,
      paciente_id: req.body.paciente_id || null,
      paciente_nombre: req.body.paciente_nombre || null,
      paciente_telefono: req.body.paciente_telefono || null,
      productos: req.body.productos,
      subtotal: req.body.subtotal,
      descuento_total: req.body.descuento_total || 0,
      total: req.body.total,
      anticipo: req.body.anticipo || 0,
      saldo_pendiente: (req.body.total || 0) - (req.body.anticipo || 0),
      forma_pago: req.body.forma_pago,
      detalle_pago_mixto: req.body.detalle_pago_mixto || null,
      fecha_entrega: req.body.fecha_entrega || null,
      estado: req.body.estado || 'por_enviar',
      notas: req.body.notas || '',
      activo: true
    };
    
    // Asegurar que saldo_pendiente no sea negativo
    if (ventaData.saldo_pendiente < 0) ventaData.saldo_pendiente = 0;
    
    // Agregar historial inicial
    ventaData.historial_estados = [{
      estado: ventaData.estado,
      fecha: new Date(),
      nota: 'Venta registrada',
      actualizado_por: req.body.vendedor || 'Sistema'
    }];
    

    // 4. Crear la venta
    const venta = new Venta(ventaData);
    await venta.save();
    
    // 5. ACTUALIZAR STOCK (después de crear la venta)
    for (const item of productosAActualizar) {
      await Producto.findByIdAndUpdate(
        item.id,
        { $inc: { stock: -item.cantidad } }
      );
    }
    
    // 6. Actualizar paciente con la venta (si aplica)
    if (req.body.paciente_id) {
      const Paciente = require('../models/Paciente');
      await Paciente.findByIdAndUpdate(
        req.body.paciente_id,
        { $push: { ventas: venta._id } }
      );
    }
    
    res.status(201).json(venta);
    
  } catch (error) {
    // Verificar si es error de validación de MongoDB
    if (error.name === 'MongoServerError' && error.code === 121) {
      return res.status(400).json({ 
        message: 'Error de validación de datos. Verifica que todos los campos requeridos estén presentes.',
      });
    }
    
    if (error.name === 'ValidationError') {
      const errores = {};
      for (const field in error.errors) {
        errores[field] = error.errors[field].message;
      }
      return res.status(400).json({ 
        message: 'Error de validación', 
        errors: errores 
      });
    }
    
    res.status(400).json({ message: error.message });
  }
};

// Actualizar estado de venta
exports.updateEstado = async (req, res) => {
  try {
    const { estado, nota } = req.body;
    const { id } = req.params;

    const estadosPermitidos = [
      'por_enviar',
      'laboratorio',
      'garantia',
      'cortesia',
      'reproceso',
      'listo_entrega',
      'entregado',
      'cancelado',
    ];
    if (!estado || !estadosPermitidos.includes(estado)) {
      return res.status(400).json({ message: 'Estado no válido' });
    }
    const notaSegura =
      typeof nota === 'string' ? nota.trim().slice(0, 500) : '';
    
    const venta = await Venta.findById(id);
    if (!venta) {
      return res.status(404).json({ message: 'Venta no encontrada' });
    }
    
    venta.estado = estado;
    venta.historial_estados.push({
      estado,
      nota: notaSegura || `Estado actualizado a ${estado}`,
      actualizado_por: req.user?.nombre || 'Sistema'
    });
    
    await venta.save();
    
    res.json(venta);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Actualizar pago (abono)
exports.updatePago = async (req, res) => {
  try {
    const { anticipo } = req.body;
    const { id } = req.params;
    
    const venta = await Venta.findById(id);
    if (!venta) {
      return res.status(404).json({ message: 'Venta no encontrada' });
    }
    
    venta.anticipo += anticipo;
    venta.saldo_pendiente = venta.total - venta.anticipo;
    
    if (venta.saldo_pendiente <= 0) {
      venta.saldo_pendiente = 0;
      if (venta.estado === 'por_enviar') {
        venta.estado = 'listo_entrega';
      }
    }
    
    await venta.save();
    
    res.json(venta);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Cancelar venta (con reversión de stock)
exports.cancelarVenta = async (req, res) => {
  try {
    const { id } = req.params;
    
    const venta = await Venta.findById(id);
    if (!venta) {
      return res.status(404).json({ message: 'Venta no encontrada' });
    }
    
    // Revertir stock
    for (const item of venta.productos) {
      await Producto.findByIdAndUpdate(
        item.producto_id,
        { $inc: { stock: item.cantidad } }
      );
    }
    
    venta.activo = false;
    venta.estado = 'cancelado';
    venta.historial_estados.push({
      estado: 'cancelado',
      nota: 'Venta cancelada',
      actualizado_por: req.user?.nombre || 'Sistema'
    });
    
    await venta.save();
    
    res.json({ message: 'Venta cancelada correctamente', venta });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Registrar un nuevo abono
// Registrar un nuevo abono (CORREGIDO para Decimal128)
exports.registrarAbono = async (req, res) => {
  try {
    const { monto, forma_pago, nota } = req.body;
    const { id } = req.params;

    // ✅ Validar y convertir monto a número
    let montoNum;
    if (typeof monto === 'number') {
      montoNum = monto;
    } else if (typeof monto === 'string') {
      montoNum = parseFloat(monto);
    } else {
      return res.status(400).json({ message: 'Monto inválido' });
    }
    
    if (isNaN(montoNum) || montoNum <= 0) {
      return res.status(400).json({ message: 'Monto inválido' });
    }
    
    const venta = await Venta.findById(id);
    if (!venta) {
      return res.status(404).json({ message: 'Venta no encontrada' });
    }
    
    // ✅ Convertir Decimal128 a números para operaciones
    const anticipoActual = parseFloat(venta.anticipo.toString());
    const saldoActual = parseFloat(venta.saldo_pendiente.toString());
    const totalVenta = parseFloat(venta.total.toString());
    
    if (saldoActual < montoNum) {
      return res.status(400).json({ 
        message: `El saldo pendiente es ${saldoActual}. No se puede abonar más de lo debido.` 
      });
    }
    
    // Registrar el abono
    const abono = {
      monto: montoNum,
      forma_pago: forma_pago || 'efectivo',
      registrado_por: req.user?.nombre || 'Sistema',
      nota: nota || '',
      fecha: new Date()
    };
    
    if (!venta.historial_abonos) {
      venta.historial_abonos = [];
    }
    venta.historial_abonos.push(abono);
    
    // ✅ Sumar correctamente como números
    const nuevoAnticipo = anticipoActual + montoNum;
    const nuevoSaldo = totalVenta - nuevoAnticipo;

    venta.anticipo = nuevoAnticipo;
    venta.saldo_pendiente = nuevoSaldo < 0 ? 0 : nuevoSaldo;
    
    // Si se liquidó, cambiar estado automáticamente
    if (venta.saldo_pendiente <= 0) {
      venta.saldo_pendiente = 0;
      if (venta.estado === 'por_enviar') {
        venta.estado = 'listo_entrega';
        venta.historial_estados.push({
          estado: 'listo_entrega',
          nota: 'Pago completado automáticamente',
          actualizado_por: req.user?.nombre || 'Sistema'
        });
      }
    }
    
    await venta.save();
    
    res.json(venta);
    
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Obtener historial de abonos de una venta
exports.getHistorialAbonos = async (req, res) => {
  try {
    const { id } = req.params;
    const venta = await Venta.findById(id).select('historial_abonos');
    
    if (!venta) {
      return res.status(404).json({ message: 'Venta no encontrada' });
    }
    
    res.json(venta.historial_abonos || []);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Obtener ventas de un paciente
exports.getVentasByPaciente = async (req, res) => {
  try {
    const { pacienteId } = req.params;
    
    const ventas = await Venta.find({ 
      paciente_id: pacienteId,
      activo: true 
    }).sort({ fecha: -1 });
    
    res.json(ventas);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};