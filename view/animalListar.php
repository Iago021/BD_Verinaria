<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php
$search=trim((string)($_GET['q']??''));$arch=isset($_GET['arquivados']);$rows=$animalDAO->listar($search, $arch);
?>
<div class="page-head">
<div>
<div class="eyebrow">CUIDADO CONTÍNUO</div>
<h1>Pacientes</h1>
<p>Cadastros e histórico clínico em um só lugar.</p>
</div>
<button class="button" data-open="animal">+ Novo paciente</button>
</div>
<section class="panel">
<form class="toolbar" method="get">
<input type="hidden" name="link" value="2">
<label class="search-box">
<?=icon('search')?>
<input type="search" name="q" value="<?=h($search)?>" placeholder="Buscar paciente ou responsável" aria-label="Buscar paciente ou responsável">
</label>
<button class="button secondary">Buscar</button>
<a class="text-link toolbar-end" href="?link=2<?=$arch?'':'&arquivados=1'?>">
<?=$arch?'Ver ativos':'Ver arquivados'?>
</a>
</form>
<div class="table-scroll">
<table>
<thead>
<tr>
<th>Paciente</th>
<th>Espécie / raça</th>
<th>Responsável</th>
<th>Nascimento</th>
<th>Ações</th>
</tr>
</thead>
<tbody>
<?php foreach($rows as$n):?>
<tr>
<td>
<div class="person">
<span class="avatar tone-<?=$n['id']%4?>">
<?=h(mb_substr_safe($n['nome']))?>
</span>
<a class="strong-link" href="?link=8&id=<?=$n['id']?>">
<?=h($n['nome'])?>
</a>
</div>
</td>
<td>
<?=h($n['especie'])?>
<small>
<?=h($n['raca'])?>
</small>
</td>
<td>
<?=h($n['responsavel'])?>
</td>
<td>
<?=day($n['nascimento'])?>
</td>
<td>
<div class="row-actions">
<a class="button small secondary" href="?link=8&id=<?=$n['id']?>">Prontuário</a>
<button class="text-button" data-open="animal" data-values="<?=h(json_encode($n))?>">Editar</button>
</div>
</td>
</tr>
<?php endforeach;?>
</tbody>
</table>
</div>
<?php if(!$rows)emptyState('Nenhum paciente encontrado.');?>
</section>
