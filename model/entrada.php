<?php
// Validação dos dados recebidos pelos controllers.
function val($k,$default=''){return trim((string)($_POST[$k]??$default));}
function req($k):string{$v=val($k);if($v==='')throw new InvalidArgumentException('Preencha todos os campos obrigatórios.');return $v;}
function intv($k):int{$v=filter_var(req($k),FILTER_VALIDATE_INT);if($v===false||$v<1)throw new InvalidArgumentException('Escolha um registro válido.');return $v;}
function decimal($k):string{$v=str_replace(',','.',req($k));if(!preg_match('/^\d{1,8}(\.\d{1,2})?$/',$v))throw new InvalidArgumentException('Informe um valor numérico válido.');return $v;}
