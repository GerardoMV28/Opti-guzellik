/**
 * Falla rápido si faltan variables críticas (evita arrancar con JWT débil o sin BD).
 */
function assertRequiredEnv() {
  const missing = [];
  if (!process.env.MONGODB_URI || String(process.env.MONGODB_URI).trim() === '') {
    missing.push('MONGODB_URI');
  }
  if (!process.env.JWT_SECRET || String(process.env.JWT_SECRET).trim() === '') {
    missing.push('JWT_SECRET');
  }
  if (process.env.JWT_SECRET && process.env.NODE_ENV === 'production' && process.env.JWT_SECRET.length < 24) {
    throw new Error('JWT_SECRET debe tener al menos 24 caracteres en producción.');
  }
  if (missing.length) {
    throw new Error(`Variables de entorno faltantes: ${missing.join(', ')}`);
  }
}

module.exports = { assertRequiredEnv };
