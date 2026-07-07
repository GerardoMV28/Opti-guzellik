const Producto = require('../models/Producto');

// Obtener todos los productos (con filtros opcionales)
exports.getProductos = async (req, res) => {
  try {    
    const { tipo, activo, search } = req.query;
    let filtro = {};
    
    // Aplicar filtros si existen
    if (tipo) filtro.tipo = tipo;
    if (activo !== undefined) filtro.activo = activo === 'true';
    
    // Búsqueda por texto en nombre, código o marca
    if (search) {
      filtro.$or = [
        { nombre: { $regex: search, $options: 'i' } },
        { codigo: { $regex: search, $options: 'i' } },
        { marca: { $regex: search, $options: 'i' } }
      ];
    }

    const productos = await Producto.find(filtro).sort({ fecha_alta: -1 });

    
    res.json(productos);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Obtener productos con stock bajo
exports.getProductosBajoStock = async (req, res) => {
  try {
    const productos = await Producto.find({
      $expr: { $lte: ['$stock', '$stock_minimo'] },
      activo: true
    });
    res.json(productos);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Obtener producto por ID
exports.getProductoById = async (req, res) => {
  try {
    const producto = await Producto.findById(req.params.id);
    if (!producto) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }
    res.json(producto);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Crear producto
exports.createProducto = async (req, res) => {
  try {

    // Verificar si ya existe un producto con el mismo código
    const existingProduct = await Producto.findOne({ codigo: req.body.codigo });
    if (existingProduct) {
      return res.status(400).json({ message: 'Ya existe un producto con este código' });
    }
    
    const producto = new Producto({
      ...req.body,
      fecha_modificacion: new Date()
    });
    
    const nuevoProducto = await producto.save();
    res.status(201).json(nuevoProducto);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Actualizar producto
exports.updateProducto = async (req, res) => {
  try {
    
    // Verificar si el código ya existe en otro producto
    if (req.body.codigo) {
      const existingProduct = await Producto.findOne({
        codigo: req.body.codigo,
        _id: { $ne: req.params.id }
      });
      if (existingProduct) {
        return res.status(400).json({ message: 'Ya existe otro producto con este código' });
      }
    }
    
    const producto = await Producto.findByIdAndUpdate(
      req.params.id,
      { ...req.body, fecha_modificacion: new Date() },
      { new: true, runValidators: true }
    );
    
    if (!producto) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }

    res.json(producto);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Eliminar producto (soft delete)
exports.deleteProducto = async (req, res) => {
  try {
    
    const producto = await Producto.findByIdAndUpdate(
      req.params.id,
      { activo: false, fecha_modificacion: new Date() },
      { new: true }
    );
    
    if (!producto) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }
    
    res.json({ message: 'Producto desactivado correctamente', producto });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Actualizar stock
exports.updateStock = async (req, res) => {
  try {
    
    const { stock } = req.body;
    
    if (stock === undefined || stock < 0) {
      return res.status(400).json({ message: 'Stock inválido' });
    }
    
    const producto = await Producto.findByIdAndUpdate(
      req.params.id,
      { stock, fecha_modificacion: new Date() },
      { new: true }
    );
    
    if (!producto) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }

    res.json(producto);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Activar/Desactivar producto
exports.toggleActivo = async (req, res) => {
  try {

    
    const { activo } = req.body;
    
    const producto = await Producto.findByIdAndUpdate(
      req.params.id,
      { activo, fecha_modificacion: new Date() },
      { new: true }
    );
    
    if (!producto) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }
    
    res.json(producto);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};