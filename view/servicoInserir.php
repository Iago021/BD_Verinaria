<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php modalStart('servico','Adicionar serviço','servico');?>
<input type="hidden" name="atendimento_id">
<label class="wide">Serviço<select name="servico_id" data-price-select required>
<option value="">Selecione o serviço</option>
<?php foreach($servicoDAO->catalogo()as$s):?>
<option value="<?=$s['id']?>" data-price="<?=h($s['preco_base'])?>">
<?=h($s['nome'])?>
</option>
<?php endforeach;?>
</select>
</label>
<label>Quantidade<input type="number" name="quantidade" min="1" max="65535" value="1" required>
</label>
<label>Valor unitário (R$)<input type="number" name="valor_unitario" min="0" step="0.01" required>
</label>
<?php modalEnd('Adicionar serviço'); ?>
