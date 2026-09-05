const VERSAO = '3.1.2';
const CACHE = 'caixa-v' + VERSAO;

const ESSENCIAIS = [
  './',
  './index.html',
  './config.js',
  './manifest.webmanifest',
  './icon.svg'
];

self.addEventListener('install', (evento) => {
  evento.waitUntil(
    caches.open(CACHE)
      .then((cache) => cache.addAll(ESSENCIAIS))
      .catch(() => undefined)
  );
});

self.addEventListener('activate', (evento) => {
  evento.waitUntil(
    caches.keys()
      .then((chaves) => Promise.all(
        chaves.filter((chave) => chave !== CACHE).map((chave) => caches.delete(chave))
      ))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('message', (evento) => {
  const dados = evento.data || {};
  if (dados.tipo === 'PULAR_ESPERA') self.skipWaiting();
  if (dados.tipo === 'VERSAO' && evento.source) {
    evento.source.postMessage({ tipo: 'VERSAO', versao: VERSAO });
  }
});

// Rede primeiro, com reserva no cache.
self.addEventListener('fetch', (evento) => {
  const req = evento.request;
  if (req.method !== 'GET') return;

  const url = new URL(req.url);
  if (url.origin !== self.location.origin) return;

  evento.respondWith(
    fetch(req)
      .then((resposta) => {
        if (resposta && resposta.ok && resposta.type === 'basic') {
          const copia = resposta.clone();
          caches.open(CACHE).then((cache) => cache.put(req, copia)).catch(() => undefined);
        }
        return resposta;
      })
      .catch(() => caches.match(req).then((emCache) => {
        if (emCache) return emCache;
        if (req.mode === 'navigate') return caches.match('./index.html');
        return Response.error();
      }))
  );
});
