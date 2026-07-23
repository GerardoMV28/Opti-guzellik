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
    const { nombre, email, rol, telefono, activo, password } = req.body;

    const datosActualizar = { nombre, email, rol, telefono, activo };

    // La contraseña es opcional en la edición: solo se toca si el admin
    // decide restablecerla (no hay recuperación por correo en este sistema).
    if (password) {
      const salt = await bcrypt.genSalt(10);
      datosActualizar.password = await bcrypt.hash(password, salt);
    }

    // Buscar y actualizar
    const user = await User.findByIdAndUpdate(
      req.params.id,
      datosActualizar,
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

// Verifica que desactivar a este usuario no deje al sistema sin administradores activos
async function bloqueaUltimoAdmin(idObjetivo, req) {
  if (String(req.userId) === String(idObjetivo)) {
    return 'No puedes eliminar o desactivar tu propia cuenta';
  }
  const objetivo = await User.findById(idObjetivo);
  if (objetivo && objetivo.rol === 'admin' && objetivo.activo) {
    const otrosAdminsActivos = await User.countDocuments({
      rol: 'admin',
      activo: true,
      _id: { $ne: idObjetivo },
    });
    if (otrosAdminsActivos === 0) {
      return 'Debe existir al menos un administrador activo';
    }
  }
  return null;
}

// Eliminar usuario permanentemente (uso: limpiar cuentas de prueba).
// Es irreversible a propósito: para solo desactivar sin borrar, usar toggleActivo.
exports.deleteUsuario = async (req, res) => {
  try {
    const bloqueo = await bloqueaUltimoAdmin(req.params.id, req);
    if (bloqueo) {
      return res.status(400).json({ message: bloqueo });
    }

    const user = await User.findByIdAndDelete(req.params.id).select('-password');

    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    res.json({ message: 'Usuario eliminado permanentemente', user });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Activar/Desactivar usuario
exports.toggleActivo = async (req, res) => {
  try {
    const { activo } = req.body;

    if (activo === false) {
      const bloqueo = await bloqueaUltimoAdmin(req.params.id, req);
      if (bloqueo) {
        return res.status(400).json({ message: bloqueo });
      }
    }

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