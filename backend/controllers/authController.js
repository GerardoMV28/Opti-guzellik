const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Registro de usuarios (solo para crear usuarios de prueba)
exports.register = async (req, res) => {
  try {
    const { nombre, email, password, rol, telefono } = req.body;
    
    // Verificar si el usuario ya existe
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'El email ya está registrado' });
    }
    
    // Encriptar contraseña
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);
    
    // Crear usuario
    const user = new User({
      nombre,
      email,
      password: hashedPassword,
      rol,
      telefono
    });
    
    await user.save();
    
    res.status(201).json({ 
      message: 'Usuario creado exitosamente',
      user: {
        id: user._id,
        nombre: user.nombre,
        email: user.email,
        rol: user.rol
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Login
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const emailTrim = (email || '').trim();
    if (!emailTrim) {
      return res.status(400).json({ message: 'El correo es obligatorio' });
    }

    const escapeRegex = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const user = await User.findOne({
      email: new RegExp(`^${escapeRegex(emailTrim)}$`, 'i'),
      activo: true,
    });
    
    if (!user) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
    }

    // Verificar contraseña
    const isMatch = await bcrypt.compare(password, user.password);

    
    if (!isMatch) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
    }
    
    // Crear token
    const tokenPayload = jwt.sign(
      {
        id: user._id.toString(),
        email: user.email,
        rol: user.rol,
      },
      process.env.JWT_SECRET,
      { expiresIn: '8h' }
    );

    res.json({
      token: tokenPayload,
      user: {
        id: user._id,
        nombre: user.nombre,
        email: user.email,
        rol: user.rol
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Cambiar la propia contraseña (usuario autenticado)
exports.changePassword = async (req, res) => {
  try {
    const { passwordActual, passwordNueva } = req.body;

    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    const isMatch = await bcrypt.compare(passwordActual, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'La contraseña actual es incorrecta' });
    }

    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(passwordNueva, salt);
    await user.save();

    res.json({ message: 'Contraseña actualizada correctamente' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Verificar token (para mantener sesión)
exports.verifyToken = async (req, res) => {
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
      return res.status(401).json({ message: 'Token requerido' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id).select('-password');
    
    if (!user) {
      return res.status(401).json({ message: 'Usuario no encontrado' });
    }
    
    res.json({ user });
  } catch (error) {
    res.status(401).json({ message: 'Token inválido' });
  }
};