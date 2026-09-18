<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php modalStart('emitir','Emitir cobrança','emitir');?>
<input type="hidden" name="atendimento_id">
<label>Desconto (%)<input type="number" name="desconto_pct" value="0" min="0" max="30" step="0.01" required>
</label>
<label>Vencimento<input type="date" name="vencimento" value="<?=date('Y-m-d',strtotime('+7 days'))?>" min="<?=$hoje?>" required>
</label>
<p class="form-hint wide">Após a emissão, os serviços e valores desta cobrança ficam preservados.</p>
<?php modalEnd('Emitir cobrança'); ?>
