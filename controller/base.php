<?php
require_once __DIR__ . '/sessao.php';
require_once __DIR__ . '/../model/entrada.php';
require_once __DIR__ . '/../model/rotas.php';

function executarAcao(callable $operacao, string $pagina, ?string $campoId = null): never
{
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        http_response_code(405);
        header('Allow: POST');
        exit('Esta operação deve ser enviada pelo formulário.');
    }
    $destino = '../view/admin.php?link=' . PAGINAS[$pagina];
    try {
        if (!hash_equals($_SESSION['csrf'], val('csrf'))) {
            throw new InvalidArgumentException('Sua sessão mudou. Atualize a página e tente novamente.');
        }
        // Valide o destino antes de executar a escrita.
        if ($campoId !== null) $destino .= '&id=' . intv($campoId);
        $operacao();
        $_SESSION['flash'] = ['ok', 'Registro salvo com sucesso.'];
    } catch (Throwable $erro) {
        $mensagem = $erro instanceof InvalidArgumentException ? $erro->getMessage() : 'Não foi possível salvar. Confira os dados e tente novamente.';
        if ($erro instanceof PDOException) {
            $codigo = (int)($erro->errorInfo[1] ?? 0);
            if ($codigo === 1644) $mensagem = (string)$erro->errorInfo[2];
            elseif ($codigo === 1062) $mensagem = 'Este registro já existe. Confira documento, microchip, CRMV ou horário.';
            elseif (in_array($codigo, [4025, 3819])) $mensagem = 'Um valor está fora do limite permitido. Confira datas, valores e desconto máximo de 30%.';
            elseif (in_array($codigo, [1451, 1452, 1048])) $mensagem = 'Confira os vínculos e campos obrigatórios deste registro.';
            else error_log($erro->getMessage());
        } elseif (!$erro instanceof InvalidArgumentException) {
            error_log($erro->getMessage());
        }
        $_SESSION['flash'] = ['error', $mensagem];
        $_SESSION['form_old'] = $_POST;
        $origem = filter_var($_POST['origem_link'] ?? 0, FILTER_VALIDATE_INT);
        if ($origem !== false && in_array($origem, PAGINAS, true)) {
            $destino = '../view/admin.php?link=' . $origem;
            $id = filter_var($_POST['origem_id'] ?? 0, FILTER_VALIDATE_INT);
            if ($id !== false && $id > 0) $destino .= '&id=' . $id;
        }
    }
    header('Location: ' . $destino, true, 303);
    exit;
}
