<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php
$rows=$vacinaDAO->pendentes();$history=$vacinaDAO->historico();?>
<div class="page-head">
<div>
<div class="eyebrow">PREVENÇÃO E CONTROLE</div>
<h1>Vacinação</h1>
<p>Aplicações, lotes e próximos reforços.</p>
</div>
<button class="button" data-open="vacinar">+ Registrar aplicação</button>
</div>
<section class="panel">
<div class="panel-head">
<h2>Reforços a acompanhar <span class="count">
<?=count($rows)?>
</span>
</h2>
<span class="muted">Próximos 30 dias e vencidos</span>
</div>
<div class="table-scroll">
<table>
<thead>
<tr>
<th>Paciente</th>
<th>Vacina</th>
<th>Próxima dose</th>
<th>Situação</th>
<th>
</th>
</tr>
</thead>
<tbody>
<?php foreach($rows as$v):?>
<tr>
<td>
<strong>
<?=h($v['animal'])?>
</strong>
<small>
<?=h($v['responsavel'])?>
</small>
</td>
<td>
<?=h($v['vacina'])?>
</td>
<td>
<?=day($v['proxima_dose'])?>
</td>
<td>
<?=badge($v['situacao'])?>
<small>
<?=$v['dias']<0?abs($v['dias']).' dias em atraso':($v['dias']==0?'Prevista para hoje':'Em '.$v['dias'].' dias')?>
</small>
</td>
<td>
<button class="button small secondary" data-open="agendar" data-values="<?=h(json_encode(['animal_id'=>$v['animal_id'],'motivo'=>'Reforço de vacinação']))?>">Agendar</button>
</td>
</tr>
<?php endforeach;?>
</tbody>
</table>
</div>
<?php if(!$rows)emptyState('Nenhum reforço pendente nos próximos 30 dias.');?>
</section>
<section class="panel section-gap">
<div class="panel-head">
<h2>Histórico de aplicações</h2>
</div>
<div class="table-scroll">
<table>
<thead>
<tr>
<th>Paciente / produto</th>
<th>Lote</th>
<th>Aplicação</th>
<th>Profissional</th>
<th>Próxima dose</th>
</tr>
</thead>
<tbody>
<?php foreach($history as$v):?>
<tr>
<td>
<strong>
<?=h($v['animal'])?>
</strong>
<small>
<?=h($v['vacina'])?>
</small>
</td>
<td>
<?=h($v['codigo'])?>
</td>
<td>
<?=day($v['aplicada_em'])?>
</td>
<td>
<?=h($v['profissional'])?>
</td>
<td>
<?=day($v['proxima_dose'])?>
</td>
</tr>
<?php endforeach;?>
</tbody>
</table>
</div>
</section>
