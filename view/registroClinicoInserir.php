<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php modalStart('clinico','Evolução clínica','clinico');?>
<input type="hidden" name="atendimento_id">
<input type="hidden" name="retifica_id">
<label class="wide">Veterinário autor<select name="autor_id" required>
<?php options($vets);?>
</select>
</label>
<label class="wide">Anamnese<textarea name="anamnese" required rows="3">
</textarea>
</label>
<label class="wide">Diagnóstico<textarea name="diagnostico" required rows="3">
</textarea>
</label>
<label>Peso (kg)<input type="number" min="0.01" max="9999.99" step="0.01" name="peso_kg">
</label>
<label class="wide">Observações<textarea name="observacoes" rows="2">
</textarea>
</label>
<p class="form-hint wide">O registro será preservado. Correções são acrescentadas como retificações.</p>
<?php modalEnd('Salvar evolução'); ?>
