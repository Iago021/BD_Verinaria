<?php
require_once __DIR__ . '/baseDAO.php';
require_once __DIR__ . '/../model/agendamento.php';

class AtendimentoDAO extends BaseDAO
{
    public function porAnimal(int $id): array
    {
        return $this->consultar('SELECT * FROM vw_agenda WHERE animal_id=? ORDER BY inicio DESC', [$id]);
    }

    public function buscar(int $id): array
    {
        return $this->um('SELECT * FROM vw_agenda WHERE id=?', [$id]);
    }

    public function opcoes(): array
    {
        return $this->consultar("SELECT id,CONCAT(animal,' · ',DATE_FORMAT(inicio,'%d/%m %H:%i'),' · #',id) AS nome FROM vw_agenda WHERE status<>'CANCELADO' ORDER BY inicio DESC");
    }

    public function hoje(): array
    {
        return $this->consultar('SELECT * FROM vw_agenda WHERE inicio>=CURRENT_DATE AND inicio<DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY) ORDER BY inicio,veterinario');
    }

    public function listar(string $date, bool $all): array
    {
        $where = $all ? '1=1' : 'inicio>=? AND inicio<DATE_ADD(?,INTERVAL 1 DAY)';
        $params = $all ? [] : [$date, $date];
        return $this->consultar('SELECT * FROM vw_agenda WHERE '.$where.' ORDER BY inicio DESC,id DESC',$params);
    }

    public function inserir(Agendamento $agendamento): void
    {
        // Esta procedure controla sua própria transação.
        $this->executar('CALL sp_agendar(?,?,?,?,?)', [$agendamento->getAnimalId(), $agendamento->getVeterinarioId(), $agendamento->getInicio(), $agendamento->getFim(), $agendamento->getMotivo()]);
    }

    public function remarcar(int $id, string $inicio, string $fim): void
    {
        $this->executar('CALL sp_remarcar(?,?,?)', [$id, $inicio, $fim]);
    }

    public function cancelar(int $id, string $motivo): void
    {
        $this->executar('CALL sp_cancelar(?,?)', [$id, $motivo]);
    }

    public function confirmar(int $id): void
    {
        $this->executar("UPDATE atendimento SET status='CONFIRMADO' WHERE id=?", [$id]);
    }

    public function concluir(int $id): void
    {
        $this->executar("UPDATE atendimento SET status='CONCLUIDO' WHERE id=?", [$id]);
    }
}
