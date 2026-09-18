<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php modalStart('vacinar','Registrar aplicação de vacina','vacinar');?>
<label class="wide">Atendimento<select name="atendimento_id" required>
<option value="">Selecione o atendimento</option>
<?php options($openAppointments);?>
</select>
</label>
<label class="wide">Vacina e lote<select name="lote_id" required>
<option value="">Selecione um lote válido</option>
<?php options($vacinaDAO->lotesValidos());?>
</select>
</label>
<label class="wide">Profissional aplicador<select name="profissional_id" required>
<?php options($vets);?>
</select>
</label>
<label>Data da aplicação<input type="date" name="aplicada_em" max="<?=$hoje?>" value="<?=$hoje?>" required>
</label>
<label>Próxima dose<input type="date" name="proxima_dose">
</label>
<?php modalEnd('Registrar aplicação'); ?>
