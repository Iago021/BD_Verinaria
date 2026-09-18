<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php
$date=(string)($_GET['data']??$hoje);if(!preg_match('/^\d{4}-\d{2}-\d{2}$/',$date))$date=$hoje;
 $all=isset($_GET['todas']);
 $rows=$atendimentoDAO->listar($date, $all);
?>
<div class="page-head">
<div>
<div class="eyebrow">ROTINA DA CLÍNICA</div>
<h1>Agenda</h1>
<p>Organize os horários de cada profissional.</p>
</div>
<button class="button" data-open="agendar">+ Novo agendamento</button>
</div>
<section class="panel">
<form class="toolbar" method="get">
<input type="hidden" name="link" value="1">
<label class="inline-label">Data <input type="date" name="data" value="<?=h($date)?>">
</label>
<button class="button secondary" type="submit">Ver dia</button>
<a class="button ghost" href="?link=1&todas=1">Todos os atendimentos</a>
<span class="toolbar-end muted">
<?=count($rows)?> registros</span>
</form>
<div class="table-scroll">
<table>
<thead>
<tr>
<th>Data e horário</th>
<th>Paciente</th>
<th>Veterinário</th>
<th>Motivo</th>
<th>Situação</th>
<th>Ações</th>
</tr>
</thead>
<tbody>
<?php foreach($rows as$a):?>
<tr>
<td class="nowrap">
<?=day($a['inicio'])?>
<small>
<?=hour($a['inicio'])?> – <?=hour($a['fim'])?>
</small>
</td>
<td>
<a class="strong-link" href="?link=8&id=<?=$a['animal_id']?>">
<?=h($a['animal'])?>
</a>
<small>
<?=h($a['responsavel'])?>
</small>
</td>
<td>
<?=h($a['veterinario'])?>
</td>
<td>
<?=h($a['motivo'])?>
</td>
<td>
<?=badge($a['status'])?>
</td>
<td>
<div class="row-actions">
<a class="button small secondary" href="?link=9&id=<?=$a['id']?>">Abrir</a>
<?php if(in_array($a['status'],['AGENDADO','CONFIRMADO'])):?>
<button class="text-button" data-open="remarcar" data-values="<?=h(json_encode(['id'=>$a['id'],'inicio'=>str_replace(' ','T',$a['inicio']),'fim'=>str_replace(' ','T',$a['fim'])]))?>">Remarcar</button>
<button class="text-button danger-text" data-open="cancelar" data-values="<?=h(json_encode(['id'=>$a['id']]))?>">Cancelar</button>
<?php endif;?>
</div>
</td>
</tr>
<?php endforeach;?>
</tbody>
</table>
</div>
<?php if(!$rows)emptyState('Nenhum atendimento nesta data. Você pode criar um novo agendamento.');?>
</section>
