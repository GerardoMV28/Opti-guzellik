/**
 * Genera hash bcrypt para crear/actualizar usuarios en la BD.
 * Uso (no guardes la contraseña en el código):
 *   node generate_hash.js "TuContraseñaSegura123"
 */
const bcrypt = require('bcryptjs');

async function main() {
  const password = process.argv[2];
  if (!password || password.length < 8) {
    console.error('Uso: node generate_hash.js "<contraseña>" (mínimo 8 caracteres)');
    process.exit(1);
  }
  const salt = await bcrypt.genSalt(12);
  const hash = await bcrypt.hash(password, salt);
  console.log(hash);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
