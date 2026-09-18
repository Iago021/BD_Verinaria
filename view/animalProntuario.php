<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php

 $n=$animalDAO->buscar($id);
 if(!$n){emptyState('Paciente não encontrado.');return;}
 $notes=$clinicoDAO->historicoAnimal($id);
 $visits=$atendimentoDAO->porAnimal($id);
?>
<a class="back-link" href="?link=2">← Pacientes</a>
<div class="page-head">
<div class="patient-heading">
<span class="avatar xl tone-<?=$id%4?>">
<?=h(mb_substr_safe($n['nome']))?>
</span>
<div>
<div class="eyebrow">PRONTUÁRIO #<?=str_pad((string)$id,4,'0',STR_PAD_LEFT)?>
</div>
<h1>
<?=h($n['nome'])?>
</h1>
<p>
<?=h($n['especie'])?> · <?=h($n['raca'])?> · <?=$n['ativo']?'Paciente ativo':'Cadastro arquivado'?>
</p>
</div>
</div>
<button class="button" data-open="agendar" data-values="<?=h(json_encode(['animal_id'=>$id]))?>">+ Agendar atendimento</button>
</div>
<div class="patient-info">
<div>
<span>Responsável</span>
<strong>
<?=h($n['responsavel'])?>
</strong>
</div>
<div>
<span>Nascimento</span>
<strong>
<?=day($n['nascimento'])?>
</strong>
</div>
<div>
<span>Sexo</span>
<strong>
<?=h(['M'=>'Macho','F'=>'Fêmea','NI'=>'Não informado'][$n['sexo']])?>
</strong>
</div>
<div>
<span>Microchip</span>
<strong>
<?=h($n['microchip']?:'Não informado')?>
</strong>
</div>
</div>
<div class="clinical-grid">
<section class="panel">
<div class="panel-head">
<h2>Histórico clínico</h2>
<span class="muted">
<?=count($notes)?> registros</span>
</div>
<div class="timeline">
<?php foreach($notes as$c):?>
<article>
<div class="timeline-meta">
<span>
<?=day($c['consulta'])?> · <?=h($c['autor'])?>
</span>
<a href="?link=9&id=<?=$c['atendimento_id']?>">Atendimento #<?=$c['atendimento_id']?> ↗</a>
</div>
<h3>
<?=$c['retifica_id']?'Retificação do registro #'.h($c['retifica_id']):'Evolução clínica'?>
</h3>
<p>
<?=nl2br(h($c['anamnese']))?>
</p>
<dl>
<dt>Diagnóstico</dt>
<dd>
<?=nl2br(h($c['diagnostico']))?>
</dd>
<?php if($c['peso_kg']):?>
<dt>Peso</dt>
<dd>
<?=h($c['peso_kg'])?> kg</dd>
<?php endif;?>
</dl>
<?php if($c['observacoes']):?>
<p class="muted">
<?=nl2br(h($c['observacoes']))?>
</p>
<?php endif;?>
<small>Lançado em <?=day($c['criado_em'])?> às <?=hour($c['criado_em'])?> · Registro #<?=$c['id']?>
</small>
</article>
<?php endforeach;?>
<?php if(!$notes)emptyState('O primeiro registro aparecerá após o atendimento.');?>
</div>
</section>
<aside>
<section class="panel">
<div class="panel-head">
<h2>Atendimentos</h2>
</div>
<?php foreach($visits as$v):?>
<a class="visit-row" href="?link=9&id=<?=$v['id']?>">
<div>
<strong>
<?=day($v['inicio'])?> · <?=hour($v['inicio'])?>
</strong>
<small>
<?=h($v['veterinario'])?>
</small>
</div>
<?=badge($v['status'])?>
</a>
<?php endforeach;?>
</section>
<div class="archive-box">
<p>O prontuário permanece disponível mesmo com o cadastro arquivado.</p>
<form method="post" action="<?=h(controllerUrl($n['ativo']?'arquivar':'reativar'))?>">
<?php action($n['ativo']?'arquivar':'reativar');?>
<input type="hidden" name="id" value="<?=$id?>">
<button class="button secondary full">
<?=$n['ativo']?'Arquivar paciente':'Reativar paciente'?>
</button>
</form>
</div>
</aside>
</div>

