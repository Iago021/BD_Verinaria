<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php modalStart('solicitar_exame','Solicitar exame','solicitar_exame');?>
<label class="wide">Atendimento<select name="atendimento_id" required>
<option value="">Selecione o atendimento</option>
<?php options($openAppointments);?>
</select>
</label>
<label class="wide">Exame<select name="tipo_exame_id" required>
<?php options($exameDAO->tipos());?>
</select>
</label>
<?php modalEnd('Solicitar'); ?>
