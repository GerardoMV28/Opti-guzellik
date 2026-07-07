const express = require('express');
const router = express.Router();
const reporteController = require('../controllers/reporteController');
const { verificarToken } = require('../middleware/authMiddleware');

// Todas las rutas de reportes requieren autenticación
router.get('/resumen', verificarToken, reporteController.getResumenVentas);
router.get('/ventas/dia', verificarToken, reporteController.getVentasDelDia);
router.get('/productos/top', verificarToken, reporteController.getProductosMasVendidos);
router.get('/productos/bajo-stock', verificarToken, reporteController.getProductosBajoStock);
router.get('/ventas/por-empleado', verificarToken, reporteController.getVentasPorEmpleado);

module.exports = router;