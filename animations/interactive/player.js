/* ============================================================
   Step player — Back / Play / Pause / Next controls shared by
   every interactive animation. Play auto-advances slowly by
   default and loops; any manual navigation pauses playback.

   Usage:
     initPlayer({
       steps: [{ title, text, ...sceneState }, ...],
       apply: (step, index) => { render the scene for this step }
     });

   Expects the page to contain:
     <section id="narration"></section>
     <div id="controls"></div>
   ============================================================ */

function initPlayer(opts) {
  const steps = opts.steps;
  const apply = opts.apply;

  let index = 0;
  let playing = false;
  let timer = null;

  const ICONS = {
    back: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>',
    next: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>',
    play: '<svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor" stroke="none"><polygon points="6 3 21 12 6 21"/></svg>',
    pause: '<svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor" stroke="none"><rect x="5" y="4" width="5" height="16" rx="1.5"/><rect x="14" y="4" width="5" height="16" rx="1.5"/></svg>'
  };

  // ---- build controls ----
  const controls = document.getElementById('controls');
  controls.className = 'controls';
  controls.innerHTML =
    '<div class="ctrl-buttons">' +
      '<button id="btn-back" class="ctrl-btn" title="Back (←)">' + ICONS.back + '<span>Back</span></button>' +
      '<button id="btn-play" class="ctrl-btn ctrl-play" title="Play / Pause (space)">' + ICONS.play + '<span>Play</span></button>' +
      '<button id="btn-next" class="ctrl-btn" title="Next (→)"><span>Next</span>' + ICONS.next + '</button>' +
    '</div>' +
    '<div id="dots" class="dots" role="tablist" aria-label="Steps"></div>' +
    '<div class="ctrl-meta">' +
      '<span id="step-count"></span>' +
      '<label class="speed-label">Speed' +
        '<select id="speed-sel" title="Playback speed">' +
          '<option value="4200" selected>Slow</option>' +
          '<option value="2600">Normal</option>' +
          '<option value="1400">Fast</option>' +
        '</select>' +
      '</label>' +
    '</div>';

  const btnBack = document.getElementById('btn-back');
  const btnPlay = document.getElementById('btn-play');
  const btnNext = document.getElementById('btn-next');
  const dotsEl = document.getElementById('dots');
  const countEl = document.getElementById('step-count');
  const speedSel = document.getElementById('speed-sel');

  // ---- build narration box ----
  const narr = document.getElementById('narration');
  narr.className = 'narration';
  narr.innerHTML = '<h2 id="narr-title"></h2><p id="narr-text"></p>';
  const narrTitle = document.getElementById('narr-title');
  const narrText = document.getElementById('narr-text');

  // ---- progress dots ----
  steps.forEach(function (_, i) {
    const d = document.createElement('button');
    d.className = 'dot';
    d.title = 'Step ' + (i + 1);
    d.addEventListener('click', function () {
      pause();
      goTo(i);
    });
    dotsEl.appendChild(d);
  });
  const dots = Array.prototype.slice.call(dotsEl.children);

  function render() {
    const step = steps[index];
    apply(step, index);
    narrTitle.textContent = step.title || '';
    narrText.textContent = step.text || '';
    countEl.textContent = 'Step ' + (index + 1) + ' of ' + steps.length;
    dots.forEach(function (d, i) {
      d.classList.toggle('active', i === index);
      d.classList.toggle('done', i < index);
    });
  }

  function goTo(i) {
    index = ((i % steps.length) + steps.length) % steps.length;
    render();
  }

  function schedule() {
    clearTimeout(timer);
    timer = setTimeout(function () {
      if (!playing) return;
      goTo(index + 1);
      schedule();
    }, Number(speedSel.value));
  }

  function play() {
    playing = true;
    btnPlay.classList.add('playing');
    btnPlay.innerHTML = ICONS.pause + '<span>Pause</span>';
    schedule();
  }

  function pause() {
    playing = false;
    clearTimeout(timer);
    btnPlay.classList.remove('playing');
    btnPlay.innerHTML = ICONS.play + '<span>Play</span>';
  }

  btnPlay.addEventListener('click', function () {
    if (playing) pause();
    else play();
  });
  btnNext.addEventListener('click', function () { pause(); goTo(index + 1); });
  btnBack.addEventListener('click', function () { pause(); goTo(index - 1); });
  speedSel.addEventListener('change', function () { if (playing) schedule(); });

  document.addEventListener('keydown', function (e) {
    if (e.target.tagName === 'SELECT' || e.target.tagName === 'INPUT') return;
    if (e.key === 'ArrowRight') { e.preventDefault(); pause(); goTo(index + 1); }
    else if (e.key === 'ArrowLeft') { e.preventDefault(); pause(); goTo(index - 1); }
    else if (e.key === ' ') { e.preventDefault(); if (playing) pause(); else play(); }
  });

  // Optional deep link: page.html?step=3 opens on step 3 (1-based)
  const match = /[?&]step=(\d+)/.exec(window.location.search);
  if (match) {
    const wanted = parseInt(match[1], 10) - 1;
    if (wanted >= 0 && wanted < steps.length) index = wanted;
  }

  render();
}
