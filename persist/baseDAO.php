<?php
require_once __DIR__ . '/conexao.php';

abstract class BaseDAO
{
    protected PDO $pdo;

    public function __construct()
    {
        $this->pdo = (new Conexao())->conectar();
    }

    protected function consultar(string $sql, array $parametros = []): array
    {
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($parametros);
        $resultado = $stmt->fetchAll();
        $stmt->closeCursor();
        return $resultado;
    }

    protected function um(string $sql, array $parametros = []): array
    {
        return $this->consultar($sql, $parametros)[0] ?? [];
    }

    protected function executar(string $sql, array $parametros = []): void
    {
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($parametros);
        $stmt->closeCursor();
    }

    protected function transacao(callable $operacao): void
    {
        $this->pdo->beginTransaction();
        try {
            $operacao();
            $this->pdo->commit();
        } catch (Throwable $erro) {
            if ($this->pdo->inTransaction()) $this->pdo->rollBack();
            throw $erro;
        }
    }
}
