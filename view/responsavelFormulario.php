<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php modalStart('responsavel','Cadastro de responsável','responsavel');?>
<input type="hidden" name="id">
<label class="wide">Nome completo<input name="nome" required minlength="2" maxlength="120">
</label>
<label class="wide">Documento <span class="optional">11 dígitos</span>
<input name="documento" inputmode="numeric" pattern="[0-9]{11}" required maxlength="11">
</label>
<label>Telefone<input name="telefone" type="tel" maxlength="160">
</label>
<label>E-mail<input name="email" type="email" maxlength="160">
</label>
<?php modalEnd('Salvar responsável'); ?>
