<?php
require_once __DIR__ . "/../model/rotas.php";
function h($s):string { return htmlspecialchars((string)($s??''),ENT_QUOTES|ENT_SUBSTITUTE,'UTF-8'); }
function money($n):string{return 'R$ '.number_format((float)$n,2,',','.');}
function day($v):string{return $v?date('d/m/Y',strtotime((string)$v)):'Não informada';}
function hour($v):string{return date('H:i',strtotime((string)$v));}
function title($v):string{return ['AGENDADO'=>'Agendado','CONFIRMADO'=>'Confirmado','CONCLUIDO'=>'Concluído','CANCELADO'=>'Cancelado','PAGA'=>'Paga','ATRASADA'=>'Atrasada','PARCIAL'=>'Parcial','ABERTA'=>'Aberta','CANCELADA'=>'Cancelada','VENCIDA'=>'Vencida','PROXIMA'=>'Próxima'][$v]??(string)$v;}
function badge($s):string{return '<span class="badge '.h(strtolower((string)$s)).'">'.h(title($s)).'</span>';}
function options(array $rows,string $label='nome',$selected=null):void{
 foreach($rows as$r)echo '<option value="'.h($r['id']).'"'.((string)$selected===(string)$r['id']?' selected':'').'>'.h($r[$label]).'</option>';
}
function modalStart($id,$heading,$action):void{echo '<dialog id="'.h($id).'" aria-labelledby="'.h($id).'-title">
<form method="post" action="'.h(controllerUrl($action)).'">
<div class="dialog-head">
<h2 id="'.h($id).'-title">'.h($heading).'</h2>
<button type="button" class="icon-button" data-close aria-label="Fechar">×</button>
</div>
<div class="form-grid">';action($action);echo '<input type="hidden" name="dialog" value="'.h($id).'">';}
function modalEnd($label='Salvar'):void{echo '</div>
<div class="dialog-foot">
<button type="button" class="button secondary" data-close>Voltar</button>
<button class="button" type="submit">'.h($label).'</button>
</div>
</form>
</dialog>';}
function emptyState($message):void{echo '<div class="empty">'.h($message).'</div>';}
function icon($name):string{
 $paths=['inicio'=>'<rect x="3" y="3" width="7" height="7" rx="1"/>
<rect x="14" y="3" width="7" height="7" rx="1"/>
<rect x="3" y="14" width="7" height="7" rx="1"/>
<rect x="14" y="14" width="7" height="7" rx="1"/>','agenda'=>'<rect x="3" y="5" width="18" height="16" rx="2"/>
<path d="M16 3v4M8 3v4M3 11h18"/>','pacientes'=>'<path d="M12 3v18M3 12h18"/>
<circle cx="12" cy="12" r="9"/>','responsaveis'=>'<circle cx="9" cy="8" r="3"/>
<path d="M3 21v-3a6 6 0 0 1 12 0v3M16 4a3 3 0 0 1 0 6M21 21v-3a6 6 0 0 0-3-5"/>','equipe'=>'<rect x="3" y="7" width="18" height="14" rx="2"/>
<path d="M8 7V3h8v4M12 10v8M8 14h8"/>','exames'=>'<path d="M9 3h6M10 3v7l-6 9a1 1 0 0 0 1 2h14a1 1 0 0 0 1-2l-6-9V3M8 15h8"/>','vacinas'=>'<path d="m16 3 5 5M8 12l4 4M6 14l4 4M3 21l4-4M14 5l5 5-8 8H6v-5z"/>','financeiro'=>'<rect x="3" y="5" width="18" height="14" rx="2"/>
<path d="M3 10h18M7 15h3"/>','chevron'=>'<path d="m9 5 7 7-7 7"/>','search'=>'<circle cx="10" cy="10" r="6"/>
<path d="m15 15 5 5"/>'];
 return '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">'.($paths[$name]??$paths['pacientes']).'</svg>';
}

function mb_substr_safe($str):string{return preg_match('/^./u',(string)$str,$m)?$m[0]:'';}

function controllerUrl(string $action): string
{
    return '../controller/' . (ACOES[$action] ?? throw new InvalidArgumentException('Ação inválida.'));
}

function token(): void
{
    echo '<input type="hidden" name="csrf" value="' . h($_SESSION['csrf']) . '">';
}

function action(string $name): void
{
    global $p, $id;
    token();
    echo '<input type="hidden" name="action" value="' . h($name) . '">';
    echo '<input type="hidden" name="origem_link" value="' . PAGINAS[$p] . '">';
    echo '<input type="hidden" name="origem_id" value="' . (int)$id . '">';
}
