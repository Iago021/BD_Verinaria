<?php
require_once __DIR__ . '/base.php';
require_once __DIR__ . '/../persist/clinicoDAO.php';

executarAcao(function () {
    $prescricao = new Prescricao(intv('atendimento_id'), intv('medicamento_id'), req('posologia'), intv('duracao_dias'), val('orientacoes') ?: null);
    (new ClinicoDAO())->prescrever($prescricao);
}, 'atendimento', 'atendimento_id');
