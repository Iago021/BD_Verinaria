<?php
require_once __DIR__ . '/base.php';
require_once __DIR__ . '/../persist/veterinarioDAO.php';

executarAcao(function () {
    $veterinario = new Veterinario(req('nome'), req('crmv'), intv('especialidade_id'));
    (new VeterinarioDAO())->inserir($veterinario);
}, 'equipe');
