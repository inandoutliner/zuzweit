/* Zu zweit: App-Hülle offline verfügbar halten (Flugzeug, Camper).
   Die Daten selbst laufen nie über diesen Speicher, nur Seite, Schriften und Bibliothek. */
const CACHE = 'zuzweit-1002';
const SHELL = ['./', './index.html', './config.js', './apple-touch-icon.png'];
self.addEventListener('install', (e) => { e.waitUntil(caches.open(CACHE).then((c) => c.addAll(SHELL)).then(() => self.skipWaiting())); });
self.addEventListener('activate', (e) => { e.waitUntil(caches.keys().then((ks) => Promise.all(ks.filter((k) => k !== CACHE).map((k) => caches.delete(k)))).then(() => self.clients.claim())); });
self.addEventListener('fetch', (e) => {
  const req = e.request; if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (url.hostname.endsWith('supabase.co')) return;            // Daten nie zwischenspeichern
  const own = url.origin === location.origin;
  const lib = /fonts\.(googleapis|gstatic)\.com$|cdn\.jsdelivr\.net$/.test(url.hostname);
  if (!own && !lib) return;
  if (own) {                                                    // erst Netz (für Updates), sonst Speicher
    e.respondWith(fetch(req).then((r) => { const c = r.clone(); caches.open(CACHE).then((k) => k.put(req, c)); return r; })
      .catch(() => caches.match(req, { ignoreSearch: true }).then((r) => r || caches.match('./index.html'))));
  } else {                                                      // Schriften, Bibliothek: erst Speicher
    e.respondWith(caches.match(req).then((r) => r || fetch(req).then((n) => { const c = n.clone(); caches.open(CACHE).then((k) => k.put(req, c)); return n; })));
  }
});
