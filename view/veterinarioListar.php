<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php
$rows=$veterinarioDAO->listar();?>
<div class="page-head">
<div>
<div class="eyebrow">PROFISSIONAIS</div>
<h1>Equipe</h1>
<p>Especialidades e disponibilidade para atendimento.</p>
</div>
<button class="button" data-open="veterinario">+ Novo profissional</button>
</div>
<div class="team-grid">
<?php foreach($rows as$v):?>
<article class="panel team-card">
<span class="avatar large tone-<?=$v['id']%4?>">
<?=h(mb_substr_safe($v['nome']))?>
</span>
<h2>
<?=h($v['nome'])?>
</h2>
<p>
<?=h($v['especialidades']?:'Especialidade não informada')?>
</p>
<span class="muted">
<?=h($v['crmv'])?> · <?=$v['ativo']?'Ativo':'Inativo'?>
</span>
<div class="availability">
<?php $ds=['Seg','Ter','Qua','Qui','Sex','Sáb','Dom'];foreach($veterinarioDAO->horarios($v['id'])as$d):?>
<div>
<span>
<?=$ds[$d['dia_semana']]?>
</span>
<span>
<?=substr($d['inicio'],0,5)?> – <?=substr($d['fim'],0,5)?>
</span>
</div>
<?php endforeach;?>
</div>
<button class="button secondary full" data-open="disponibilidade" data-values="<?=h(json_encode(['veterinario_id'=>$v['id']]))?>">Adicionar horário</button>
</article>
<?php endforeach;?>
</div>
