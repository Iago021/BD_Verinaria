<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php modalStart('prescrever','Nova prescrição','prescrever');?>
<input type="hidden" name="atendimento_id">
<label class="wide">Medicamento<select name="medicamento_id" required>
<?php options($clinicoDAO->medicamentos());?>
</select>
</label>
<label class="wide">Posologia<input name="posologia" required maxlength="200">
</label>
<label>Duração (dias)<input type="number" name="duracao_dias" required min="1" max="365">
</label>
<label class="wide">Orientações<textarea name="orientacoes" rows="3">
</textarea>
</label>
<?php modalEnd('Salvar prescrição'); ?>
