// backend/routes/dashboard.js
const express = require('express');
const router = express.Router();
const Venta = require('../models/Venta');
const Producto = require('../models/Producto');
const { verificarToken } = require('../middleware/authMiddleware');

// Todas las rutas requieren autenticación
router.use(verificarToken);

// Obtener estadísticas del dashboard
router.get('/stats', async (req, res) => {
  try {
    const hoy = new Date();
    hoy.setHours(0, 0, 0, 0);
    
    const manana = new Date(hoy);
    manana.setDate(manana.getDate() + 1);

    const inicioMes = new Date(hoy.getFullYear(), hoy.getMonth(), 1);

    // Ventas de hoy
    const ventasHoy = await Venta.find({
      fecha: { $gte: hoy, $lt: manana }
    });

    const totalVentasHoy = ventasHoy.reduce((sum, venta) => sum + parseFloat(venta.total || 0), 0);
    
    // Clientes únicos hoy
    const clientesHoy = [...new Set(ventasHoy.map(v => v.paciente_id).filter(id => id))].length;
    
    // Productos totales y stock bajo
    let totalProductos = 0;
    let productosBajosStock = 0;
    
    try {
      totalProductos = await Producto.countDocuments();
      productosBajosStock = await Producto.countDocuments({ 
        stock: { $lt: 10 } 
      });
    } catch (err) {
      console.log('Error contando productos:', err.message);
    }
    
    // Ingresos del mes
    const ventasMes = await Venta.find({
      fecha: { $gte: inicioMes }
    });
    const ingresosMes = ventasMes.reduce((sum, venta) => sum + parseFloat(venta.total || 0), 0);

    // Ventas por método de pago
    const efectivo = ventasHoy
      .filter(v => v.forma_pago === 'efectivo')
      .reduce((sum, v) => sum + parseFloat(v.total || 0), 0);
    
    const tarjeta = ventasHoy
      .filter(v => v.forma_pago === 'tarjeta')
      .reduce((sum, v) => sum + parseFloat(v.total || 0), 0);
    
    const transferencia = ventasHoy
      .filter(v => v.forma_pago === 'transferencia')
      .reduce((sum, v) => sum + parseFloat(v.total || 0), 0);

    // Ventas de hoy formateadas
    const ventasDelDia = ventasHoy.map(venta => ({
      id: venta._id,
      hora: venta.fecha ? `${venta.fecha.getHours().toString().padStart(2, '0')}:${venta.fecha.getMinutes().toString().padStart(2, '0')}` : '--:--',
      cliente: venta.paciente_nombre || 'Cliente general',
      total: parseFloat(venta.total),
      estado: venta.estado,
      formaPago: venta.forma_pago
    }));

    // Próximas entregas (ventas con fecha de entrega próxima y no entregadas)
    const proximasEntregas = await Venta.find({
      fecha_entrega: { $gte: hoy, $lte: manana },
      estado: { $ne: 'entregado' }
    }).limit(5);

    const entregasFormateadas = proximasEntregas.map(venta => ({
      id: venta._id,
      cliente: venta.paciente_nombre || 'Cliente',
      hora: venta.fecha_entrega ? `${venta.fecha_entrega.getHours()}:${venta.fecha_entrega.getMinutes()}` : '--:--',
      tipo: venta.productos && venta.productos.length > 0 ? venta.productos[0].nombre : 'Producto'
    }));

    res.json({
      success: true,
      data: {
        ventasHoy: totalVentasHoy,
        clientesHoy: clientesHoy,
        totalProductos: totalProductos,
        productosBajosStock: productosBajosStock,
        ingresosMes: ingresosMes,
        efectivoHoy: efectivo,
        tarjetaHoy: tarjeta,
        transferenciaHoy: transferencia,
        ventasDelDia: ventasDelDia,
        proximasEntregas: entregasFormateadas,
        totalVentasHoyCount: ventasHoy.length
      }
    });
  } catch (error) {
    console.error('Error en dashboard stats:', error);
    res.status(500).json({ error: error.message });
  }
});

// Obtener ventas del día específico
router.get('/ventas/dia/:fecha?', async (req, res) => {
  try {
    let fecha = req.params.fecha ? new Date(req.params.fecha) : new Date();
    fecha.setHours(0, 0, 0, 0);
    
    const finDia = new Date(fecha);
    finDia.setDate(finDia.getDate() + 1);

    const ventas = await Venta.find({
      fecha: { $gte: fecha, $lt: finDia }
    }).sort({ fecha: -1 });

    // Convertir Decimal128 a números
    const ventasFormateadas = ventas.map(venta => {
      const obj = venta.toObject();
      return {
        ...obj,
        total: parseFloat(obj.total),
        subtotal: parseFloat(obj.subtotal),
        anticipo: parseFloat(obj.anticipo),
        saldo_pendiente: parseFloat(obj.saldo_pendiente)
      };
    });

    res.json(ventasFormateadas);
  } catch (error) {
    console.error('Error en ventas/dia:', error);
    res.status(500).json({ error: error.message });
  }
});

// Obtener productos con stock bajo
router.get('/productos/stock-bajo', async (req, res) => {
  try {
    const productos = await Producto.find({
      stock: { $lt: 10 }
    }).sort({ stock: 1 }).limit(20);
    
    res.json(productos);
  } catch (error) {
    console.error('Error en stock-bajo:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;