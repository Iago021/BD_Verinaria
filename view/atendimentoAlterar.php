<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php modalStart('remarcar','Remarcar atendimento','remarcar');?>
<input type="hidden" name="id">
<label>Início<input type="datetime-local" name="inicio" required>
</label>
<label>Fim<input type="datetime-local" name="fim" required>
</label>
<?php modalEnd('Salvar horário'); ?>
