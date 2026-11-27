/* Zu zweit: App-Hülle und Kartenkacheln offline verfügbar halten (Flugzeug, Camper).
   Die Daten selbst laufen nie über diesen Speicher. */
const CACHE = 'zuzweit-1003';
const TILES = 'zuzweit-kacheln';
const SHELL = ['./', './index.html', './config.js', './apple-touch-icon.png', './lib/leaflet/leaflet.js', './lib/leaflet/leaflet.css'];
self.addEventListener('install', (e) => { e.waitUntil(caches.open(CACHE).then((c) => c.addAll(SHELL)).then(() => self.skipWaiting())); });
self.addEventListener('activate', (e) => { e.waitUntil(caches.keys().then((ks) => Promise.all(ks.filter((k) => k !== CACHE && k !== TILES).map((k) => caches.delete(k)))).then(() => self.clients.claim())); });
async function trimTiles() {
  const c = await caches.open(TILES); const ks = await c.keys();
  if (ks.length > 6000) await Promise.all(ks.slice(0, ks.length - 5000).map((k) => c.delete(k)));
}
let puts = 0;
self.addEventListener('fetch', (e) => {
  const req = e.request; if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (url.hostname.endsWith('supabase.co') || url.hostname.endsWith('openstreetmap.org')) return; // Daten und Suche nie zwischenspeichern
  if (url.hostname.endsWith('basemaps.cartocdn.com')) {          // Kacheln: einmal gesehen = offline da
    e.respondWith(caches.open(TILES).then((c) => c.match(req).then((r) => r || fetch(req).then((n) => {
      if (n.ok || n.type === 'opaque') { c.put(req, n.clone()); if (++puts % 200 === 0) trimTiles(); }
      return n;
    }))));
    return;
  }
  const own = url.origin === location.origin;
  const lib = /fonts\.(googleapis|gstatic)\.com$|cdn\.jsdelivr\.net$/.test(url.hostname);
  if (!own && !lib) return;
  if (own) {                                                       // erst Netz (für Updates), sonst Speicher
    e.respondWith(fetch(req).then((r) => { const c = r.clone(); caches.open(CACHE).then((k) => k.put(req, c)); return r; })
      .catch(() => caches.match(req, { ignoreSearch: true }).then((r) => r || caches.match('./index.html'))));
  } else {                                                         // Schriften, Bibliothek: erst Speicher
    e.respondWith(caches.match(req).then((r) => r || fetch(req).then((n) => { const c = n.clone(); caches.open(CACHE).then((k) => k.put(req, c)); return n; })));
  }
});
