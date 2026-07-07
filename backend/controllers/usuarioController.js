const User = require('../models/User');
const bcrypt = require('bcryptjs');

// Obtener todos los usuarios
exports.getUsuarios = async (req, res) => {
  try {
    const usuarios = await User.find().select('-password');
    res.json(usuarios);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Obtener un usuario por ID
exports.getUsuarioById = async (req, res) => {
  try {
    const usuario = await User.findById(req.params.id).select('-password');
    if (!usuario) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    res.json(usuario);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Crear usuario (empleado)
exports.createUsuario = async (req, res) => {
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
      rol: rol || 'empleado',
      telefono
    });
    
    await user.save();
    
    // No enviar la contraseña en la respuesta
    const userResponse = user.toObject();
    delete userResponse.password;
    
    res.status(201).json(userResponse);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Actualizar usuario
exports.updateUsuario = async (req, res) => {
  try {
    const { nombre, email, rol, telefono, activo } = req.body;
    
    // Buscar y actualizar
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { nombre, email, rol, telefono, activo },
      { new: true }
    ).select('-password');
    
    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Eliminar usuario (soft delete - desactivar)
exports.deleteUsuario = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { activo: false },
      { new: true }
    ).select('-password');
    
    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    
    res.json({ message: 'Usuario desactivado correctamente', user });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Activar/Desactivar usuario
exports.toggleActivo = async (req, res) => {
  try {
    const { activo } = req.body;
    
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { activo },
      { new: true }
    ).select('-password');
    
    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};