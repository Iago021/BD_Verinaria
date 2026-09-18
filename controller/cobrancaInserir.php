<?php
require_once __DIR__ . '/base.php';
require_once __DIR__ . '/../persist/financeiroDAO.php';

executarAcao(function () {
    (new FinanceiroDAO())->emitir(intv('atendimento_id'), decimal('desconto_pct'), req('vencimento'));
}, 'financeiro');
