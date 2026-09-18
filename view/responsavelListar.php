<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php
$rows=$responsavelDAO->listar();?>
<div class="page-head">
<div>
<div class="eyebrow">REDE DE CUIDADO</div>
<h1>Responsáveis</h1>
<p>Pessoas, contatos e animais vinculados.</p>
</div>
<button class="button" data-open="responsavel">+ Novo responsável</button>
</div>
<section class="panel">
<div class="table-scroll">
<table>
<thead>
<tr>
<th>Nome</th>
<th>Contato</th>
<th>Animais</th>
<th>Situação</th>
<th>Ações</th>
</tr>
</thead>
<tbody>
<?php foreach($rows as$r):?>
<tr>
<td>
<strong>
<?=h($r['nome'])?>
</strong>
<small>Documento <?=h($r['documento'])?>
</small>
</td>
<td>
<?=h($r['telefone']?:'Sem telefone')?>
<small>
<?=h($r['email'])?>
</small>
</td>
<td>
<?=$r['animais']?>
</td>
<td>
<?=$r['ativo']?'Ativo':'Inativo'?>
</td>
<td>
<button class="button small secondary" data-open="responsavel" data-values="<?=h(json_encode($r))?>">Editar</button>
<?php if($r['ativo']&&$r['animais']==0):?>
<form class="inline" method="post" action="<?=h(controllerUrl('inativar_responsavel'))?>">
<?php action('inativar_responsavel');?>
<input type="hidden" name="id" value="<?=$r['id']?>">
<button class="text-button">Inativar</button>
</form>
<?php endif;?>
</td>
</tr>
<?php endforeach;?>
</tbody>
</table>
</div>
</section>
