// backend/middleware/authMiddleware.js
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Verificar token
exports.verificarToken = async (req, res, next) => {
  try {
    const authHeader = req.header('Authorization');
    const raw =
      typeof authHeader === 'string' && authHeader.startsWith('Bearer ')
        ? authHeader.slice(7).trim()
        : '';

    const token =
      raw && raw !== 'null' && raw !== 'undefined'
        ? raw
        : null;

    if (!token) {
      return res.status(401).json({ message: 'Acceso denegado. Token requerido.' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id).select('-password');
    
    if (!user) {
      return res.status(401).json({ message: 'Usuario no encontrado' });
    }
    
    if (!user.activo) {
      return res.status(401).json({ message: 'Usuario inactivo' });
    }
    
    req.user = user;
    req.userId = decoded.id;
    req.userRol = decoded.rol;
    
    next();
  } catch (error) {
    console.error('Error en verificarToken:', error);
    res.status(401).json({ message: 'Token inválido' });
  }
};

// Verificar si es admin
exports.esAdmin = (req, res, next) => {
  if (req.userRol !== 'admin') {
    return res.status(403).json({ message: 'Acceso denegado. Se requiere rol de administrador.' });
  }
  next();
};

// Verificar si es admin o empleado
exports.esAdminOEmpleado = (req, res, next) => {
  if (req.userRol !== 'admin' && req.userRol !== 'empleado') {
    return res.status(403).json({ message: 'Acceso denegado. Se requiere rol de administrador o empleado.' });
  }
  next();
};