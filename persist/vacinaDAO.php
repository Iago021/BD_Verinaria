<?php
require_once __DIR__ . '/baseDAO.php';
require_once __DIR__ . '/../model/vacinacao.php';

class VacinaDAO extends BaseDAO
{
    public function lotesValidos(): array
    {
        return $this->consultar("SELECT l.id,CONCAT(v.nome,' · ',l.codigo,' · validade ',DATE_FORMAT(l.validade,'%d/%m/%Y')) AS nome FROM vacina_lote l JOIN vacina v ON v.id=l.vacina_id WHERE l.validade>=CURRENT_DATE ORDER BY v.nome");
    }

    public function pendentes(): array
    {
        return $this->consultar('SELECT * FROM vw_vacinacao_pendente ORDER BY proxima_dose');
    }

    public function historico(): array
    {
        return $this->consultar('SELECT va.*,n.nome AS animal,v.nome AS vacina,l.codigo,pr.nome AS profissional FROM vacinacao va JOIN atendimento a ON a.id=va.atendimento_id JOIN animal n ON n.id=a.animal_id JOIN vacina_lote l ON l.id=va.lote_id JOIN vacina v ON v.id=l.vacina_id JOIN veterinario pr ON pr.id=va.profissional_id ORDER BY va.aplicada_em DESC,va.id DESC');
    }

    public function porAtendimento(int $id): array
    {
        return $this->consultar('SELECT va.*,v.nome,l.codigo FROM vacinacao va JOIN vacina_lote l ON l.id=va.lote_id JOIN vacina v ON v.id=l.vacina_id WHERE atendimento_id=?', [$id]);
    }

    public function totalPendentes(): array
    {
        return $this->um('SELECT COUNT(*) AS n FROM vw_vacinacao_pendente');
    }

    public function inserir(Vacinacao $vacinacao): void
    {
        $this->executar('INSERT INTO vacinacao(atendimento_id,lote_id,profissional_id,aplicada_em,proxima_dose) VALUES(?,?,?,?,?)', [$vacinacao->getAtendimentoId(), $vacinacao->getLoteId(), $vacinacao->getProfissionalId(), $vacinacao->getAplicadaEm(), $vacinacao->getProximaDose()]);
    }
}
