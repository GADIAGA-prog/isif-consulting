'use strict';
const form = document.querySelector('#project-form');
const service = document.querySelector('#service');
const message = document.querySelector('#message');
const guidance = {
  projet: 'Présentez votre objectif : nous pourrons orienter votre demande vers la bonne expertise.',
  statistique: 'Précisez les données disponibles, l’enquête envisagée ou les indicateurs à suivre.',
  digital: 'Décrivez le logiciel, la plateforme ou le processus que vous souhaitez améliorer.',
  finance: 'Indiquez votre besoin en analyse, conseil, formation ou gestion financière.',
  formation: 'Précisez le thème, votre niveau, le nombre de participants et les dates souhaitées.'
};
const requested = new URLSearchParams(window.location.search).get('service');
if (Object.hasOwn(guidance, requested)) service.value = requested;
function updateGuidance() { document.querySelector('#service-hint').textContent = guidance[service.value]; }
updateGuidance();
service.addEventListener('change', updateGuidance);
message.addEventListener('input', () => { document.querySelector('#count').textContent = `${message.value.length} / 1 500`; });
let preparedText = '';
form.addEventListener('input', () => { document.querySelector('#prepared').hidden = true; });
form.addEventListener('submit', event => {
  event.preventDefault();
  const nameInput = form.elements.fullName;
  nameInput.setCustomValidity(nameInput.value.trim() ? '' : 'Veuillez indiquer votre nom.');
  message.setCustomValidity(message.value.trim().length >= 20 ? '' : 'Décrivez votre demande en au moins 20 caractères.');
  if (!form.reportValidity()) return;
  const topic = service.options[service.selectedIndex].text;
  preparedText = `Bonjour ISIF Consulting,\n\n${message.value.trim()}\n\nBesoin : ${topic}\nNom : ${nameInput.value.trim()}\nE-mail : ${form.elements.email.value.trim()}${form.elements.organization.value.trim() ? '\nOrganisation : ' + form.elements.organization.value.trim() : ''}${form.elements.phone.value.trim() ? '\nTéléphone : ' + form.elements.phone.value.trim() : ''}\n\nCordialement,\n${nameInput.value.trim()}`;
  const href = `mailto:contact@isifconsulting.com?subject=${encodeURIComponent('Demande — ' + topic)}&body=${encodeURIComponent(preparedText)}`;
  document.querySelector('#message-preview').textContent = preparedText;
  document.querySelector('#open-email').href = href;
  document.querySelector('#copy-status').textContent = '';
  document.querySelector('#prepared').hidden = false;
  document.querySelector('#prepared-title').focus();
  window.location.href = href;
});
form.addEventListener('input', event => { if (typeof event.target.setCustomValidity === 'function') event.target.setCustomValidity(''); });
document.querySelector('#copy-message').addEventListener('click', async () => {
  try { await navigator.clipboard.writeText(preparedText); document.querySelector('#copy-status').textContent = 'Message copié. Collez-le dans un e-mail à contact@isifconsulting.com.'; }
  catch { document.querySelector('#copy-status').textContent = 'La copie automatique est indisponible. Vous pouvez sélectionner le texte dans « Relire le message ».'; }
});
