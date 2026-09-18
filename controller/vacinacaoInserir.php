<?php
require_once __DIR__ . '/base.php';
require_once __DIR__ . '/../persist/vacinaDAO.php';

executarAcao(function () {
    $vacinacao = new Vacinacao(intv('atendimento_id'), intv('lote_id'), intv('profissional_id'), req('aplicada_em'), val('proxima_dose') ?: null);
    (new VacinaDAO())->inserir($vacinacao);
}, 'vacinas');
