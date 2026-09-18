<?php
require_once __DIR__ . '/baseDAO.php';
require_once __DIR__ . '/../model/registroClinico.php';
require_once __DIR__ . '/../model/prescricao.php';

class ClinicoDAO extends BaseDAO
{
    public function medicamentos(): array
    {
        return $this->consultar('SELECT * FROM medicamento ORDER BY nome');
    }

    public function historicoAnimal(int $id): array
    {
        return $this->consultar('SELECT c.*,a.inicio AS consulta,v.nome AS autor FROM registro_clinico c JOIN atendimento a ON a.id=c.atendimento_id JOIN veterinario v ON v.id=c.autor_id WHERE a.animal_id=? ORDER BY a.inicio DESC,c.criado_em DESC,c.id DESC', [$id]);
    }

    public function porAtendimento(int $id): array
    {
        return $this->consultar('SELECT c.*,v.nome AS autor FROM registro_clinico c JOIN veterinario v ON v.id=c.autor_id WHERE atendimento_id=? ORDER BY c.id DESC', [$id]);
    }

    public function retificacao(int $id): array
    {
        return $this->um('SELECT id FROM registro_clinico WHERE retifica_id=?', [$id]);
    }

    public function prescricoes(int $id): array
    {
        return $this->consultar('SELECT p.*,m.nome FROM prescricao p JOIN medicamento m ON m.id=p.medicamento_id WHERE atendimento_id=? ORDER BY p.id DESC', [$id]);
    }

    public function inserir(RegistroClinico $registro): void
    {
        $this->executar('INSERT INTO registro_clinico(atendimento_id,autor_id,anamnese,diagnostico,observacoes,peso_kg,retifica_id) VALUES(?,?,?,?,?,?,?)', [$registro->getAtendimentoId(), $registro->getAutorId(), $registro->getAnamnese(), $registro->getDiagnostico(), $registro->getObservacoes(), $registro->getPesoKg(), $registro->getRetificaId()]);
    }

    public function prescrever(Prescricao $prescricao): void
    {
        $this->executar('INSERT INTO prescricao(atendimento_id,medicamento_id,posologia,duracao_dias,orientacoes) VALUES(?,?,?,?,?)', [$prescricao->getAtendimentoId(), $prescricao->getMedicamentoId(), $prescricao->getPosologia(), $prescricao->getDuracaoDias(), $prescricao->getOrientacoes()]);
    }
}
