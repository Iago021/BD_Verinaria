<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php modalStart('cancelar','Cancelar atendimento','cancelar');?>
<input type="hidden" name="id">
<p class="wide form-hint">O agendamento e a cobrança serão preservados. Recebimentos serão estornados no controle financeiro interno.</p>
<label class="wide">Motivo do cancelamento<textarea name="motivo" required maxlength="200" rows="3">
</textarea>
</label>
<?php modalEnd('Confirmar cancelamento'); ?>
