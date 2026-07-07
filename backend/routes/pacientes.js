const express = require('express');
const router = express.Router();
const pacienteController = require('../controllers/pacienteController');
const { verificarToken } = require('../middleware/authMiddleware');
const { mongoIdParam } = require('../middleware/mongoId');

router.use(verificarToken);

router.get('/', pacienteController.getPacientes);
router.get('/buscar', pacienteController.buscarPacientes);

router.get('/:id', mongoIdParam(), pacienteController.getPacienteById);
router.post('/', pacienteController.createPaciente);
router.put('/:id', mongoIdParam(), pacienteController.updatePaciente);
router.delete('/:id', mongoIdParam(), pacienteController.deletePaciente);
router.post('/:id/consultas', mongoIdParam(), pacienteController.addConsulta);

module.exports = router;
