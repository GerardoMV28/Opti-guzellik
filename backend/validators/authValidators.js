const { body } = require('express-validator');

const loginValidators = [
  body('email')
    .trim()
    .notEmpty()
    .withMessage('El correo es obligatorio')
    .isLength({ max: 255 })
    .withMessage('Correo demasiado largo')
    .isEmail()
    .withMessage('Formato de correo inválido'),
  // No usar .normalizeEmail() en login: altera el string y puede dejar de coincidir
  // con el valor guardado en MongoDB (mayúsculas, dominios, etc.) → 401 falso.
  body('password')
    .isString()
    .withMessage('Contraseña inválida')
    .isLength({ min: 1, max: 128 })
    .withMessage('Longitud de contraseña no permitida'),
];

const registerValidators = [
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
    .isLength({ max: 255 })
    .isEmail()
    .withMessage('Correo inválido')
    .normalizeEmail(),
  body('password')
    .isString()
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

const changePasswordValidators = [
  body('passwordActual')
    .isString()
    .withMessage('Contraseña actual inválida')
    .notEmpty()
    .withMessage('La contraseña actual es obligatoria'),
  body('passwordNueva')
    .isString()
    .withMessage('Contraseña inválida')
    .isLength({ min: 8, max: 128 })
    .withMessage('La nueva contraseña debe tener entre 8 y 128 caracteres')
    .matches(/[A-Za-z]/)
    .withMessage('La nueva contraseña debe incluir al menos una letra')
    .matches(/[0-9]/)
    .withMessage('La nueva contraseña debe incluir al menos un número'),
];

module.exports = { loginValidators, registerValidators, changePasswordValidators };
