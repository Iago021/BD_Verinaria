/* Comportamentos de interface. Os dados de negócio são gravados somente no banco. */
function openDialog(id, values = {}, reset = true) {
  const dialog = document.getElementById(id);
  if (!dialog || dialog.tagName !== 'DIALOG') return;
  if (reset) dialog.querySelector('form').reset();
  for (const [key, value] of Object.entries(values)) {
    if (['csrf', 'action', 'dialog'].includes(key)) continue;
    const field = dialog.querySelector('form').elements.namedItem(key);
    if (field) field.value = value ?? '';
  }
  if (!dialog.open) dialog.showModal();
}
document.addEventListener('click', event => {
  const opener = event.target.closest('[data-open]');
  if (opener) openDialog(opener.dataset.open, JSON.parse(opener.dataset.values || '{}'));
  if (event.target.closest('[data-close]')) event.target.closest('dialog').close();
  if (event.target.closest('[data-dismiss]')) event.target.closest('.toast').remove();
});
document.querySelectorAll('dialog').forEach(dialog => dialog.addEventListener('click', event => {
  const box = dialog.getBoundingClientRect();
  if (event.target === dialog && (event.clientX < box.left || event.clientX > box.right || event.clientY < box.top || event.clientY > box.bottom)) dialog.close();
}));
document.querySelectorAll('[data-price-select]').forEach(select => select.addEventListener('change', () => {
  select.form.elements.namedItem('valor_unitario').value = select.selectedOptions[0]?.dataset.price || '';
}));
const toggle = document.querySelector('.menu-toggle');
const scrim = document.querySelector('.scrim');
function menu(open) { document.body.classList.toggle('menu-open', open); toggle?.setAttribute('aria-expanded', String(open)); if(scrim) scrim.hidden = !open; }
toggle?.addEventListener('click', () => menu(!document.body.classList.contains('menu-open')));
scrim?.addEventListener('click', () => menu(false));
document.addEventListener('keydown', event => { if(event.key === 'Escape') menu(false); });
document.querySelectorAll('form').forEach(form => form.addEventListener('submit', () => {
  if (form.method.toLowerCase() === 'post' && form.checkValidity()) {
    const button = form.querySelector('button[type="submit"]') || form.querySelector('button:not([type])');
    if (button) { button.disabled = true; button.dataset.originalText = button.textContent; button.textContent = 'Salvando…'; }
  }
}));
const recovery = document.querySelector('#form-recovery');
if (recovery) { const old = JSON.parse(recovery.dataset.form); if(old.dialog) { openDialog(old.dialog, old); const dialog = document.getElementById(old.dialog); const error = document.querySelector('.toast.error'); if(dialog && error) { const message=document.createElement('p'); message.className='form-error'; message.setAttribute('role','alert'); message.textContent=error.firstChild.textContent; dialog.querySelector('.dialog-head').after(message); } } }
