<?php
define('VETDATA_VIEW', true);
require_once __DIR__.'/../controller/sessao.php';
require_once __DIR__.'/funcoes.php';
require_once __DIR__.'/../controller/prepararDados.php';
$pages=['inicio'=>'Visão geral','agenda'=>'Agenda','pacientes'=>'Pacientes','responsaveis'=>'Responsáveis','equipe'=>'Equipe','exames'=>'Exames','vacinas'=>'Vacinação','financeiro'=>'Financeiro','paciente'=>'Prontuário','atendimento'=>'Atendimento'];
$link = filter_var($_GET['link'] ?? 0, FILTER_VALIDATE_INT);
$p = array_search($link, PAGINAS, true);
if ($p === false) $p = 'inicio';
$flash=$_SESSION['flash']??null;unset($_SESSION['flash']);
$old=$_SESSION['form_old']??null;unset($_SESSION['form_old']);
$hoje=date('Y-m-d');$id=(int)($_GET['id']??0);
if(!$dbError){
 $animals=$animalDAO->ativos();
 $owners=$responsavelDAO->ativos();
 $vets=$veterinarioDAO->ativos();
 $breeds=$animalDAO->racas();
 $openAppointments=$atendimentoDAO->opcoes();
}
?>
<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="description" content="VetData — gestão da clínica veterinária Vida Animal. Projeto acadêmico com dados fictícios.">
<title>
<?=h($pages[$p])?> · VetData</title>
<link rel="icon" type="image/svg+xml" href="img/favicon.svg">
<link rel="stylesheet" href="css/style.css">
<script src="js/app.js" defer>
</script>
</head>
<body>
<a class="skip" href="#main">Ir para o conteúdo</a>
<?php require __DIR__.'/menu.php'; ?>
<div class="app">
<header class="topbar">
<div class="breadcrumb">
<button class="icon-button menu-toggle" aria-label="Abrir menu" aria-expanded="false" aria-controls="sidebar">☰</button>
<span>Clínica Vida Animal</span>
<span class="slash">/</span>
<strong>
<?=h($pages[$p])?>
</strong>
</div>
<span class="top-label">Ambiente acadêmico</span>
<span class="profile" aria-label="Equipe Vida Animal">VA</span>
</header>
<main id="main">
<?php if($dbError):?>
<section class="setup">
<span class="eyebrow">COMECE POR AQUI</span>
<h1>Prepare o banco de dados</h1>
<p>
<?=h($dbError)?>
</p>
<ol>
<li>Inicie o Apache e o MySQL no XAMPP.</li>
<li>Abra o phpMyAdmin e importe <strong>script.sql</strong>.</li>
<li>Confira os dados de conexão em <strong>persist/config.php</strong>.</li>
</ol>
<a class="button" href="admin.php">Tentar novamente</a>
</section>
<?php else:?>
<?php if($flash):?>
<div class="toast <?=h($flash[0])?>" role="status">
<?=h($flash[1])?>
<button type="button" aria-label="Fechar aviso" data-dismiss>×</button>
</div>
<?php endif;?>
<?php
$pag = [
    'inicio' => 'inicio.php',
    'agenda' => 'atendimentoListar.php',
    'pacientes' => 'animalListar.php',
    'responsaveis' => 'responsavelListar.php',
    'equipe' => 'veterinarioListar.php',
    'exames' => 'exameListar.php',
    'vacinas' => 'vacinacaoListar.php',
    'financeiro' => 'financeiroListar.php',
    'paciente' => 'animalProntuario.php',
    'atendimento' => 'atendimentoDetalhar.php',
];
require __DIR__ . '/' . $pag[$p];
?>
<?php require __DIR__.'/formularios.php';?>
<?php if($old):?>
<div id="form-recovery" hidden data-form="<?=h(json_encode($old))?>">
</div>
<?php endif;?>
<?php endif;?>
<footer class="footer">
<span>VetData · Vida Animal</span>
<span>Projeto acadêmico · Dados de demonstração</span>
</footer>
</main>
</div>
</body>
</html>

