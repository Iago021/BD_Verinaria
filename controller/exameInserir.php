<?php
require_once __DIR__ . '/base.php';
require_once __DIR__ . '/../persist/exameDAO.php';

executarAcao(function () {
    (new ExameDAO())->solicitar(intv('atendimento_id'), intv('tipo_exame_id'));
}, 'exames');
