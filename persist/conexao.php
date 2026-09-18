<?php
declare(strict_types=1);

// Mesmo ponto de conexão do projeto PW, agora para o banco vetdata.
class Conexao
{
    private static ?PDO $pdo = null;

    public function conectar(): PDO
    {
        if (self::$pdo === null) {
            $config = require __DIR__ . '/config.php';
            self::$pdo = new PDO(
                "mysql:host={$config['host']};port={$config['port']};dbname={$config['database']};charset=utf8mb4",
                $config['user'], $config['password'], [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ]
            );
            self::$pdo->exec("SET time_zone='-03:00'");
            self::$pdo->exec('SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED');
        }
        return self::$pdo;
    }
}
