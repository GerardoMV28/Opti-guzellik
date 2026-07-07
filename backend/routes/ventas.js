const express = require('express');
const router = express.Router();
const ventaController = require('../controllers/ventaController');
const { verificarToken, esAdmin } = require('../middleware/authMiddleware');
const { mongoIdParam } = require('../middleware/mongoId');

router.use(verificarToken);

router.get('/', ventaController.getVentas);
router.get('/fechas', ventaController.getVentasByFecha);

router.get(
  '/paciente/:pacienteId',
  mongoIdParam('pacienteId'),
  ventaController.getVentasByPaciente
);

router.get('/:id', mongoIdParam(), ventaController.getVentaById);
router.post('/', ventaController.createVenta);
router.patch('/:id/estado', mongoIdParam(), ventaController.updateEstado);
router.patch('/:id/pago', mongoIdParam(), ventaController.updatePago);
router.delete('/:id', esAdmin, mongoIdParam(), ventaController.cancelarVenta);

router.post('/:id/abono', mongoIdParam(), ventaController.registrarAbono);
router.get('/:id/abonos', mongoIdParam(), ventaController.getHistorialAbonos);

module.exports = router;
