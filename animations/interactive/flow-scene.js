/* ============================================================
   Flow scene builder — renders a row of components (Client,
   API, Server, Database) with clean straight SVG arrows drawn
   between them, a travelling packet pill, per-node action
   labels, and an optional JSON payload on a node.

   Usage:
     const scene = createFlowScene(document.getElementById('scene'), {
       nodes: [
         { id: 'client', name: 'Client', sub: '(e.g., Browser)', icon: 'client', payload: '{ ... }' },
         ...
       ]
     });
     scene.apply(stepState);

   Step state (all optional):
     nodes:   { client: 'request', database: 'query', ... }   // highlight kind
     arrows:  [{ from: 'client', to: 'api', kind: 'request', dim: true, label: 'GET /x' }]
     packet:  { from: 'api', to: 'server', kind: 'request', label: 'GET' }
     actions: { database: 'Retrieving data…' }
     payload: ['client']                                       // nodes showing payload

   Kinds → colors: request, response, query, write, post
   ============================================================ */

const FLOW_COLORS = {
  request:  '#88c0d0',
  response: '#a3be8c',
  query:    '#ebcb8b',
  write:    '#b48ead',
  post:     '#d08770'
};

const FLOW_ICONS = {
  client: '<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>',
  api: '<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>',
  server: '<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="2" width="20" height="8" rx="2" ry="2"/><rect x="2" y="14" width="20" height="8" rx="2" ry="2"/><line x1="6" y1="6" x2="6.01" y2="6"/><line x1="6" y1="18" x2="6.01" y2="18"/></svg>',
  database: '<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"/></svg>'
};

function createFlowScene(rootEl, cfg) {
  const SVG_NS = 'http://www.w3.org/2000/svg';
  const nodeOrder = cfg.nodes.map(function (n) { return n.id; });
  const nodeEls = {};
  const actionEls = {};
  const payloadEls = {};

  rootEl.classList.add('flow-wrap');

  // SVG layer for arrows
  const svg = document.createElementNS(SVG_NS, 'svg');
  svg.setAttribute('class', 'flow-svg');
  const defs = document.createElementNS(SVG_NS, 'defs');
  Object.keys(FLOW_COLORS).forEach(function (kind) {
    ['', '-dim'].forEach(function (suffix) {
      const marker = document.createElementNS(SVG_NS, 'marker');
      marker.setAttribute('id', 'arrowhead-' + kind + suffix);
      marker.setAttribute('viewBox', '0 0 10 10');
      marker.setAttribute('refX', '8');
      marker.setAttribute('refY', '5');
      marker.setAttribute('markerWidth', '7');
      marker.setAttribute('markerHeight', '7');
      marker.setAttribute('orient', 'auto-start-reverse');
      const tip = document.createElementNS(SVG_NS, 'path');
      tip.setAttribute('d', 'M 0 1 L 9 5 L 0 9 z');
      tip.setAttribute('fill', FLOW_COLORS[kind]);
      if (suffix) tip.setAttribute('opacity', '0.35');
      marker.appendChild(tip);
      defs.appendChild(marker);
    });
  });
  svg.appendChild(defs);
  const arrowLayer = document.createElementNS(SVG_NS, 'g');
  svg.appendChild(arrowLayer);
  rootEl.appendChild(svg);

  // Node cards
  const grid = document.createElement('div');
  grid.className = 'flow-grid';
  grid.style.gridTemplateColumns = 'repeat(' + cfg.nodes.length + ', 1fr)';
  cfg.nodes.forEach(function (n) {
    const card = document.createElement('div');
    card.className = 'flow-node';
    card.id = 'node-' + n.id;

    const icon = document.createElement('div');
    icon.className = 'node-icon icon-' + (n.iconColor || n.icon);
    icon.innerHTML = FLOW_ICONS[n.icon] || '';
    card.appendChild(icon);

    const h = document.createElement('h3');
    h.textContent = n.name;
    card.appendChild(h);

    if (n.sub) {
      const sub = document.createElement('p');
      sub.className = 'node-sub';
      sub.textContent = n.sub;
      card.appendChild(sub);
    }

    if (n.payload) {
      const pre = document.createElement('code');
      pre.className = 'node-payload';
      pre.textContent = n.payload;
      card.appendChild(pre);
      payloadEls[n.id] = pre;
    }

    const action = document.createElement('div');
    action.className = 'node-action';
    card.appendChild(action);
    actionEls[n.id] = action;

    grid.appendChild(card);
    nodeEls[n.id] = card;
  });
  rootEl.appendChild(grid);

  // Travelling packet pill
  const packetEl = document.createElement('div');
  packetEl.className = 'flow-packet';
  rootEl.appendChild(packetEl);

  let lastState = null;
  let lastIndex = -1;

  function segmentGeometry(fromId, toId) {
    const wrap = rootEl.getBoundingClientRect();
    const a = nodeEls[fromId].getBoundingClientRect();
    const b = nodeEls[toId].getBoundingClientRect();
    const rightward = a.left < b.left;
    const midY = a.top + a.height / 2 - wrap.top;
    const y = rightward ? midY - 30 : midY + 30;
    const gap = 12;
    const x1 = rightward ? a.right - wrap.left + gap : a.left - wrap.left - gap;
    const x2 = rightward ? b.left - wrap.left - gap : b.right - wrap.left + gap;
    return { x1: x1, x2: x2, y: y, rightward: rightward };
  }

  function drawArrows(state, animate) {
    while (arrowLayer.firstChild) arrowLayer.removeChild(arrowLayer.firstChild);

    (state.arrows || []).forEach(function (ar) {
      const g = segmentGeometry(ar.from, ar.to);
      const color = FLOW_COLORS[ar.kind] || FLOW_COLORS.request;

      const line = document.createElementNS(SVG_NS, 'line');
      line.setAttribute('x1', g.x1);
      line.setAttribute('y1', g.y);
      line.setAttribute('x2', g.x2);
      line.setAttribute('y2', g.y);
      line.setAttribute('stroke', color);
      line.setAttribute('stroke-width', '2.5');
      line.setAttribute('stroke-linecap', 'round');
      line.setAttribute('marker-end', 'url(#arrowhead-' + ar.kind + (ar.dim ? '-dim' : '') + ')');
      if (ar.dim) {
        line.setAttribute('opacity', '0.35');
      } else if (animate) {
        const len = Math.abs(g.x2 - g.x1);
        line.style.strokeDasharray = String(len);
        line.style.strokeDashoffset = String(len);
        line.setAttribute('class', 'arrow-draw');
      }
      arrowLayer.appendChild(line);

      if (ar.label) {
        const text = document.createElementNS(SVG_NS, 'text');
        text.setAttribute('x', (g.x1 + g.x2) / 2);
        text.setAttribute('y', g.rightward ? g.y - 12 : g.y + 20);
        text.setAttribute('text-anchor', 'middle');
        text.setAttribute('fill', color);
        text.setAttribute('font-size', '12');
        text.setAttribute('font-family', 'SF Mono, ui-monospace, Menlo, Consolas, monospace');
        if (ar.dim) text.setAttribute('opacity', '0.4');
        text.textContent = ar.label;
        arrowLayer.appendChild(text);
      }
    });

    // Packet pill at the midpoint of its segment
    if (state.packet) {
      const p = state.packet;
      const g = segmentGeometry(p.from, p.to);
      packetEl.textContent = p.label;
      packetEl.style.color = FLOW_COLORS[p.kind] || FLOW_COLORS.request;
      packetEl.style.left = ((g.x1 + g.x2) / 2) + 'px';
      packetEl.style.top = g.y + 'px';
      packetEl.style.setProperty('--packet-shift', g.rightward ? '-140%' : '40%');
      packetEl.classList.remove('visible');
      void packetEl.offsetWidth; // restart entrance animation
      packetEl.classList.add('visible');
    } else {
      packetEl.classList.remove('visible');
    }
  }

  function apply(state, stepIndex) {
    const animate = stepIndex !== lastIndex;
    lastState = state;
    lastIndex = stepIndex;

    // Node highlights
    nodeOrder.forEach(function (id) {
      const el = nodeEls[id];
      el.className = 'flow-node';
      const kind = state.nodes && state.nodes[id];
      if (kind) el.classList.add('hl-' + kind);
    });

    // Action labels
    nodeOrder.forEach(function (id) {
      const text = state.actions && state.actions[id];
      actionEls[id].textContent = text || actionEls[id].textContent;
      actionEls[id].classList.toggle('visible', Boolean(text));
    });

    // Payloads
    Object.keys(payloadEls).forEach(function (id) {
      const show = Array.isArray(state.payload) && state.payload.indexOf(id) !== -1;
      payloadEls[id].classList.toggle('visible', show);
    });

    // Arrows need final layout — draw on the next frame
    requestAnimationFrame(function () { drawArrows(state, animate); });
  }

  window.addEventListener('resize', function () {
    if (lastState) drawArrows(lastState, false);
  });

  return { apply: apply };
}

/* Helper for pages: set the colored status line under the title */
function setStatus(html) {
  document.getElementById('status').innerHTML = html || '&nbsp;';
}
