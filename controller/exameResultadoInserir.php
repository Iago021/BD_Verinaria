<?php
require_once __DIR__ . '/base.php';
require_once __DIR__ . '/../persist/exameDAO.php';

executarAcao(function () {
    $resultado = new ResultadoExame(intv('solicitacao_id'), intv('autor_id'), req('resultado'));
    (new ExameDAO())->registrarResultado($resultado);
}, 'exames');
