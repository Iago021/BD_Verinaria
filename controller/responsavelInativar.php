<?php
require_once __DIR__ . '/base.php';
require_once __DIR__ . '/../persist/responsavelDAO.php';

executarAcao(function () {
    (new ResponsavelDAO())->inativar(intv('id'));
}, 'responsaveis');
