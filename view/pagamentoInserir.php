<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<?php modalStart('receber','Registrar recebimento','receber');?>
<input type="hidden" name="cobranca_id">
<label class="wide">Forma de pagamento<select name="forma_id" required>
<?php options($financeiroDAO->formasPagamento());?>
</select>
</label>
<label class="wide">Valor recebido (R$)<input type="number" name="valor" min="0.01" max="99999999.99" step="0.01" required>
</label>
<p class="form-hint wide">Você pode registrar pagamentos parciais em diferentes formas.</p>
<?php modalEnd('Confirmar recebimento'); ?>
