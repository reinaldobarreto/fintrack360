// Reseta a senha do usuário admin@fintrack.com para admin1234 usando Firebase Admin SDK.
// Uso:
// 1) Gere a chave de conta de serviço no Firebase Console (Project Settings → Service accounts → Generate new private key)
// 2) Instale dependência: npm install firebase-admin
// 3) Execute: node scripts/reset_admin_password.js <caminho_para_serviceAccount.json>

const admin = require('firebase-admin');
const path = require('path');

function init() {
  const credPathArg = process.argv[2];
  const credPathEnv = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  const credPath = credPathArg || credPathEnv;
  if (!credPath) {
    console.error('Defina GOOGLE_APPLICATION_CREDENTIALS ou passe o caminho do JSON como argumento.');
    process.exit(1);
  }

  const absolute = path.resolve(credPath);
  // Carrega credenciais do Service Account
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const serviceAccount = require(absolute);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

async function run() {
  try {
    init();
    const email = 'admin@fintrack.com';
    const novaSenha = 'admin1234';

    const user = await admin.auth().getUserByEmail(email);
    await admin.auth().updateUser(user.uid, { password: novaSenha });
    console.log(`Senha redefinida com sucesso para ${email} → ${novaSenha}`);
    process.exit(0);
  } catch (e) {
    console.error('Erro ao redefinir senha:', e);
    process.exit(1);
  }
}

run();