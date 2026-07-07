const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const { register, login, verifyToken } = require('../controllers/authController');
const { authLimiter } = require('../middleware/rateLimiters');
const { handleValidationErrors } = require('../middleware/handleValidation');
const { loginValidators, registerValidators } = require('../validators/authValidators');

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

module.exports = router;
