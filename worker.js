// Free Cloudflare Worker: lets your page read Kalshi's PUBLIC market data if your browser blocks direct access (CORS).
// Deploy: Cloudflare dashboard > Workers & Pages > Create > Hello World > paste this > Deploy. Paste the workers.dev address into the "Proxy" box.
export default {
  async fetch(req) {
    const h = {'access-control-allow-origin':'*','access-control-allow-methods':'GET,OPTIONS','access-control-allow-headers':'*'};
    if (req.method === 'OPTIONS') return new Response(null, {headers: h});
    const u = new URL(req.url);
    if (!u.pathname.startsWith('/trade-api/v2/markets')) return new Response('Only public market data is allowed', {status: 403, headers: h});
    const r = await fetch('https://external-api.kalshi.com' + u.pathname + u.search, {headers: {accept: 'application/json'}});
    return new Response(r.body, {status: r.status, headers: {...h, 'content-type': 'application/json'}});
  }
};
