<?php
require_once __DIR__ . '/baseDAO.php';
require_once __DIR__ . '/../model/veterinario.php';

class VeterinarioDAO extends BaseDAO
{
    public function especialidades(): array
    {
        return $this->consultar('SELECT * FROM especialidade ORDER BY nome');
    }

    public function ativos(): array
    {
        return $this->consultar('SELECT * FROM veterinario WHERE ativo=1 ORDER BY nome');
    }

    public function listar(): array
    {
        return $this->consultar("SELECT v.*,GROUP_CONCAT(e.nome ORDER BY e.nome SEPARATOR ' · ') AS especialidades FROM veterinario v LEFT JOIN veterinario_especialidade ve ON ve.veterinario_id=v.id LEFT JOIN especialidade e ON e.id=ve.especialidade_id GROUP BY v.id,v.nome,v.crmv,v.ativo ORDER BY v.nome");
    }

    public function horarios(int $id): array
    {
        return $this->consultar('SELECT * FROM disponibilidade WHERE veterinario_id=? ORDER BY dia_semana,inicio', [$id]);
    }

    public function inserir(Veterinario $veterinario): void
    {
        $this->transacao(function () use ($veterinario) {
            $this->executar('INSERT INTO veterinario(nome,crmv) VALUES(?,?)', [$veterinario->getNome(), $veterinario->getCrmv()]);
            $id = (int)$this->pdo->lastInsertId();
            $this->executar('INSERT INTO veterinario_especialidade(veterinario_id,especialidade_id) VALUES(?,?)', [$id, $veterinario->getEspecialidadeId()]);
        });
    }

    public function adicionarHorario(int $id, int $dia, string $inicio, string $fim): void
    {
        $this->executar('INSERT INTO disponibilidade(veterinario_id,dia_semana,inicio,fim) VALUES(?,?,?,?)', [$id, $dia, $inicio, $fim]);
    }
}
