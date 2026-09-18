<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php
$filter=($_GET['filtro']??'')==='abertas';$from=(string)($_GET['de']??date('Y-m-01',strtotime('-2 months')));$to=(string)($_GET['ate']??date('Y-m-d'));
 if(!preg_match('/^\d{4}-\d{2}-\d{2}$/',$from))$from=$hoje;if(!preg_match('/^\d{4}-\d{2}-\d{2}$/',$to))$to=$hoje;
 $totals=$financeiroDAO->totais($from, $to);
 $rows=$financeiroDAO->listar($from, $to, $filter);
 $cats=$financeiroDAO->categorias($from, $to);
?>
<div class="page-head">
<div>
<div class="eyebrow">GESTÃO DA CLÍNICA</div>
<h1>Financeiro</h1>
<p>Acompanhe cobranças, recebimentos e saldos.</p>
</div>
</div>
<form class="period-form" method="get">
<input type="hidden" name="link" value="7">
<label>De <input type="date" name="de" value="<?=h($from)?>" required>
</label>
<label>Até <input type="date" name="ate" value="<?=h($to)?>" required>
</label>
<button class="button secondary">Aplicar período</button>
</form>
<section class="metrics three">
<div>
<span>Faturamento no período</span>
<strong class="currency">
<?=money($totals['faturado'])?>
</strong>
<small>Total líquido das cobranças emitidas</small>
</div>
<div>
<span>Recebido dessas cobranças</span>
<strong class="currency">
<?=money($totals['recebido'])?>
</strong>
<small>Acumulado, descontando estornos</small>
</div>
<div>
<span>Saldo a receber</span>
<strong class="currency">
<?=money($totals['saldo'])?>
</strong>
<small>Das cobranças do período</small>
</div>
</section>
<div class="category-strip">
<?php foreach($cats as$c):?>
<div>
<span>
<?=h($c['nome'])?>
</span>
<strong>
<?=money($c['total'])?>
</strong>
</div>
<?php endforeach;?>
</div>
<div class="tabs">
<a class="<?=$filter?'':'selected'?>" href="?link=7&de=<?=h($from)?>&ate=<?=h($to)?>">Todas as cobranças</a>
<a class="<?=$filter?'selected':''?>" href="?link=7&filtro=abertas&de=<?=h($from)?>&ate=<?=h($to)?>">Em aberto</a>
</div>
<section class="panel">
<div class="table-scroll">
<table>
<thead>
<tr>
<th>Cobrança</th>
<th>Paciente / responsável</th>
<th>Total</th>
<th>Recebido</th>
<th>Saldo</th>
<th>Vencimento</th>
<th>Situação</th>
<th>
</th>
</tr>
</thead>
<tbody>
<?php foreach($rows as$f):?>
<tr>
<td>
<a class="strong-link" href="?link=9&id=<?=$f['atendimento_id']?>">#<?=str_pad((string)$f['id'],4,'0',STR_PAD_LEFT)?>
</a>
<small>
<?=day($f['emitida_em'])?>
</small>
</td>
<td>
<strong>
<?=h($f['animal'])?>
</strong>
<small>
<?=h($f['responsavel'])?>
</small>
</td>
<td class="nowrap">
<?=money($f['total_liquido'])?>
</td>
<td class="nowrap">
<?=money($f['recebido'])?>
</td>
<td class="nowrap">
<?=money($f['saldo'])?>
</td>
<td>
<?=day($f['vencimento'])?>
</td>
<td>
<?=badge($f['situacao'])?>
</td>
<td>
<?php if($f['saldo']>0):?>
<button class="button small secondary" data-open="receber" data-values="<?=h(json_encode(['cobranca_id'=>$f['id'],'valor'=>$f['saldo']]))?>">Receber</button>
<?php endif;?>
</td>
</tr>
<?php endforeach;?>
</tbody>
</table>
</div>
<?php if(!$rows)emptyState('Nenhuma cobrança para o período e filtro escolhidos.');?>
</section>
