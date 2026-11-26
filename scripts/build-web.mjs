// Builds the static site (landing + privacy + terms + account deletion) in web/public.
// Identical in every project: what changes lives in web/site.config.json and web/content/{en,es}.json.
// Run it with `npm run build:web`. Every page has one address and holds both languages: English is shown
// by default and a selector switches to Spanish. See docs/decisions (legal site) and STANDARD.md.
import { copyFileSync, existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';

const OUT = 'web/public';
const LANGS = ['en', 'es']; // the first one is the default
const PAGE_KEYS = ['privacy', 'terms', 'delete'];
const readJson = (file) => JSON.parse(readFileSync(file, 'utf8'));

const config = readJson('web/site.config.json');
const contents = Object.fromEntries(LANGS.map((lang) => [lang, readJson(`web/content/${lang}.json`)]));

/** Light and dark palettes; a project overrides only what it needs under `theme.light` / `theme.dark`. */
const THEME = {
  light: { bg: '#ffffff', ink: '#0e0e10', muted: '#5d5d66', line: '#e3e3e8', card: '#f4f4f6', accent: '#b86d00', onAccent: '#ffffff' },
  dark: { bg: '#0e0e10', ink: '#f4f4f6', muted: '#a3a3ad', line: '#2a2a31', card: '#17171b', accent: '#f5a524', onAccent: '#0e0e10' },
};
const palette = (mode) => ({ ...THEME[mode], ...(config.theme?.[mode] ?? {}) });
const cssVars = (p) => `  --bg: ${p.bg};\n  --ink: ${p.ink};\n  --muted: ${p.muted};\n  --line: ${p.line};\n  --card: ${p.card};\n  --accent: ${p.accent};\n  --on-accent: ${p.onAccent};`;
const themeCss = () => `:root {\n${cssVars(palette('light'))}\n  color-scheme: light dark;\n}\n@media (prefers-color-scheme: dark) {\n  :root {\n${cssVars(palette('dark'))}\n  }\n}\n`;

/** Both languages must have the same shape, so a section never exists in only one of them. */
function sameShape(a, b, path = '') {
  if (Array.isArray(a) !== Array.isArray(b) || typeof a !== typeof b) throw new Error(`web/content: "${path}" differs in type between languages`);
  if (Array.isArray(a)) {
    if (a.length !== b.length) throw new Error(`web/content: "${path}" has ${a.length} items in ${LANGS[0]} and ${b.length} in ${LANGS[1]}`);
    a.forEach((item, i) => sameShape(item, b[i], `${path}[${i}]`));
  } else if (a && typeof a === 'object') {
    const keys = new Set([...Object.keys(a), ...Object.keys(b)]);
    for (const key of keys) {
      if (!(key in a) || !(key in b)) throw new Error(`web/content: "${path}.${key}" is missing in one language`);
      sameShape(a[key], b[key], `${path}.${key}`);
    }
  }
}
sameShape(contents[LANGS[0]], contents[LANGS[1]]);

const escape = (text) => text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
const fill = (text, c) => text.replaceAll('{{owner}}', c.owner).replaceAll('{{email}}', c.email);
const linkEmail = (html, email) => html.replaceAll(escape(email), `<a href="mailto:${email}">${escape(email)}</a>`);

/** Inline marks: **bold**, `code` and [text](https://link). Everything else is plain text. */
function inline(text) {
  return text
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/`([^`]+)`/g, '<code>$1</code>')
    .replace(/\[([^\]]+)\]\((https?:\/\/[^)\s]+)\)/g, '<a href="$2" rel="noopener">$1</a>');
}
const line = (text, c) => inline(linkEmail(escape(fill(text, c)), c.email));

/** A body is lines separated by a line break: "1. " lines make an ordered list, "- " lines a bullet list, the rest are paragraphs. */
function renderBody(body, c) {
  const out = [];
  let list = null; // { tag, items }
  const flush = () => {
    if (list) out.push(`<${list.tag}>${list.items.map((item) => `<li>${item}</li>`).join('')}</${list.tag}>`);
    list = null;
  };
  for (const text of body.split('\n')) {
    const step = /^\d+\. (.*)$/.exec(text);
    const bullet = /^- (.*)$/.exec(text);
    const kind = step ? { tag: 'ol', text: step[1] } : bullet ? { tag: 'ul', text: bullet[1] } : null;
    if (kind) {
      if (list && list.tag !== kind.tag) flush();
      list ??= { tag: kind.tag, items: [] };
      list.items.push(line(kind.text, c));
    } else {
      flush();
      out.push(`<p>${line(text, c)}</p>`);
    }
  }
  flush();
  return out.join('\n');
}

const sectionsHtml = (sections, c) => sections.map((s) => `<section><h2>${escape(s.title)}</h2>\n${renderBody(s.body, c)}</section>`).join('\n');

/**
 * A document comes from the app (`<key>.source: "app"` in site.config.json: a single text for the app and the site, read
 * from its locale files) or from web/content. Privacy and terms can come from the app; account deletion always comes from web/content.
 */
function documentSource(key, lang, c) {
  const { source, file, key: appKey = key } = config[key] ?? { source: 'content' };
  if (source === 'app') {
    const doc = readJson(file.replace('{lang}', lang))[appKey];
    return { intro: doc.intro, updated: doc.updated, sections: Array.isArray(doc.sections) ? doc.sections : Object.values(doc.sections) };
  }
  return { intro: fill(c[key].intro ?? '', c), updated: c[key].updated ?? c.updated, sections: c[key].sections };
}

/** One block per language; only the active one is visible (the others carry `hidden`). */
const perLanguage = (render) =>
  LANGS.map((lang, i) => `<div data-lang="${lang}" lang="${contents[lang].lang}"${i === 0 ? '' : ' hidden'}>\n${render(contents[lang])}\n</div>`).join('\n');

const SWITCH_SCRIPT = `<script>
(function () {
  var langs = ${JSON.stringify(LANGS)};
  var current = langs[0];
  try {
    var wanted = new URLSearchParams(location.search).get('lang') || localStorage.getItem('lang');
    if (langs.indexOf(wanted) >= 0) current = wanted;
  } catch (e) {}
  function apply(lang) {
    current = lang;
    document.documentElement.lang = lang;
    document.querySelectorAll('[data-lang]').forEach(function (el) { el.hidden = el.getAttribute('data-lang') !== lang; });
    document.querySelectorAll('[data-pick]').forEach(function (el) { el.setAttribute('aria-pressed', String(el.getAttribute('data-pick') === lang)); });
    var title = document.querySelector('[data-title-' + lang + ']');
    if (title) document.title = title.getAttribute('data-title-' + lang);
  }
  document.querySelectorAll('[data-pick]').forEach(function (el) {
    el.addEventListener('click', function () {
      try { localStorage.setItem('lang', el.getAttribute('data-pick')); } catch (e) {}
      apply(el.getAttribute('data-pick'));
    });
  });
  apply(current);
})();
</script>`;

const NAME = escape(config.name);
const pageHtml = ({ titleOf, descriptionOf, body }) => `<!doctype html>
<html lang="${contents[LANGS[0]].lang}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${escape(titleOf(contents[LANGS[0]]))} · ${NAME}</title>
<meta name="description" content="${escape(descriptionOf(contents[LANGS[0]]))}">
<meta name="title-data" ${LANGS.map((l) => `data-title-${l}="${escape(titleOf(contents[l]))} · ${NAME}"`).join(' ')}>
<link rel="icon" href="/logo.png" type="image/png">
<link rel="stylesheet" href="/style.css">
</head>
<body>
<header class="top">
  <a class="brand" href="/"><img src="/${config.logo.svg ? 'logo.svg' : 'logo.png'}" alt="" width="40" height="40"><span>${NAME}</span></a>
  <div class="langs" role="group" aria-label="Language / Idioma">${LANGS.map((l, i) => `<button type="button" data-pick="${l}" aria-pressed="${i === 0}" lang="${contents[l].lang}">${escape(contents[l].languageName)}</button>`).join('')}</div>
</header>
<main>
${body}
</main>
<footer>
${perLanguage((c) => `<p>${NAME} · ${escape(c.owner)} · <a href="mailto:${c.email}">${escape(c.email)}</a></p>\n<nav>${PAGE_KEYS.map((k) => `<a href="/${c.pages[k].slug}">${escape(c.pages[k].title)}</a>`).join(' · ')}</nav>`)}
</footer>
${SWITCH_SCRIPT}
</body>
</html>
`;

const write = (file, content) => writeFileSync(file, content);

rmSync(OUT, { recursive: true, force: true });
mkdirSync(OUT, { recursive: true });
copyFileSync(config.logo.png, `${OUT}/logo.png`);
if (config.logo.svg) copyFileSync(config.logo.svg, `${OUT}/logo.svg`);
write(`${OUT}/style.css`, `${themeCss()}${readFileSync('web/style.css', 'utf8')}`);

// Landing: pitch, download link, features (with screenshots when the project has them) and the legal documents.
// config.screens = { en: { dir, files: [...] }, es: { dir, files: [...] } }, one file per `showcase` item (in order).
const screenFor = (lang, i) => {
  const screens = config.screens?.[lang];
  const name = screens?.files[i];
  if (!name) return null;
  const target = `screens/${lang}-${i + 1}.jpg`;
  mkdirSync(`${OUT}/screens`, { recursive: true });
  copyFileSync(`${screens.dir}/${name}`, `${OUT}/${target}`);
  return `/${target}`;
};
// Without `playUrl` (an app that is not published yet) the page shows `landing.comingSoon` (or the note) and no button.
// To launch: set `playUrl` in web/site.config.json and run `npm run build:web`.
const playButton = (c) => (config.playUrl ? `<p><a class="play" href="${config.playUrl}" rel="noopener">${escape(c.landing.download)}</a></p>` : '');
const showcaseRow = (c, f, i) => {
  const src = screenFor(c.lang === 'es' ? 'es' : 'en', i);
  const image = src ? `<img src="${src}" alt="${escape(f.title)}" width="270" height="522" loading="lazy">` : '';
  return `<article class="row${i % 2 ? ' flip' : ''}${src ? '' : ' plain'}">${image}<div><h3>${escape(f.title)}</h3><p class="lead">${escape(f.text)}</p><ul>${f.bullets.map((x) => `<li>${escape(x)}</li>`).join('')}</ul></div></article>`;
};

write(
  `${OUT}/index.html`,
  pageHtml({
    titleOf: (c) => c.landing.title,
    descriptionOf: (c) => c.landing.lead,
    body: perLanguage((c) => {
      const l = c.landing;
      return `<section class="hero"><img src="/logo.png" alt="" width="96" height="96"><h1>${escape(l.headline)}</h1>
<p class="lead">${escape(l.lead)}</p>
${playButton(c)}<p class="updated">${escape(config.playUrl ? l.downloadNote : (l.comingSoon ?? l.downloadNote))}</p></section>
<section><h2>${escape(l.featuresTitle)}</h2>
${l.showcase.map((f, i) => showcaseRow(c, f, i)).join('')}</section>
<section><h2>${escape(l.moreTitle)}</h2>
<ul class="features">${l.more.map((f) => `<li><strong>${escape(f.title)}</strong><span>${escape(f.text)}</span></li>`).join('')}</ul></section>
${config.playUrl ? `<section class="cta"><h2>${escape(l.ctaTitle)}</h2>
${playButton(c)}</section>` : ''}
<section><h2>${escape(l.legalTitle)}</h2>
<ul class="cards">${PAGE_KEYS.map((k) => `<li><a href="/${c.pages[k].slug}"><strong>${escape(c.pages[k].title)}</strong><span>${escape(c.pages[k].summary)}</span></a></li>`).join('')}</ul></section>`;
    }),
  }),
);

// One page per document, with both languages inside.
for (const key of PAGE_KEYS) {
  write(
    `${OUT}/${contents[LANGS[0]].pages[key].slug}.html`,
    pageHtml({
      titleOf: (c) => c.pages[key].title,
      descriptionOf: (c) => c.pages[key].summary,
      body: perLanguage((c) => {
        const source = documentSource(key, c.lang === 'es' ? 'es' : 'en', c);
        return `<p class="back"><a href="/">← ${escape(c.home.back)}</a></p>\n<h1>${escape(c.pages[key].title)}</h1>\n<p class="updated">${escape(source.updated)}</p>\n<p class="lead">${linkEmail(escape(source.intro), c.email)}</p>\n${sectionsHtml(source.sections, c).replaceAll('{{owner}}', c.owner)}`;
      }),
    }),
  );
}
if (existsSync('web/extra')) console.warn('web/extra is not part of the standard; remove it or move it to web/public by hand.');
console.log(`Site written to ${OUT}`);
