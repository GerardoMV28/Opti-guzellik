const mongoose = require('mongoose');

function mongoIdParam(paramName = 'id') {
  return (req, res, next) => {
    const raw = req.params[paramName];
    if (!raw || !mongoose.Types.ObjectId.isValid(raw)) {
      return res.status(400).json({ message: 'Identificador no válido' });
    }
    next();
  };
}

module.exports = { mongoIdParam };
