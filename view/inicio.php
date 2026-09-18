<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php
$metrics=$painelDAO->indicadores();
 $today=$atendimentoDAO->hoje();
 $vacc=$vacinaDAO->totalPendentes()['n'];
 $exams=$exameDAO->totalPendentes()['n'];
 $monthnames=['janeiro','fevereiro','março','abril','maio','junho','julho','agosto','setembro','outubro','novembro','dezembro'];
 $days=['domingo','segunda-feira','terça-feira','quarta-feira','quinta-feira','sexta-feira','sábado'];
?>
<div class="page-head">
<div>
<div class="eyebrow">
<?=h($days[(int)date('w')])?>, <?=date('d')?> de <?=$monthnames[(int)date('n')-1]?>
</div>
<h1>Um olhar sobre a clínica.</h1>
<p>Acompanhe os atendimentos e o que precisa da sua atenção.</p>
</div>
<button class="button" data-open="agendar">
<span>+</span> Novo agendamento</button>
</div>
<section class="metrics" aria-label="Indicadores da clínica">
<a href="?link=1">
<span>Atendimentos hoje</span>
<strong>
<?=$metrics['agenda']?>
</strong>
<small>Na agenda do dia</small>
</a>
<a href="?link=2">
<span>Pacientes ativos</span>
<strong>
<?=$metrics['pacientes']?>
</strong>
<small>Com acompanhamento</small>
</a>
<a href="?link=7">
<span>Faturamento do mês</span>
<strong class="currency">
<?=money($metrics['faturamento'])?>
</strong>
<small>Cobranças emitidas no mês</small>
</a>
<a href="?link=7&filtro=abertas">
<span>Cobranças em aberto</span>
<strong>
<?=$metrics['pendencias']?>
</strong>
<small>Recebimentos a acompanhar</small>
</a>
</section>
<div class="dashboard-grid">
<section class="panel">
<div class="panel-head">
<div>
<h2>Agenda de hoje <span class="count">
<?=count($today)?>
</span>
</h2>
<p>
<?=day($hoje)?>
</p>
</div>
<a class="text-link" href="?link=1">Ver agenda <?=icon('chevron')?>
</a>
</div>
<div class="table-scroll">
<table>
<thead>
<tr>
<th>Horário</th>
<th>Paciente</th>
<th>Veterinário</th>
<th>Situação</th>
<th>
<span class="sr-only">Abrir</span>
</th>
</tr>
</thead>
<tbody>
<?php foreach($today as$a):?>
<tr>
<td class="time">
<?=hour($a['inicio'])?>
<small>
<?=hour($a['fim'])?>
</small>
</td>
<td>
<div class="person">
<span class="avatar tone-<?=($a['animal_id']%4)?>">
<?=h(mb_substr_safe($a['animal']))?>
</span>
<div>
<a class="strong-link" href="?link=8&id=<?=$a['animal_id']?>">
<?=h($a['animal'])?>
</a>
<small>
<?=h($a['especie'])?> · <?=h($a['responsavel'])?>
</small>
</div>
</div>
</td>
<td>
<?=h($a['veterinario'])?>
</td>
<td>
<?=badge($a['status'])?>
</td>
<td>
<a class="icon-link" href="?link=9&id=<?=$a['id']?>" aria-label="Abrir atendimento de <?=h($a['animal'])?>">
<?=icon('chevron')?>
</a>
</td>
</tr>
<?php endforeach;?>
</tbody>
</table>
</div>
<?php if(!$today)emptyState('Nenhum atendimento agendado para hoje.');?>
</section>
<div class="right-rail">
<section class="panel attention">
<div class="panel-head">
<h2>Precisa de atenção</h2>
</div>
<a href="?link=6">
<span class="attention-icon amber">
<?=icon('vacinas')?>
</span>
<div>
<strong>
<?=$vacc?> reforços de vacina</strong>
<small>Vencidos ou nos próximos 30 dias</small>
</div>
<?=icon('chevron')?>
</a>
<a href="?link=5&filtro=pendentes">
<span class="attention-icon blue">
<?=icon('exames')?>
</span>
<div>
<strong>
<?=$exams?> exames pendentes</strong>
<small>Aguardando coleta ou resultado</small>
</div>
<?=icon('chevron')?>
</a>
<a href="?link=7&filtro=abertas">
<span class="attention-icon pink">
<?=icon('financeiro')?>
</span>
<div>
<strong>
<?=$metrics['pendencias']?> cobranças abertas</strong>
<small>Confira os saldos a receber</small>
</div>
<?=icon('chevron')?>
</a>
</section>
<section class="panel compact">
<div class="panel-head">
<h2>Faturamento por mês</h2>
</div>
<?php $chart=$financeiroDAO->ultimosMeses();$max=$chart?max(array_column($chart,'valor')):1;foreach(array_reverse($chart)as$c):?>
<div class="bar-row">
<div>
<span>
<?=h(substr($c['mes'],5).'/'.substr($c['mes'],0,4))?>
</span>
<strong>
<?=money($c['valor'])?>
</strong>
</div>
<div class="bar-track">
<div style="width:<?=max(2,100*(float)$c['valor']/max(1,(float)$max))?>%">
</div>
</div>
</div>
<?php endforeach;?>
<p class="caption">Por emissão de cobrança, já com descontos.</p>
</section>
</div>
</div>
