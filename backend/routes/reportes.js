const express = require('express');
const router = express.Router();
const reporteController = require('../controllers/reporteController');
const { verificarToken, esAdmin } = require('../middleware/authMiddleware');

// Reportes financieros y de rendimiento restringidos a administradores
router.get('/resumen', verificarToken, esAdmin, reporteController.getResumenVentas);
router.get('/ventas/dia', verificarToken, reporteController.getVentasDelDia);
router.get('/productos/top', verificarToken, esAdmin, reporteController.getProductosMasVendidos);
router.get('/productos/bajo-stock', verificarToken, reporteController.getProductosBajoStock);
router.get('/ventas/por-empleado', verificarToken, esAdmin, reporteController.getVentasPorEmpleado);

module.exports = router;