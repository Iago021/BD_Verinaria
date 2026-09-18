<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php
$pending=($_GET['filtro']??'')==='pendentes';
 $rows=$exameDAO->listar($pending);
?>
<div class="page-head">
<div>
<div class="eyebrow">ACOMPANHAMENTO CLÍNICO</div>
<h1>Exames</h1>
<p>Da solicitação ao resultado, com o histórico preservado.</p>
</div>
<button class="button" data-open="solicitar_exame">+ Solicitar exame</button>
</div>
<div class="tabs">
<a class="<?=$pending?'':'selected'?>" href="?link=5">Todos os exames</a>
<a class="<?=$pending?'selected':''?>" href="?link=5&filtro=pendentes">Pendentes</a>
</div>
<section class="panel">
<div class="table-scroll">
<table>
<thead>
<tr>
<th>Exame</th>
<th>Paciente</th>
<th>Solicitado em</th>
<th>Etapa</th>
<th>Ação</th>
</tr>
</thead>
<tbody>
<?php foreach($rows as$x):?>
<tr>
<td>
<strong>
<?=h($x['tipo'])?>
</strong>
<small>Pedido #<?=$x['id']?>
</small>
</td>
<td>
<?=h($x['animal'])?>
<small>
<?=h($x['veterinario'])?>
</small>
</td>
<td>
<?=day($x['solicitado_em'])?>
</td>
<td>
<span class="badge <?=$x['resultados']?'paga':'aberta'?>">
<?=$x['resultados']?'Concluído':($x['coletado_em']?'Aguardando resultado':'Aguardando coleta')?>
</span>
</td>
<td>
<?php if(!$x['coletado_em']):?>
<form method="post" action="<?=h(controllerUrl('coletar'))?>">
<?php action('coletar');?>
<input type="hidden" name="id" value="<?=$x['id']?>">
<button class="button small secondary">Registrar coleta</button>
</form>
<?php else:?>
<button class="button small secondary" data-open="resultado" data-values="<?=h(json_encode(['solicitacao_id'=>$x['id']]))?>">
<?=$x['resultados']?'Novo laudo / correção':'Registrar resultado'?>
</button>
<?php endif;?>
</td>
</tr>
<?php if($x['resultados']):?>
<tr class="result-row">
<td colspan="5">
<details>
<summary>Ver histórico de resultados (<?=$x['resultados']?>)</summary>
<?php foreach($exameDAO->resultados($x['id'])as$z):?>
<div class="result-text">
<strong>
<?=day($z['registrado_em'])?> · <?=h($z['autor'])?>
</strong>
<p>
<?=nl2br(h($z['resultado']))?>
</p>
</div>
<?php endforeach;?>
</details>
</td>
</tr>
<?php endif;endforeach;?>
</tbody>
</table>
</div>
<?php if(!$rows)emptyState('Nenhum exame nesta seleção.');?>
</section>
