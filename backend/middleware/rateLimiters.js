const rateLimit = require('express-rate-limit');

/** Limita intentos de login/registro para mitigar fuerza bruta. */
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.' },
});

/** API general (capa adicional; rutas sensibles pueden tener límites propios). */
const apiLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 200,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Límite de solicitudes excedido. Intenta más tarde.' },
});

module.exports = { authLimiter, apiLimiter };
