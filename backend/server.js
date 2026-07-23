require('dotenv').config();

// En algunas configuraciones de Windows, el resolver de DNS de Node.js no
// logra consultar registros SRV (usados por las URI mongodb+srv:// de
// Atlas), aunque herramientas como mongosh sí puedan. Forzar un DNS público
// conocido evita el error "querySrv ECONNREFUSED" al conectar con Atlas.
require('dns').setServers(['8.8.8.8', '8.8.4.4']);

const { assertRequiredEnv } = require('./middleware/envGuard');

try {
  assertRequiredEnv();
} catch (e) {
  console.error('[config]', e.message);
  process.exit(1);
}

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const { apiLimiter } = require('./middleware/rateLimiters');

const app = express();

app.use(
  helmet({
    crossOriginResourcePolicy: { policy: 'cross-origin' },
  })
);

const corsOrigin = process.env.CORS_ORIGIN;
app.use(
  cors({
    origin: corsOrigin && corsOrigin !== '*' ? corsOrigin : true,
    credentials: true,
  })
);

app.use(express.json({ limit: '256kb' }));
app.use(express.urlencoded({ extended: true, limit: '256kb' }));

app.use('/api', apiLimiter);

mongoose
  .connect(process.env.MONGODB_URI)
  .then(() => console.log('Conectado a MongoDB'))
  .catch((err) => console.error('Error:', err));

app.use('/api/auth', require('./routes/auth'));
app.use('/api/usuarios', require('./routes/usuarios'));
app.use('/api/productos', require('./routes/productos'));
app.use('/api/reportes', require('./routes/reportes'));
app.use('/api/pacientes', require('./routes/pacientes'));
app.use('/api/ventas', require('./routes/ventas'));
app.use('/api/dashboard', require('./routes/dashboard'));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
