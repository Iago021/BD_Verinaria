<?php
require_once __DIR__ . '/baseDAO.php';
require_once __DIR__ . '/../model/resultadoExame.php';

class ExameDAO extends BaseDAO
{
    public function tipos(): array
    {
        return $this->consultar('SELECT * FROM tipo_exame ORDER BY nome');
    }

    public function listar(bool $pending): array
    {
        return $this->consultar("SELECT x.*,n.nome AS animal,t.nome AS tipo,v.nome AS veterinario,
 (SELECT COUNT(*) FROM exame_resultado z WHERE z.solicitacao_id=x.id) AS resultados
 FROM exame_solicitacao x JOIN atendimento a ON a.id=x.atendimento_id JOIN animal n ON n.id=a.animal_id
 JOIN veterinario v ON v.id=a.veterinario_id JOIN tipo_exame t ON t.id=x.tipo_exame_id ".($pending?'WHERE NOT EXISTS(SELECT 1 FROM exame_resultado z WHERE z.solicitacao_id=x.id)':'').' ORDER BY x.id DESC');
    }

    public function resultados(int $id): array
    {
        return $this->consultar('SELECT z.*,v.nome AS autor FROM exame_resultado z JOIN veterinario v ON v.id=z.autor_id WHERE solicitacao_id=? ORDER BY registrado_em DESC,id DESC', [$id]);
    }

    public function porAtendimento(int $id): array
    {
        return $this->consultar('SELECT t.nome,x.coletado_em,(SELECT COUNT(*) FROM exame_resultado z WHERE z.solicitacao_id=x.id) AS resultados FROM exame_solicitacao x JOIN tipo_exame t ON t.id=x.tipo_exame_id WHERE atendimento_id=?', [$id]);
    }

    public function totalPendentes(): array
    {
        return $this->um('SELECT COUNT(*) AS n FROM exame_solicitacao x WHERE NOT EXISTS(SELECT 1 FROM exame_resultado z WHERE z.solicitacao_id=x.id)');
    }

    public function solicitar(int $id, int $tipo): void
    {
        $this->executar('INSERT INTO exame_solicitacao(atendimento_id,tipo_exame_id) VALUES(?,?)', [$id, $tipo]);
    }

    public function coletar(int $id): void
    {
        $this->executar('UPDATE exame_solicitacao SET coletado_em=NOW() WHERE id=?', [$id]);
    }

    public function registrarResultado(ResultadoExame $resultado): void
    {
        $this->executar('INSERT INTO exame_resultado(solicitacao_id,autor_id,resultado) VALUES(?,?,?)', [$resultado->getSolicitacaoId(), $resultado->getAutorId(), $resultado->getResultado()]);
    }
}
