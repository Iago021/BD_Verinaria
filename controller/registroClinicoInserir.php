<?php
require_once __DIR__ . '/base.php';
require_once __DIR__ . '/../persist/clinicoDAO.php';

executarAcao(function () {
    $registro = new RegistroClinico(intv('atendimento_id'), intv('autor_id'), req('anamnese'), req('diagnostico'), val('observacoes') ?: null, val('peso_kg') ? decimal('peso_kg') : null, val('retifica_id') ? intv('retifica_id') : null);
    (new ClinicoDAO())->inserir($registro);
}, 'atendimento', 'atendimento_id');
