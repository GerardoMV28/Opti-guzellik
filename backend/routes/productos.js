const express = require('express');
const router = express.Router();
const productoController = require('../controllers/productoController');
const { verificarToken, esAdminOEmpleado } = require('../middleware/authMiddleware');
const { mongoIdParam } = require('../middleware/mongoId');

router.get('/', verificarToken, productoController.getProductos);
router.get('/bajo-stock', verificarToken, productoController.getProductosBajoStock);

router.get('/:id', verificarToken, mongoIdParam(), productoController.getProductoById);

router.post('/', verificarToken, esAdminOEmpleado, productoController.createProducto);
router.put('/:id', verificarToken, esAdminOEmpleado, mongoIdParam(), productoController.updateProducto);
router.delete('/:id', verificarToken, esAdminOEmpleado, mongoIdParam(), productoController.deleteProducto);
router.patch('/:id/stock', verificarToken, esAdminOEmpleado, mongoIdParam(), productoController.updateStock);
router.patch('/:id/toggle', verificarToken, esAdminOEmpleado, mongoIdParam(), productoController.toggleActivo);

module.exports = router;
