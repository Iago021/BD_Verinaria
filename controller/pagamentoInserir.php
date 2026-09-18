<?php
require_once __DIR__ . '/base.php';
require_once __DIR__ . '/../persist/financeiroDAO.php';

executarAcao(function () {
    (new FinanceiroDAO())->receber(intv('cobranca_id'), intv('forma_id'), decimal('valor'));
}, 'financeiro');
