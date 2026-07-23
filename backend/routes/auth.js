const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const { register, login, verifyToken, changePassword } = require('../controllers/authController');
const { authLimiter } = require('../middleware/rateLimiters');
const { handleValidationErrors } = require('../middleware/handleValidation');
const { verificarToken } = require('../middleware/authMiddleware');
const {
  loginValidators,
  registerValidators,
  changePasswordValidators,
} = require('../validators/authValidators');

router.post(
  '/register',
  (req, res, next) => {
    if (process.env.ALLOW_REGISTER !== 'true') {
      return res.status(403).json({
        message: 'El registro público está deshabilitado. Contacta al administrador.',
      });
    }
    next();
  },
  authLimiter,
  registerValidators,
  handleValidationErrors,
  register
);

router.post('/login', authLimiter, loginValidators, handleValidationErrors, login);

router.get('/verify', verifyToken);

router.put(
  '/cambiar-password',
  verificarToken,
  authLimiter,
  changePasswordValidators,
  handleValidationErrors,
  changePassword
);

module.exports = router;
