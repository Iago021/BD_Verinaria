<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php
$a=$atendimentoDAO->buscar($id);if(!$a){emptyState('Atendimento não encontrado.');return;}
$isCancelled=$a['status']==='CANCELADO';$isOpen=in_array($a['status'],['AGENDADO','CONFIRMADO']);
$notes=$clinicoDAO->porAtendimento($id);
$items=$servicoDAO->porAtendimento($id);
$bill=$financeiroDAO->porAtendimento($id);
$default=['atendimento_id'=>$id,'autor_id'=>$a['veterinario_id'],'profissional_id'=>$a['veterinario_id']];
?>
<a class="back-link" href="?link=1&todas=1">← Agenda</a>
<div class="page-head">
<div>
<div class="eyebrow">ATENDIMENTO #<?=str_pad((string)$id,4,'0',STR_PAD_LEFT)?>
</div>
<h1>
<?=h($a['animal'])?> <span class="heading-badge">
<?=badge($a['status'])?>
</span>
</h1>
<p>
<?=day($a['inicio'])?>, <?=hour($a['inicio'])?> · <?=h($a['veterinario'])?>
</p>
</div>
<a class="button secondary" href="?link=8&id=<?=$a['animal_id']?>">Ver prontuário</a>
</div>
<div class="patient-info">
<div>
<span>Responsável</span>
<strong>
<?=h($a['responsavel'])?>
</strong>
</div>
<div>
<span>Motivo</span>
<strong>
<?=h($a['motivo'])?>
</strong>
</div>
<div>
<span>Espécie</span>
<strong>
<?=h($a['especie'])?>
</strong>
</div>
<?php if($isOpen):?>
<div class="row-actions">
<?php if($a['status']==='AGENDADO'):?>
<form method="post" action="<?=h(controllerUrl('confirmar'))?>">
<?php action('confirmar');?>
<input type="hidden" name="id" value="<?=$id?>">
<button class="button secondary small">Confirmar</button>
</form>
<?php endif;?>
<form method="post" action="<?=h(controllerUrl('concluir'))?>">
<?php action('concluir');?>
<input type="hidden" name="id" value="<?=$id?>">
<button class="button small">Concluir atendimento</button>
</form>
</div>
<?php endif;?>
</div>
<?php if($isCancelled):?>
<div class="notice">Atendimento cancelado. O histórico financeiro foi preservado.</div>
<?php endif;?>
<div class="clinical-grid">
<div>
<section class="panel">
<div class="panel-head">
<h2>Evoluções clínicas</h2>
<?php if(!$isCancelled):?>
<button class="text-link" data-open="clinico" data-values="<?=h(json_encode($default))?>">+ Registrar evolução</button>
<?php endif;?>
</div>
<div class="timeline">
<?php foreach($notes as$c):?>
<article>
<div class="timeline-meta">
<span>
<?=day($c['criado_em'])?> · <?=h($c['autor'])?>
</span>
<span>#<?=$c['id']?>
</span>
</div>
<h3>
<?=$c['retifica_id']?'Retificação de #'.$c['retifica_id']:'Anamnese'?>
</h3>
<p>
<?=nl2br(h($c['anamnese']))?>
</p>
<dl>
<dt>Diagnóstico</dt>
<dd>
<?=nl2br(h($c['diagnostico']))?>
</dd>
<dt>Peso</dt>
<dd>
<?=$c['peso_kg']?h($c['peso_kg']).' kg':'Não informado'?>
</dd>
</dl>
<p class="muted">
<?=nl2br(h($c['observacoes']))?>
</p>
<?php if(!$isCancelled&&!$clinicoDAO->retificacao($c['id'])):?>
<button class="text-button" data-open="clinico" data-values="<?=h(json_encode([...$default,'retifica_id'=>$c['id']]))?>">Acrescentar retificação</button>
<?php endif;?>
</article>
<?php endforeach;?>
<?php if(!$notes)emptyState('Registre a avaliação para iniciar o histórico deste atendimento.');?>
</div>
</section>
<section class="panel section-gap">
<div class="panel-head">
<h2>Prescrições</h2>
<?php if(!$isCancelled):?>
<button class="text-link" data-open="prescrever" data-values="<?=h(json_encode($default))?>">+ Prescrever</button>
<?php endif;?>
</div>
<?php $rx=$clinicoDAO->prescricoes($id);foreach($rx as$r):?>
<div class="detail-row">
<strong>
<?=h($r['nome'])?>
</strong>
<p>
<?=h($r['posologia'])?>
</p>
<small>
<?=h($r['duracao_dias'])?> dias · <?=h($r['orientacoes'])?>
</small>
</div>
<?php endforeach;if(!$rx)emptyState('Nenhuma prescrição neste atendimento.');?>
</section>
<section class="panel section-gap">
<div class="panel-head">
<h2>Exames e vacinas</h2>
</div>
<?php foreach($exameDAO->porAtendimento($id)as$x):?>
<div class="detail-row">
<strong>
<?=h($x['nome'])?>
</strong>
<small>
<?=$x['resultados']?'Resultado disponível':($x['coletado_em']?'Aguardando resultado':'Aguardando coleta')?>
</small>
</div>
<?php endforeach;?>
<?php foreach($vacinaDAO->porAtendimento($id)as$v):?>
<div class="detail-row">
<strong>
<?=h($v['nome'])?>
</strong>
<small>
<?=day($v['aplicada_em'])?> · Lote <?=h($v['codigo'])?> · Reforço <?=day($v['proxima_dose'])?>
</small>
</div>
<?php endforeach;?>
<?php if(!$isCancelled):?>
<div class="panel-actions">
<button class="button secondary" data-open="solicitar_exame" data-values="<?=h(json_encode($default))?>">Solicitar exame</button>
<button class="button secondary" data-open="vacinar" data-values="<?=h(json_encode($default))?>">Registrar vacina</button>
</div>
<?php endif;?>
</section>
</div>
<aside>
<section class="panel">
<div class="panel-head">
<h2>Serviços e cobrança</h2>
<?php if(!$bill&&!$isCancelled):?>
<button class="text-link" data-open="servico" data-values="<?=h(json_encode($default))?>">+ Adicionar</button>
<?php endif;?>
</div>
<?php $total=0;foreach($items as$item):$sum=$item['quantidade']*$item['valor_unitario'];$total+=$sum;?>
<div class="bill-item">
<div>
<strong>
<?=h($item['nome'])?>
</strong>
<small>
<?=$item['quantidade']?> × <?=money($item['valor_unitario'])?>
</small>
</div>
<span>
<?=money($sum)?>
</span>
</div>
<?php endforeach;if(!$items)emptyState('Adicione os serviços realizados.');?>
<div class="bill-total">
<span>Subtotal</span>
<strong>
<?=money($total)?>
</strong>
</div>
<?php if($bill):?>
<div class="bill-summary">
<div>
<span>Desconto</span>
<strong>
<?=h($bill['desconto_pct'])?>%</strong>
</div>
<div>
<span>Total</span>
<strong>
<?=money($bill['total_liquido'])?>
</strong>
</div>
<div>
<span>Recebido</span>
<strong>
<?=money($bill['recebido'])?>
</strong>
</div>
<div>
<span>Saldo</span>
<strong>
<?=money($bill['saldo'])?>
</strong>
</div>
<?=badge($bill['situacao'])?>
<a class="button secondary full" href="?link=7">Abrir financeiro</a>
</div>
<?php elseif(!$isCancelled&&$items):?>
<div class="panel-actions">
<button class="button full" data-open="emitir" data-values="<?=h(json_encode($default))?>">Emitir cobrança</button>
</div>
<?php endif;?>
</section>
</aside>
</div>
