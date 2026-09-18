<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php modalStart('agendar','Novo agendamento','agendar'); ?>
<label class="wide">Paciente<select name="animal_id" required>
<option value="">Selecione o paciente</option>
<?php options($animals,'rotulo');?>
</select>
</label>
<label class="wide">Veterinário<select name="veterinario_id" required>
<option value="">Selecione o profissional</option>
<?php options($vets);?>
</select>
</label>
<label>Início<input type="datetime-local" name="inicio" required value="<?=$hoje?>T09:00">
</label>
<label>Fim<input type="datetime-local" name="fim" required value="<?=$hoje?>T09:40">
</label>
<label class="wide">Motivo<input name="motivo" required maxlength="200" placeholder="Ex.: consulta de rotina">
</label>
<p class="form-hint wide">O horário precisa estar disponível para o paciente e o veterinário.</p>
<?php modalEnd('Agendar'); ?>
