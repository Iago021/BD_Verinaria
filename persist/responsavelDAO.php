<?php
require_once __DIR__ . '/baseDAO.php';
require_once __DIR__ . '/../model/responsavel.php';

class ResponsavelDAO extends BaseDAO
{
    public function ativos(): array
    {
        return $this->consultar('SELECT * FROM responsavel WHERE ativo=1 ORDER BY nome');
    }

    public function listar(): array
    {
        return $this->consultar("SELECT r.*, (SELECT GROUP_CONCAT(c.valor SEPARATOR ', ') FROM contato_responsavel c WHERE c.responsavel_id=r.id AND c.tipo='EMAIL') AS email,(SELECT GROUP_CONCAT(c.valor SEPARATOR ', ') FROM contato_responsavel c WHERE c.responsavel_id=r.id AND c.tipo='TELEFONE') AS telefone,(SELECT COUNT(*) FROM animal n WHERE n.responsavel_id=r.id) AS animais FROM responsavel r ORDER BY r.ativo DESC,r.nome");
    }

    public function salvar(Responsavel $responsavel): void
    {
        $this->transacao(function () use ($responsavel) {
            $id = $responsavel->getId();
            if ($id > 0) {
                $this->executar('UPDATE responsavel SET nome=?,documento=? WHERE id=?', [$responsavel->getNome(), $responsavel->getDocumento(), $id]);
                $this->executar('DELETE FROM contato_responsavel WHERE responsavel_id=?', [$id]);
            } else {
                $this->executar('INSERT INTO responsavel(nome,documento) VALUES(?,?)', [$responsavel->getNome(), $responsavel->getDocumento()]);
                $id = (int)$this->pdo->lastInsertId();
            }
            foreach (['EMAIL' => $responsavel->getEmail(), 'TELEFONE' => $responsavel->getTelefone()] as $tipo => $valor) {
                if ($valor !== '') $this->executar('INSERT INTO contato_responsavel(responsavel_id,tipo,valor) VALUES(?,?,?)', [$id, $tipo, $valor]);
            }
        });
    }

    public function inativar(int $id): void
    {
        $this->executar('UPDATE responsavel SET ativo=0 WHERE id=?', [$id]);
    }
}
