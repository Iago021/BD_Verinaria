<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php modalStart('resultado','Registrar resultado de exame','resultado');?>
<input type="hidden" name="solicitacao_id">
<label class="wide">Veterinário autor<select name="autor_id" required>
<?php options($vets);?>
</select>
</label>
<label class="wide">Resultado<textarea name="resultado" required rows="6">
</textarea>
</label>
<p class="form-hint wide">Um novo laudo mantém os resultados anteriores disponíveis.</p>
<?php modalEnd('Salvar resultado'); ?>
