<?php
require_once __DIR__ . '/base.php';
require_once __DIR__ . '/../persist/veterinarioDAO.php';

executarAcao(function () {
    $dia = filter_var(req('dia_semana'), FILTER_VALIDATE_INT);
    if ($dia === false || $dia < 0 || $dia > 6) throw new InvalidArgumentException('Dia da semana inválido.');
    (new VeterinarioDAO())->adicionarHorario(intv('veterinario_id'), $dia, req('inicio'), req('fim'));
}, 'equipe');
