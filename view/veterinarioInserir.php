<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php modalStart('veterinario','Novo profissional','veterinario');?>
<label class="wide">Nome<input name="nome" required maxlength="120">
</label>
<label>CRMV / UF<input name="crmv" required maxlength="24">
</label>
<label>Especialidade<select name="especialidade_id" required>
<?php options($veterinarioDAO->especialidades());?>
</select>
</label>
<p class="form-hint wide">Após o cadastro, adicione os horários de disponibilidade.</p>
<?php modalEnd('Cadastrar'); ?>
