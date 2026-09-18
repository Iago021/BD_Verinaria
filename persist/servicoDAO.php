<?php
require_once __DIR__ . '/baseDAO.php';
require_once __DIR__ . '/../model/servicoAtendimento.php';

class ServicoDAO extends BaseDAO
{
    public function catalogo(): array
    {
        return $this->consultar('SELECT * FROM servico ORDER BY nome');
    }

    public function porAtendimento(int $id): array
    {
        return $this->consultar('SELECT i.*,s.nome FROM atendimento_servico i JOIN servico s ON s.id=i.servico_id WHERE atendimento_id=?', [$id]);
    }

    public function inserir(ServicoAtendimento $servico): void
    {
        $this->transacao(function () use ($servico) {
            $this->um('SELECT id FROM atendimento WHERE id=? FOR UPDATE', [$servico->getAtendimentoId()]);
            $this->executar('INSERT INTO atendimento_servico(atendimento_id,servico_id,quantidade,valor_unitario) VALUES(?,?,?,?)', [$servico->getAtendimentoId(), $servico->getServicoId(), $servico->getQuantidade(), $servico->getValorUnitario()]);
        });
    }
}
