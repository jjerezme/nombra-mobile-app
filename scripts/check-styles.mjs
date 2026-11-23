// Fails when a style number or color drifts away from the design tokens (src/constants/tokens.ts, src/constants/typography.ts).
// Run with `npm run check:styles`. A line that is a deliberate exception (a circle sized to its element, an illustration)
// ends with `// style-ok`.
import { readdirSync, readFileSync } from 'node:fs';
import { join, relative } from 'node:path';

const ROOTS = ['src/app', 'src/components'];
const COLOR_EXCEPTIONS = new Set([]);

const SPACING_PROPS =
  'padding|paddingHorizontal|paddingVertical|paddingTop|paddingBottom|paddingLeft|paddingRight|paddingStart|paddingEnd|margin|marginHorizontal|marginVertical|marginTop|marginBottom|marginLeft|marginRight|marginStart|marginEnd|gap|rowGap|columnGap';
// Numbers that sit between two scale steps: almost always a drifted value.
const NEAR_SPACING = new Set([5, 6, 7, 9, 10, 11, 13, 14, 15, 17, 18, 19, 21, 22, 23, 25, 26, 27, 28, 29, 30, 31]);
const NEAR_RADIUS = new Set([9, 10, 11, 13, 15, 17, 18, 19]);
const NEAR_ICON = new Set([14, 15, 17, 19, 20, 21, 23, 25, 26]);

const files = [];
const walk = (dir) => {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const full = join(dir, entry.name);
    if (entry.isDirectory()) walk(full);
    else if (/\.(tsx|js)$/.test(entry.name)) files.push(full);
  }
};
ROOTS.forEach(walk);

const findings = [];
for (const file of files) {
  const name = relative('.', file).split('\\').join('/');
  const lines = readFileSync(file, 'utf8').split(/\r?\n/);
  lines.forEach((line, index) => {
    if (/\/\/ style-ok\s*$/.test(line)) return;
    const report = (message) => findings.push(`${name}:${index + 1}  ${message}\n    ${line.trim()}`);

    const font = line.match(/\bfontSize:\s*(\d+(?:\.\d+)?)\s*[,}]?\s*$/);
    if (font) report(`fontSize ${font[1]}: use fontSize.* (or a typography.* role)`);

    const spacing = line.match(new RegExp(`\\b(?:${SPACING_PROPS}):\\s*(\\d+)\\s*[,}]?\\s*$`));
    if (spacing && NEAR_SPACING.has(Number(spacing[1]))) report(`spacing ${spacing[1]}: use spacing.* (4/8/12/16/20/24/32)`);

    const rad = line.match(/\bborderRadius:\s*(\d+)\s*[,}]?\s*$/);
    if (rad && NEAR_RADIUS.has(Number(rad[1]))) report(`borderRadius ${rad[1]}: use radius.* (a circle: radius.pill)`);

    const icon = line.match(/<MaterialIcons\b[^>]*\bsize=\{(\d+)\}/);
    if (icon && NEAR_ICON.has(Number(icon[1]))) report(`icon size ${icon[1]}: use iconSize.*`);

    if (!COLOR_EXCEPTIONS.has(name) && /['"`]#[0-9A-Fa-f]{3,8}['"`]|rgba?\(/.test(line)) report('color literal: use the theme (useTheme) or withAlpha()');
  });
}

if (findings.length) {
  console.error(findings.join('\n'));
  console.error(`\n${findings.length} style value(s) outside the design tokens. Use src/constants/tokens.ts and src/constants/typography.ts.`);
  process.exit(1);
}
console.log('check-styles: all style values come from the design tokens.');
