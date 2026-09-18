<?php
require_once __DIR__ . '/base.php';
require_once __DIR__ . '/../persist/atendimentoDAO.php';

executarAcao(function () {
    (new AtendimentoDAO())->remarcar(intv('id'), req('inicio'), req('fim'));
}, 'agenda');
