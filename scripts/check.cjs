'use strict';
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const root = path.resolve(__dirname, '../site');
let checked = 0;
for (const name of ['index.html', 'contact.html']) {
  const html = fs.readFileSync(path.join(root, name), 'utf8');
  if (/chatgpt\.site|127\.0\.0\.1/i.test(html)) throw new Error('Adresse de développement dans ' + name);
  for (const match of html.matchAll(/(?:href|src)="([^"]+)"/g)) {
    const ref = match[1];
    if (/^(?:https?:|mailto:|tel:|data:)/.test(ref)) continue;
    const [resource, anchor] = ref.split('#');
    const target = resource.split('?')[0] || name;
    const targetPath = path.join(root, target);
    if (!fs.existsSync(targetPath)) throw new Error('Lien introuvable : ' + ref);
    if (anchor && !fs.readFileSync(targetPath, 'utf8').includes('id="' + anchor + '"')) throw new Error('Ancre introuvable : ' + ref);
    checked++;
  }
}
new vm.Script(fs.readFileSync(path.join(root, 'contact.js'), 'utf8'));
console.log(checked + ' liens et ressources vérifiés. Syntaxe JavaScript valide. Aucune dépendance à ChatGPT.');
