<?php
require_once __DIR__ . '/baseDAO.php';
require_once __DIR__ . '/../model/animal.php';

class AnimalDAO extends BaseDAO
{
    public function buscar(int $id): array
    {
        return $this->um('SELECT n.*,r.nome AS responsavel,ra.nome AS raca,e.nome AS especie FROM animal n JOIN responsavel r ON r.id=n.responsavel_id JOIN raca ra ON ra.id=n.raca_id JOIN especie e ON e.id=ra.especie_id WHERE n.id=?', [$id]);
    }

    public function ativos(): array
    {
        return $this->consultar("SELECT n.*,CONCAT(n.nome,' · ',r.nome) AS rotulo FROM animal n JOIN responsavel r ON r.id=n.responsavel_id WHERE n.ativo=1 ORDER BY n.nome");
    }

    public function racas(): array
    {
        return $this->consultar("SELECT r.id,CONCAT(e.nome,' · ',r.nome) AS nome FROM raca r JOIN especie e ON e.id=r.especie_id ORDER BY e.nome,r.nome");
    }

    public function listar(string $search, bool $arch): array
    {
        return $this->consultar('SELECT n.*,ra.nome AS raca,e.nome AS especie,r.nome AS responsavel FROM animal n JOIN raca ra ON ra.id=n.raca_id JOIN especie e ON e.id=ra.especie_id JOIN responsavel r ON r.id=n.responsavel_id WHERE n.ativo=? AND (n.nome LIKE ? OR r.nome LIKE ?) ORDER BY n.nome',[$arch?0:1,'%'.$search.'%','%'.$search.'%']);
    }

    public function salvar(Animal $animal): void
    {
        $dados = [$animal->getResponsavelId(), $animal->getRacaId(), $animal->getNome(),
            $animal->getSexo(), $animal->getNascimento(), $animal->getMicrochip()];
        if ($animal->getId() > 0) {
            $dados[] = $animal->getId();
            $this->executar('UPDATE animal SET responsavel_id=?,raca_id=?,nome=?,sexo=?,nascimento=?,microchip=? WHERE id=?', $dados);
        } else {
            $this->executar('INSERT INTO animal(responsavel_id,raca_id,nome,sexo,nascimento,microchip) VALUES(?,?,?,?,?,?)', $dados);
        }
    }

    public function arquivar(int $id): void
    {
        // O mesmo lock usado pelas procedures evita arquivar durante um agendamento.
        $this->transacao(function () use ($id) {
            $this->um('SELECT id FROM especie WHERE id=1 FOR UPDATE');
            if ($this->um("SELECT id FROM atendimento WHERE animal_id=? AND status IN ('AGENDADO','CONFIRMADO') LIMIT 1", [$id])) {
                throw new InvalidArgumentException('Resolva os agendamentos antes de arquivar este paciente.');
            }
            $this->executar('UPDATE animal SET ativo=0 WHERE id=?', [$id]);
        });
    }

    public function reativar(int $id): void
    {
        $this->executar('UPDATE animal SET ativo=1 WHERE id=?', [$id]);
    }
}
