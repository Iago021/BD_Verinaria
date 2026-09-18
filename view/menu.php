<?php if (!defined('VETDATA_VIEW')) { http_response_code(404); exit; } ?>
<aside class="sidebar" id="sidebar">
<a class="brand" href="admin.php">
<span class="brand-mark">v<span>+</span>
</span>
<span>vetdata<span class="brand-dot">.</span>
</span>
</a>
<div class="workspace">
<span class="clinic-icon">VA</span>
<div>
<strong>Vida Animal</strong>
<small>Clínica veterinária</small>
</div>
</div>
<span class="nav-label">ESPAÇO DE TRABALHO</span>
<nav aria-label="Navegação principal">
<?php foreach(array_slice($pages,0,8,true)as$key=>$label):$active=$p===$key||($p==='paciente'&&$key==='pacientes')||($p==='atendimento'&&$key==='agenda');?>
<a href="?link=<?=PAGINAS[$key]?>" class="nav-item <?=$active?'active':''?>" <?=$active?'aria-current="page"':''?>>
<?=icon($key)?>
<span>
<?=h($label)?>
</span>
</a>
<?php endforeach;?>
</nav>
<div class="sidebar-bottom">
<span class="demo-tag">DADOS FICTÍCIOS</span>
<p>Projeto VetData<br>
<small>Banco de Dados II · 2026</small>
</p>
</div>
</aside>
<button class="scrim" tabindex="-1" aria-label="Fechar menu" hidden>
</button>
