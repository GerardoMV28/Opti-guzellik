const Venta = require('../models/Venta');
const Producto = require('../models/Producto');
const Usuario = require('../models/User');

// Obtener resumen de ventas por período
exports.getResumenVentas = async (req, res) => {
  try {
    const { inicio, fin } = req.query;
    
    // Convertir strings a fechas
    const fechaInicio = new Date(inicio);
    const fechaFin = new Date(fin);
    fechaFin.setHours(23, 59, 59, 999);
    
    // Obtener todas las ventas en el período
    const estadosContabilizados = ['entregado', 'listo_entrega', 'garantia', 'cortesia', 'reproceso'];
    const ventas = await Venta.find({
      fecha: { $gte: fechaInicio, $lte: fechaFin },
      estado: { $in: estadosContabilizados }
    });

    // Calcular totales
    let totalVentas = 0;
    let efectivo = 0;
    let tarjeta = 0;
    let transferencia = 0;

    ventas.forEach(venta => {
      // Convertir Decimal128 a número
      const total = parseFloat(venta.total.toString());
      totalVentas += total;
      
      switch (venta.forma_pago) {
        case 'efectivo':
          efectivo += total;
          break;
        case 'tarjeta':
          tarjeta += total;
          break;
        case 'transferencia':
          transferencia += total;
          break;
        case 'mixto':
          // Para pagos mixtos, sumar cada parte
          if (venta.detalle_pago_mixto) {
            efectivo += parseFloat(venta.detalle_pago_mixto.efectivo?.toString() || 0);
            tarjeta += parseFloat(venta.detalle_pago_mixto.tarjeta?.toString() || 0);
            transferencia += parseFloat(venta.detalle_pago_mixto.transferencia?.toString() || 0);
          }
          break;
      }
    });

    const cantidadVentas = ventas.length;
    const promedioVenta = cantidadVentas > 0 ? totalVentas / cantidadVentas : 0;

    res.json({
      totalVentas,
      cantidadVentas,
      efectivo,
      tarjeta,
      transferencia,
      promedioVenta
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Obtener ventas del día
// Obtener ventas del día
exports.getVentasDelDia = async (req, res) => {
  try {
    const hoy = new Date();
    hoy.setHours(0, 0, 0, 0);
    
    const manana = new Date(hoy);
    manana.setDate(manana.getDate() + 1);

    // Obtener ventas del día (completadas o en proceso)
    const ventas = await Venta.find({
      fecha: { $gte: hoy, $lt: manana },
      activo: true
    }).sort({ fecha: -1 });
    
    ventas.forEach(venta => {
    });

    // Formatear ventas para el frontend
    const ventasFormateadas = ventas.map(venta => ({
      _id: venta._id,
      fecha: venta.fecha,
      vendedor: venta.vendedor,
      total: parseFloat(venta.total.toString()),
      cantidadProductos: venta.productos.length,
      forma_pago: venta.forma_pago,
      estado: venta.estado
    }));
    
    res.json(ventasFormateadas);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Obtener productos más vendidos
exports.getProductosMasVendidos = async (req, res) => {
  try {
    const { inicio, fin, limite = 10 } = req.query;
    
    const fechaInicio = new Date(inicio);
    const fechaFin = new Date(fin);
    fechaFin.setHours(23, 59, 59, 999);

    // Obtener ventas completadas en el período
    const ventas = await Venta.find({
      fecha: { $gte: fechaInicio, $lte: fechaFin },
      estado: { $in: ['entregado', 'listo_entrega', 'garantia', 'cortesia', 'reproceso'] }
    });

    // Agrupar por producto
    const productosMap = new Map();

    ventas.forEach(venta => {
      venta.productos.forEach(item => {
        const productoId = item.producto_id.toString();
        if (!productosMap.has(productoId)) {
          productosMap.set(productoId, {
            _id: productoId,
            nombre: item.nombre,
            tipo: item.tipo,
            cantidad: 0,
            total: 0
          });
        }
        const prod = productosMap.get(productoId);
        prod.cantidad += item.cantidad;
        prod.total += parseFloat(item.subtotal.toString());
      });
    });

    // Convertir a array y ordenar
    const productosTop = Array.from(productosMap.values())
      .sort((a, b) => b.cantidad - a.cantidad)
      .slice(0, parseInt(limite));

    res.json(productosTop);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Obtener productos con stock bajo
exports.getProductosBajoStock = async (req, res) => {
  try {
    const productos = await Producto.find({
      $expr: { $lte: ['$stock', '$stock_minimo'] },
      activo: true
    }).select('nombre codigo stock stock_minimo');

    res.json(productos);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Obtener ventas por empleado
exports.getVentasPorEmpleado = async (req, res) => {
  try {
    const { inicio, fin } = req.query;
    
    const fechaInicio = new Date(inicio);
    const fechaFin = new Date(fin);
    fechaFin.setHours(23, 59, 59, 999);

    // Obtener ventas completadas agrupadas por vendedor
    const ventas = await Venta.aggregate([
      {
        $match: {
          fecha: { $gte: fechaInicio, $lte: fechaFin },
          estado: { $in: ['entregado', 'listo_entrega', 'garantia', 'cortesia', 'reproceso'] }
        }
      },
      {
        $group: {
          _id: '$vendedor',
          total: { $sum: { $toDouble: '$total' } },
          cantidad: { $sum: 1 }
        }
      },
      {
        $sort: { total: -1 }
      }
    ]);

    // Convertir a objeto clave-valor
    const resultado = {};
    ventas.forEach(item => {
      if (item._id) {
        resultado[item._id] = item.total;
      }
    });

    res.json(resultado);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Obtener todas las ventas (con filtros opcionales)
exports.getVentas = async (req, res) => {
  try {
    const { inicio, fin, estado, vendedor } = req.query;
    const filtro = { activo: true };
    
    // Filtro por fechas
    if (inicio && fin) {
      const fechaInicio = new Date(inicio);
      const fechaFin = new Date(fin);
      fechaFin.setHours(23, 59, 59, 999);
      filtro.fecha = { $gte: fechaInicio, $lte: fechaFin };
    }
    
    // Filtro por estado
    if (estado) {
      filtro.estado = estado;
    }
    
    // Filtro por vendedor
    if (vendedor) {
      filtro.vendedor = vendedor;
    }
    
    const ventas = await Venta.find(filtro)
      .sort({ fecha: -1 })
      .populate('vendedor_id', 'nombre')
      .populate('paciente_id', 'nombre telefono');
    
    // Formatear ventas para el frontend
    const ventasFormateadas = ventas.map(venta => ({
      _id: venta._id,
      folio: venta.folio,
      fecha: venta.fecha,
      vendedor: venta.vendedor,
      paciente_nombre: venta.paciente_nombre,
      total: parseFloat(venta.total.toString()),
      anticipo: parseFloat(venta.anticipo.toString()),
      saldo_pendiente: parseFloat(venta.saldo_pendiente.toString()),
      forma_pago: venta.forma_pago,
      estado: venta.estado,
      productos: venta.productos.map(p => ({
        nombre: p.nombre,
        cantidad: p.cantidad,
        subtotal: parseFloat(p.subtotal.toString())
      }))
    }));
    
    res.json(ventasFormateadas);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Obtener estadísticas completas para dashboard
exports.getDashboardStats = async (req, res) => {
  try {
    const hoy = new Date();
    hoy.setHours(0, 0, 0, 0);
    
    const manana = new Date(hoy);
    manana.setDate(manana.getDate() + 1);
    
    const inicioMes = new Date(hoy.getFullYear(), hoy.getMonth(), 1);
    const finMes = new Date(hoy.getFullYear(), hoy.getMonth() + 1, 0);
    finMes.setHours(23, 59, 59, 999);
    
    // Ventas del día
    const ventasHoy = await Venta.find({
      fecha: { $gte: hoy, $lt: manana },
      estado: { $in: ['entregado', 'listo_entrega', 'garantia', 'cortesia', 'reproceso'] }
    });
    
    let totalHoy = 0;
    ventasHoy.forEach(v => { totalHoy += parseFloat(v.total.toString()); });
    
    // Ventas del mes
    const ventasMes = await Venta.find({
      fecha: { $gte: inicioMes, $lte: finMes },
      estado: { $in: ['entregado', 'listo_entrega', 'garantia', 'cortesia', 'reproceso'] }
    });
    
    let totalMes = 0;
    ventasMes.forEach(v => { totalMes += parseFloat(v.total.toString()); });
    
    // Productos con stock bajo
    const productosBajoStock = await Producto.countDocuments({
      $expr: { $lte: ['$stock', '$stock_minimo'] },
      activo: true
    });
    
    // Clientes registrados (pacientes)
    const Paciente = require('../models/Paciente');
    const totalClientes = await Paciente.countDocuments({ activo: true });
    
    // Ventas pendientes de entrega
    const ventasPendientes = await Venta.countDocuments({
      estado: { $in: ['por_enviar', 'laboratorio', 'garantia', 'cortesia', 'reproceso'] },
      activo: true
    });
    
    res.json({
      ventasHoy: ventasHoy.length,
      totalHoy,
      ventasMes: ventasMes.length,
      totalMes,
      productosBajoStock,
      totalClientes,
      ventasPendientes
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Obtener ventas por estado
exports.getVentasPorEstado = async (req, res) => {
  try {
    const estados = ['por_enviar', 'laboratorio', 'garantia', 'cortesia', 'reproceso', 'listo_entrega', 'entregado', 'cancelado'];
    const resultado = {};
    
    for (const estado of estados) {
      const count = await Venta.countDocuments({ estado, activo: true });
      resultado[estado] = count;
    }
    
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Obtener productos con stock bajo (versión detallada)
exports.getProductosBajoStockDetallado = async (req, res) => {
  try {
    const productos = await Producto.find({
      $expr: { $lte: ['$stock', '$stock_minimo'] },
      activo: true
    }).select('nombre codigo stock stock_minimo tipo marca');
    
    const resultado = productos.map(p => ({
      id: p._id,
      nombre: p.nombre,
      codigo: p.codigo,
      stock: p.stock,
      stock_minimo: p.stock_minimo,
      tipo: p.tipo,
      marca: p.marca
    }));
    
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};