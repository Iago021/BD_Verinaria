<?php
require_once __DIR__ . '/base.php';
require_once __DIR__ . '/../persist/atendimentoDAO.php';

executarAcao(function () {
    $registro = new Agendamento(intv('animal_id'), intv('veterinario_id'), req('inicio'), req('fim'), req('motivo'));
    (new AtendimentoDAO())->inserir($registro);
}, 'agenda');
