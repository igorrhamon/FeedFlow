// Simple proxy for The Old Reader API to bypass CORS for Flutter Web
const express = require("express");
const cors = require("cors");
const os = require("os");
const { exec } = require("child_process");
const net = require("net");
const fs = require("fs");
const path = require("path");

// Log file setup
const logDir = path.join(__dirname, "logs");
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}
const logFile = fs.createWriteStream(path.join(logDir, "proxy.log"), { flags: "a" });

function log(message) {
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] ${message}\n`;
  console.log(message);
  logFile.write(logMessage);
}

// Determine if a port is available
function isPortAvailable(port) {
  return new Promise((resolve) => {
    const server = net.createServer();
    
    server.once('error', () => {
      resolve(false);
    });
    
    server.once('listening', () => {
      server.close();
      resolve(true);
    });
    
    server.listen(port);
  });
}

// Find an available port starting from the given port
async function findAvailablePort(startPort) {
  let port = startPort;
  while (port < startPort + 100) { // Try 100 ports
    if (await isPortAvailable(port)) {
      return port;
    }
    port++;
  }
  return null;
}

// Try to identify the process using a port (Windows only)
function getProcessUsingPort(port) {
  return new Promise((resolve) => {
    exec(`netstat -ano | findstr :${port} | findstr LISTENING`, (error, stdout) => {
      if (error || !stdout) {
        resolve(null);
        return;
      }
      
      const match = stdout.match(/LISTENING\s+(\d+)/);
      if (!match || !match[1]) {
        resolve(null);
        return;
      }
      
      const pid = match[1];
      exec(`tasklist /fi "PID eq ${pid}" /fo csv /nh`, (error, stdout) => {
        if (error || !stdout) {
          resolve({ pid });
          return;
        }
        
        const parts = stdout.split(',');
        if (parts.length >= 2) {
          const processName = parts[0].replace(/"/g, '');
          resolve({ pid, name: processName });
        } else {
          resolve({ pid });
        }
      });
    });
  });
}

// Verifica se fetch está disponível globalmente (Node.js 18+) 
// ou se precisa ser importado (Node.js 16 ou anterior)
let fetch;
try {
  // Para Node.js <18
  if (!globalThis.fetch) {
    fetch = require("node-fetch");
    log("Usando node-fetch");
  } else {
    fetch = globalThis.fetch;
    log("Usando fetch global");
  }
} catch (err) {
  log(`Erro ao configurar fetch: ${err.message}`);
  log("Se você estiver usando Node.js <18, instale node-fetch com: npm install node-fetch");
  process.exit(1);
}

// Tratamento de erros global para evitar que o processo termine inesperadamente
process.on('uncaughtException', (err) => {
  log('Erro não tratado capturado:');
  log(err.toString());
  log(err.stack);
  fs.appendFileSync(path.join(logDir, 'proxy-error.log'), `[${new Date().toISOString()}] Uncaught Exception: ${err.stack}\n`);
  // Não terminamos o processo, permitindo que ele continue funcionando
});

process.on('unhandledRejection', (reason, promise) => {
  log('Promessa rejeitada não tratada:');
  log(reason.toString());
  fs.appendFileSync(path.join(logDir, 'proxy-error.log'), `[${new Date().toISOString()}] Unhandled Rejection: ${reason}\n`);
  // Não terminamos o processo, permitindo que ele continue funcionando
});

const app = express();
let PORT = process.env.PORT || 3000;

app.use(cors({ origin: /localhost|127\.0\.0\.1/ }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const API_BASE = "https://theoldreader.com/reader/api/0";
const AUTH_BASE = "https://theoldreader.com";


// Proxy para o endpoint web de favoritos (starred posts)
app.get("/proxy/posts/starred", async (req, res) => {
  const url = "https://theoldreader.com/posts/starred?_pjax=%5Bdata-behavior%3Dcontents%5D";
  const cookies = req.headers["cookie"];
  try {
    log(`[GET] Proxying starred posts to: ${url}`);
    const response = await fetch(url, {
      headers: cookies ? { 'Cookie': cookies } : {},
    });
    const data = await response.text();
    log(`[GET] Received response from starred posts (${response.status})`);
    res.status(response.status).send(data);
  } catch (err) {
    log(`[GET] Error (starred posts): ${err.message}`);
    res.status(500).json({ error: err.message });
  }
});

// Proxy GET requests (Express RegExp route for compatibility)
app.get(/^\/proxy\/(.*)/, async (req, res) => {
  const apiPath = req.params[0];
  // Garante que output=json só é adicionado para endpoints que aceitam esse parâmetro
  let url = `${API_BASE}/${apiPath}`;
  
  // Adiciona output=json para endpoints conhecidos que suportam
  const endpointsWithJson = [
    'subscription/list',
    'user-info',
    'unread-count',
    'preference/list',
    'tag/list',
    'friend/list',
    'stream/contents',
    'stream/contents/feed',
  ];
  
  // Se o endpoint começa com algum dos acima, adiciona output=json
  if (endpointsWithJson.some(e => apiPath.startsWith(e))) {
    // Só adiciona se não existir na URL
    if (!url.includes('output=')) {
      url += url.includes('?') ? '&output=json' : '?output=json';
    }
  }
  
  log(`[GET] Proxying to: ${url}`);
  const auth = req.headers['authorization'];
  
  try {
    const headers = {};
    if (auth) headers['Authorization'] = auth;

    const response = await fetch(url, { headers });
    const contentType = response.headers.get('content-type') || '';

    let data;
    let isJson = false;
    // Sempre leia o body como texto primeiro
    const rawText = await response.text();
    if (contentType.includes('application/json')) {
      try {
        data = JSON.parse(rawText);
        isJson = true;
      } catch (err) {
        log(`[GET] Aviso: Falha ao fazer parse JSON, retornando como texto. Erro: ${err.message}`);
        data = rawText;
      }
    } else {
      data = rawText;
    }

    log(`[GET] Received response from ${url} (${response.status}) [content-type: ${contentType}]`);

    // Se não for JSON, envie header apropriado
    if (!isJson) {
      res.set('Content-Type', contentType || 'text/plain');
    }
    res.status(response.status).send(data);
  } catch (err) {
    log(`[GET] Error (${url}): ${err.message}`);
    res.status(500).json({ error: err.message });
  }
});

// Handler especial para o endpoint quickadd para fins de debug
app.post("/proxy/subscription/quickadd", (req, res, next) => {
  log("[POST] Recebida requisição para quickadd");
  
  // Registra query params
  log(`[POST] Query params: ${JSON.stringify(req.query)}`);
  
  // Registra body
  log(`[POST] Body: ${JSON.stringify(req.body)}`);
  
  // Continua para o handler geral
  next();
});

// Proxy POST requests (Express RegExp route for compatibility)
app.post(/^\/proxy\/(.*)/, async (req, res) => {
  let apiPath = req.params[0];
  
  // Se for autenticação, use AUTH_BASE, senão API_BASE
  const isAuth = apiPath.startsWith('accounts/ClientLogin');
  
  // Verifica se é uma requisição de quickadd (adicionar feed)
  const isQuickadd = apiPath.includes('subscription/quickadd');
  
  // Preserva parâmetros da URL original para requisições que precisam deles
  let url;
  if (isQuickadd) {
    // Se for quickadd, garanta que o parâmetro quickadd esteja na URL
    let quickaddParam = req.query.quickadd;
    
    // Se não estiver na query, procura no body
    if (!quickaddParam && req.body && req.body.quickadd) {
      quickaddParam = req.body.quickadd;
      log("[POST] Encontrado parâmetro quickadd no body. Movendo para URL.");
    }
    
    // Constrói a URL com o parâmetro na query string
    if (quickaddParam) {
      // Remove o parâmetro da URL original para evitar duplicação
      apiPath = apiPath.replace(/\?.*$/, '');
      url = `${API_BASE}/${apiPath}?quickadd=${encodeURIComponent(quickaddParam)}`;
      log(`[POST] Quickadd URL: ${url}`);
    } else {
      // Se não encontrou, usa a URL original (provavelmente vai falhar)
      url = `${API_BASE}/${apiPath}`;
      log("[POST] AVISO: Parâmetro quickadd não encontrado na query nem no body!");
    }
  } else {
    // Para outros endpoints, mantém a URL original
    url = isAuth ? `${AUTH_BASE}/${apiPath}` : `${API_BASE}/${apiPath}`;
    
    // Preserva query string para outros endpoints
    if (Object.keys(req.query).length > 0) {
      const queryString = new URLSearchParams(req.query).toString();
      url += url.includes('?') ? `&${queryString}` : `?${queryString}`;
    }
  }
  
  const auth = req.headers['authorization'];
  log(`[POST] Proxying to: ${url}`);
  
  try {
    const headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    
    if (auth) headers['Authorization'] = auth;
    
    // Especial para quickadd: não envie o parâmetro quickadd no body
    // se ele já foi movido para a URL
    let body = req.body;
    if (isQuickadd && body && body.quickadd) {
      const { quickadd, ...restBody } = body;
      body = restBody;
    }
    
    // Converte o body para formato URL encoded se for um objeto
    let bodyToSend;
    if (typeof body === 'object' && body !== null) {
      bodyToSend = new URLSearchParams(body).toString();
    } else {
      bodyToSend = req.rawBody || '';
    }
    
    const response = await fetch(url, {
      method: 'POST',
      headers,
      body: bodyToSend
    });
    
    const contentType = response.headers.get('content-type');
    let data;
    
    if (contentType && contentType.includes('application/json')) {
      data = await response.json();
    } else {
      data = await response.text();
    }
    
    log(`[POST] Received response from ${url} (${response.status})`);
    
    // Registra resposta para diagnóstico
    if (isQuickadd) {
      log(`[POST] Quickadd response: ${JSON.stringify(data)}`);
    }
    
    res.status(response.status).send(data);
  } catch (err) {
    log(`[POST] Error (${url}): ${err.message}`);
    res.status(500).json({ error: err.message });
  }
});

// Função principal para iniciar o servidor
async function startServer() {
  // Verifica se a porta padrão está disponível
  const isAvailable = await isPortAvailable(PORT);
  
  if (!isAvailable) {
    // Tenta obter informações sobre o processo usando a porta
    const processInfo = await getProcessUsingPort(PORT);
    
    if (processInfo) {
      log(`ERRO: A porta ${PORT} já está em uso.`);
      log(`Processo usando a porta: ${processInfo.name || 'desconhecido'} (PID: ${processInfo.pid})`);
      log(`Para encerrar este processo, execute: taskkill /F /PID ${processInfo.pid}`);
    } else {
      log(`ERRO: A porta ${PORT} já está em uso.`);
    }
    
    // Tenta encontrar uma porta alternativa
    const alternativePort = await findAvailablePort(PORT + 1);
    
    if (alternativePort) {
      log(`Tentando porta alternativa: ${alternativePort}`);
      PORT = alternativePort;
    } else {
      log("Não foi possível encontrar uma porta alternativa disponível.");
      process.exit(1);
    }
  }
  
  app.listen(PORT, () => {
    log(`Proxy server running on http://localhost:${PORT}`);
    log(`Importante: Se você estiver usando a porta ${PORT}, certifique-se de atualizar a baseUrl no OldReaderApi.dart:`);
    log(`static const String baseUrl = 'http://localhost:${PORT}/proxy'`);
  });
}

// Inicia o servidor
startServer();
