<?php
require_once __DIR__ . '/base.php';
require_once __DIR__ . '/../persist/exameDAO.php';

executarAcao(function () {
    (new ExameDAO())->coletar(intv('id'));
}, 'exames');
