<?php
// Instancia os DAOs para leitura das telas e trata a conexão inicial.
$dbError = null;
try {
    require_once __DIR__ . '/../persist/veterinarioDAO.php';
    $veterinarioDAO = new VeterinarioDAO();
    require_once __DIR__ . '/../persist/responsavelDAO.php';
    $responsavelDAO = new ResponsavelDAO();
    require_once __DIR__ . '/../persist/animalDAO.php';
    $animalDAO = new AnimalDAO();
    require_once __DIR__ . '/../persist/atendimentoDAO.php';
    $atendimentoDAO = new AtendimentoDAO();
    require_once __DIR__ . '/../persist/financeiroDAO.php';
    $financeiroDAO = new FinanceiroDAO();
    require_once __DIR__ . '/../persist/exameDAO.php';
    $exameDAO = new ExameDAO();
    require_once __DIR__ . '/../persist/vacinaDAO.php';
    $vacinaDAO = new VacinaDAO();
    require_once __DIR__ . '/../persist/painelDAO.php';
    $painelDAO = new PainelDAO();
    require_once __DIR__ . '/../persist/clinicoDAO.php';
    $clinicoDAO = new ClinicoDAO();
    require_once __DIR__ . '/../persist/servicoDAO.php';
    $servicoDAO = new ServicoDAO();
} catch (PDOException $erro) {
    $dbError = 'Não foi possível conectar ao banco VetData.';
    error_log($erro->getMessage());
}
