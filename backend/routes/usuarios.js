const express = require('express');
const router = express.Router();
const usuarioController = require('../controllers/usuarioController');
const { verificarToken, esAdmin } = require('../middleware/authMiddleware');
const { mongoIdParam } = require('../middleware/mongoId');
const { handleValidationErrors } = require('../middleware/handleValidation');
const {
  createUsuarioValidators,
  updateUsuarioValidators,
} = require('../validators/usuarioValidators');

router.use(verificarToken);
router.use(esAdmin);

router.get('/', usuarioController.getUsuarios);
router.get('/:id', mongoIdParam(), usuarioController.getUsuarioById);
router.post('/', createUsuarioValidators, handleValidationErrors, usuarioController.createUsuario);
router.put(
  '/:id',
  mongoIdParam(),
  updateUsuarioValidators,
  handleValidationErrors,
  usuarioController.updateUsuario
);
router.delete('/:id', mongoIdParam(), usuarioController.deleteUsuario);
router.patch('/:id', mongoIdParam(), usuarioController.toggleActivo);

module.exports = router;
