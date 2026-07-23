const { body } = require('express-validator');

const createUsuarioValidators = [
  body('nombre')
    .trim()
    .notEmpty()
    .withMessage('El nombre es obligatorio')
    .isLength({ min: 2, max: 120 })
    .withMessage('El nombre debe tener entre 2 y 120 caracteres')
    .matches(/^[\p{L}\p{N}\s.'\-]+$/u)
    .withMessage('El nombre contiene caracteres no permitidos'),
  body('email')
    .trim()
    .notEmpty()
    .withMessage('El correo es obligatorio')
    .isLength({ max: 255 })
    .withMessage('Correo demasiado largo')
    .isEmail()
    .withMessage('Formato de correo inválido')
    .normalizeEmail(),
  body('password')
    .isString()
    .withMessage('Contraseña inválida')
    .isLength({ min: 8, max: 128 })
    .withMessage('La contraseña debe tener entre 8 y 128 caracteres')
    .matches(/[A-Za-z]/)
    .withMessage('La contraseña debe incluir al menos una letra')
    .matches(/[0-9]/)
    .withMessage('La contraseña debe incluir al menos un número'),
  body('rol')
    .optional()
    .isIn(['admin', 'empleado'])
    .withMessage('Rol no válido'),
  body('telefono')
    .optional({ values: 'falsy' })
    .trim()
    .isLength({ max: 30 })
    .withMessage('Teléfono demasiado largo')
    .matches(/^[0-9+\s\-().]*$/)
    .withMessage('Teléfono con formato no permitido'),
];

const updateUsuarioValidators = [
  body('nombre')
    .optional()
    .trim()
    .isLength({ min: 2, max: 120 })
    .withMessage('El nombre debe tener entre 2 y 120 caracteres')
    .matches(/^[\p{L}\p{N}\s.'\-]+$/u)
    .withMessage('El nombre contiene caracteres no permitidos'),
  body('email')
    .optional()
    .trim()
    .isLength({ max: 255 })
    .withMessage('Correo demasiado largo')
    .isEmail()
    .withMessage('Formato de correo inválido')
    .normalizeEmail(),
  body('rol')
    .optional()
    .isIn(['admin', 'empleado'])
    .withMessage('Rol no válido'),
  body('telefono')
    .optional({ values: 'falsy' })
    .trim()
    .isLength({ max: 30 })
    .withMessage('Teléfono demasiado largo')
    .matches(/^[0-9+\s\-().]*$/)
    .withMessage('Teléfono con formato no permitido'),
  body('activo')
    .optional()
    .isBoolean()
    .withMessage('Activo debe ser verdadero o falso'),
  body('password')
    .optional({ values: 'falsy' })
    .isString()
    .withMessage('Contraseña inválida')
    .isLength({ min: 8, max: 128 })
    .withMessage('La contraseña debe tener entre 8 y 128 caracteres')
    .matches(/[A-Za-z]/)
    .withMessage('La contraseña debe incluir al menos una letra')
    .matches(/[0-9]/)
    .withMessage('La contraseña debe incluir al menos un número'),
];

module.exports = { createUsuarioValidators, updateUsuarioValidators };
