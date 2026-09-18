<?php
// Configuração para XAMPP local. Prefira vet_app após executar permissoes.sql.
// Variáveis de ambiente podem substituir os valores sem editar este arquivo.
return [
    'host' => getenv('VETDATA_HOST') ?: '127.0.0.1',
    'port' => getenv('VETDATA_PORT') ?: '3306',
    'database' => getenv('VETDATA_DATABASE') ?: 'vetdata',
    'user' => getenv('VETDATA_USER') ?: 'root',
    'password' => getenv('VETDATA_PASSWORD') ?: '',
];
