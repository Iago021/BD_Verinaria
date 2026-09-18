<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php modalStart('animal','Cadastro de paciente','animal');?>
<input type="hidden" name="id">
<label>Nome<input name="nome" required maxlength="70">
</label>
<label>Sexo<select name="sexo">
<option value="F">Fêmea</option>
<option value="M">Macho</option>
<option value="NI">Não informado</option>
</select>
</label>
<label class="wide">Responsável<select name="responsavel_id" required>
<option value="">Selecione o responsável</option>
<?php options($owners);?>
</select>
</label>
<label class="wide">Espécie e raça<select name="raca_id" required>
<option value="">Selecione a raça</option>
<?php options($breeds);?>
</select>
</label>
<label>Nascimento<input type="date" name="nascimento" max="<?=$hoje?>">
</label>
<label>Microchip <span class="optional">opcional</span>
<input name="microchip" maxlength="30">
</label>
<?php modalEnd('Salvar paciente'); ?>
