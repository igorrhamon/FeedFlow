// Versão simplificada do proxy para debug
const express = require('express');
const fs = require('fs');
const path = require('path');

// Arquivo de log para erros
const logDir = path.join(__dirname, "..", "logs");
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}
const logFile = fs.createWriteStream(path.join(logDir, 'proxy-debug.log'), { flags: 'a' });

// Tratamento de erros global para evitar que o processo termine inesperadamente
process.on('uncaughtException', (err) => {
  const errorMsg = `[${new Date().toISOString()}] Erro não tratado capturado: ${err.stack}\n`;
  console.error(errorMsg);
  logFile.write(errorMsg);
});

process.on('unhandledRejection', (reason, promise) => {
  const errorMsg = `[${new Date().toISOString()}] Promessa rejeitada não tratada: ${reason}\n`;
  console.error(errorMsg);
  logFile.write(errorMsg);
});

const app = express();
const PORT = process.env.PORT || 3001; // Usando porta diferente para este teste

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rota simples de teste
app.get('/', (req, res) => {
  res.send('Proxy de Debug está funcionando!');
});

// Rota de eco para testar requisições (Authorization header redacted)
app.all('/echo', (req, res) => {
  try {
    const safeHeaders = { ...req.headers };
    if (safeHeaders.authorization) {
      safeHeaders.authorization = safeHeaders.authorization.substring(0, 20) + '...[REDACTED]';
    }
    res.json({
      method: req.method,
      headers: safeHeaders,
      query: req.query,
      body: req.body,
      url: req.url
    });
  } catch (error) {
    const errorMsg = `[${new Date().toISOString()}] Erro na rota /echo: ${error.stack}\n`;
    console.error(errorMsg);
    logFile.write(errorMsg);
    res.status(500).json({ error: error.message });
  }
});

// Registra quando o servidor inicia
const server = app.listen(PORT, () => {
  const msg = `[${new Date().toISOString()}] Servidor de debug rodando em http://localhost:${PORT}\n`;
  console.log(msg);
  logFile.write(msg);
});

// Tratamento para quando o servidor é encerrado
server.on('close', () => {
  const msg = `[${new Date().toISOString()}] Servidor encerrado\n`;
  console.log(msg);
  logFile.write(msg);
});

// Captura sinais de encerramento para limpar recursos
process.on('SIGINT', () => {
  const msg = `[${new Date().toISOString()}] Recebeu SIGINT, encerrando...\n`;
  console.log(msg);
  logFile.write(msg);
  server.close(() => {
    process.exit(0);
  });
});

process.on('SIGTERM', () => {
  const msg = `[${new Date().toISOString()}] Recebeu SIGTERM, encerrando...\n`;
  console.log(msg);
  logFile.write(msg);
  server.close(() => {
    process.exit(0);
  });
});
