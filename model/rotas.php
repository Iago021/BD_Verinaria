<?php

const PAGINAS = ['inicio' => 0, 'agenda' => 1, 'pacientes' => 2, 'responsaveis' => 3, 'equipe' => 4, 'exames' => 5, 'vacinas' => 6, 'financeiro' => 7, 'paciente' => 8, 'atendimento' => 9];

const ACOES = [
    'agendar' => 'atendimentoInserir.php',
    'remarcar' => 'atendimentoAlterar.php',
    'cancelar' => 'atendimentoCancelar.php',
    'confirmar' => 'atendimentoConfirmar.php',
    'concluir' => 'atendimentoConcluir.php',
    'animal' => 'animalSalvar.php',
    'arquivar' => 'animalArquivar.php',
    'reativar' => 'animalReativar.php',
    'responsavel' => 'responsavelSalvar.php',
    'inativar_responsavel' => 'responsavelInativar.php',
    'veterinario' => 'veterinarioInserir.php',
    'disponibilidade' => 'disponibilidadeInserir.php',
    'clinico' => 'registroClinicoInserir.php',
    'servico' => 'servicoInserir.php',
    'emitir' => 'cobrancaInserir.php',
    'receber' => 'pagamentoInserir.php',
    'solicitar_exame' => 'exameInserir.php',
    'coletar' => 'exameColetar.php',
    'resultado' => 'exameResultadoInserir.php',
    'vacinar' => 'vacinacaoInserir.php',
    'prescrever' => 'prescricaoInserir.php',
];
