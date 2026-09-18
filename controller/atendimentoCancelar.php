<?php
require_once __DIR__ . '/base.php';
require_once __DIR__ . '/../persist/atendimentoDAO.php';

executarAcao(function () {
    (new AtendimentoDAO())->cancelar(intv('id'), req('motivo'));
}, 'agenda');
