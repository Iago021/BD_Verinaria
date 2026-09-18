<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php modalStart('disponibilidade','Adicionar horário semanal','disponibilidade');?>
<label class="wide">Profissional<select name="veterinario_id" required>
<?php options($vets);?>
</select>
</label>
<label class="wide">Dia da semana<select name="dia_semana" required>
<?php foreach(['Segunda-feira','Terça-feira','Quarta-feira','Quinta-feira','Sexta-feira','Sábado','Domingo']as$k=>$d):?>
<option value="<?=$k?>">
<?=$d?>
</option>
<?php endforeach;?>
</select>
</label>
<label>Início<input type="time" name="inicio" required>
</label>
<label>Fim<input type="time" name="fim" required>
</label>
<?php modalEnd('Adicionar'); ?>
