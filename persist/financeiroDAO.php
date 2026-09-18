<?php
require_once __DIR__ . '/baseDAO.php';

class FinanceiroDAO extends BaseDAO
{
    public function formasPagamento(): array
    {
        return $this->consultar('SELECT * FROM forma_pagamento ORDER BY nome');
    }

    public function totais(string $from, string $to): array
    {
        $base = 'emitida_em>=? AND emitida_em<=?';
        $args = [$from, $to];
        return $this->um('SELECT COALESCE(SUM(total_liquido),0) AS faturado,COALESCE(SUM(recebido),0) AS recebido,COALESCE(SUM(saldo),0) AS saldo FROM vw_financeiro WHERE '.$base,$args);
    }

    public function listar(string $from, string $to, bool $filter): array
    {
        $base = 'emitida_em>=? AND emitida_em<=?';
        $args = [$from, $to];
        return $this->consultar('SELECT f.*,n.nome AS animal,r.nome AS responsavel FROM vw_financeiro f JOIN atendimento a ON a.id=f.atendimento_id JOIN animal n ON n.id=a.animal_id JOIN responsavel r ON r.id=n.responsavel_id WHERE '.$base.($filter?' AND f.saldo>0':'').' ORDER BY f.emitida_em DESC,f.id DESC',$args);
    }

    public function categorias(string $from, string $to): array
    {
        $base = 'emitida_em>=? AND emitida_em<=?';
        $args = [$from, $to];
        return $this->consultar('SELECT cat.nome,SUM(ROUND(i.quantidade*i.valor_unitario*(1-c.desconto_pct/100),2)) AS total FROM cobranca c JOIN atendimento_servico i ON i.atendimento_id=c.atendimento_id JOIN servico s ON s.id=i.servico_id JOIN categoria_servico cat ON cat.id=s.categoria_id WHERE c.cancelada=0 AND c.emitida_em>=? AND c.emitida_em<=? GROUP BY cat.id,cat.nome ORDER BY total DESC',$args);
    }

    public function porAtendimento(int $id): array
    {
        return $this->um('SELECT * FROM vw_financeiro WHERE atendimento_id=?', [$id]);
    }

    public function ultimosMeses(): array
    {
        return $this->consultar('SELECT mes,SUM(faturamento) AS valor FROM vw_faturamento_categoria GROUP BY mes ORDER BY mes DESC LIMIT 3');
    }

    public function emitir(int $id, string $desconto, string $vencimento): void
    {
        $this->executar('CALL sp_emitir_cobranca(?,?,?)', [$id, $desconto, $vencimento]);
    }

    public function receber(int $id, int $forma, string $valor): void
    {
        $this->executar('CALL sp_receber(?,?,?)', [$id, $forma, $valor]);
    }
}
