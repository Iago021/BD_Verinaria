<?php
require_once __DIR__ . '/base.php';
require_once __DIR__ . '/../persist/animalDAO.php';

executarAcao(function () {
    $animal = new Animal(val('id') ? intv('id') : 0, intv('responsavel_id'), intv('raca_id'), req('nome'), req('sexo'), val('nascimento') ?: null, val('microchip') ?: null);
    (new AnimalDAO())->salvar($animal);
}, 'pacientes');
