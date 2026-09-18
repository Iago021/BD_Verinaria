<?php
require_once __DIR__ . '/base.php';
require_once __DIR__ . '/../persist/responsavelDAO.php';

executarAcao(function () {
    if (val('email') && !filter_var(val('email'), FILTER_VALIDATE_EMAIL)) throw new InvalidArgumentException('Informe um e-mail válido.');
    $responsavel = new Responsavel(val('id') ? intv('id') : 0, req('nome'), req('documento'), val('email'), val('telefone'));
    (new ResponsavelDAO())->salvar($responsavel);
}, 'responsaveis');
