<?php
require_once __DIR__ . '/base.php';
require_once __DIR__ . '/../persist/animalDAO.php';

executarAcao(function () {
    (new AnimalDAO())->arquivar(intv('id'));
}, 'pacientes');
