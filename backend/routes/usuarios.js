const express = require('express');
const router = express.Router();
const usuarioController = require('../controllers/usuarioController');
const { verificarToken, esAdmin } = require('../middleware/authMiddleware');
const { mongoIdParam } = require('../middleware/mongoId');

router.use(verificarToken);
router.use(esAdmin);

router.get('/', usuarioController.getUsuarios);
router.get('/:id', mongoIdParam(), usuarioController.getUsuarioById);
router.post('/', usuarioController.createUsuario);
router.put('/:id', mongoIdParam(), usuarioController.updateUsuario);
router.delete('/:id', mongoIdParam(), usuarioController.deleteUsuario);
router.patch('/:id', mongoIdParam(), usuarioController.toggleActivo);

module.exports = router;
