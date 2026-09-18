<?php
require_once __DIR__ . '/base.php';
require_once __DIR__ . '/../persist/servicoDAO.php';

executarAcao(function () {
    $servico = new ServicoAtendimento(intv('atendimento_id'), intv('servico_id'), intv('quantidade'), decimal('valor_unitario'));
    (new ServicoDAO())->inserir($servico);
}, 'atendimento', 'atendimento_id');
