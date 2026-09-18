# Sistema de Gestão Veterinária 

### Modelo Conceitual (Diagrama de Entidade-Relacionamento)


```mermaid
erDiagram
    Responsavel ||--o{ Animal : "Possui"
    Animal ||--o{ Agendamento : "Tem"
    Veterinario ||--o{ Agendamento : "Atende"
    
    Agendamento ||--|| Atendimento : "Gera (1:1)"
    Animal ||--o{ Atendimento : "Passa por"
    Veterinario ||--o{ Atendimento : "Realiza"
    
    Atendimento ||--|| Registro_Clinico : "Gera"
    Atendimento ||--o{ Exame_Resultado : "Solicita"
    Atendimento ||--o{ Vacinacao : "Aplica"
    Atendimento ||--o{ Prescricao : "Emite"
    Atendimento }o--o{ Servico : "Inclui"
    
    Atendimento ||--|| Cobranca : "Gera"
    Responsavel ||--o{ Cobranca : "Responsável por"
    Cobranca ||--o{ Pagamento : "Recebe"
```

### Modelo Relacional (Tabelas)

Representação visual das tabelas criadas no banco de dados e suas ligações estruturais.

```mermaid
erDiagram
    %% Cadastros Principais
    RESPONSAVEL {
        INT id_responsavel PK
        VARCHAR nome
        VARCHAR telefone
        BOOLEAN status_ativo
    }
    
    ANIMAL {
        INT id_animal PK
        INT id_responsavel FK
        VARCHAR nome
        VARCHAR especie
        BOOLEAN status_arquivado
    }
    
    VETERINARIO {
        INT id_veterinario PK
        VARCHAR nome
        VARCHAR crmv
    }
    
    DISPONIBILIDADE {
        INT id_disponibilidade PK
        INT id_veterinario FK
        INT dia_semana
        TIME horario_inicio
        TIME horario_fim
    }

    %% Fluxo Clinico
    AGENDAMENTO {
        INT id_agendamento PK
        INT id_animal FK
        INT id_veterinario FK
        DATETIME data_hora
        VARCHAR status
    }
    
    ATENDIMENTO {
        INT id_atendimento PK
        INT id_agendamento FK "NULL"
        INT id_animal FK
        INT id_veterinario FK
        DATETIME data_atendimento
        VARCHAR status_atendimento
    }
    
    REGISTRO_CLINICO {
        INT id_registro PK
        INT id_atendimento FK
        INT id_animal FK
        TEXT observacoes
    }
    
    PRESCRICAO {
        INT id_prescricao PK
        INT id_atendimento FK
        TEXT medicamentos
    }

    %% Procedimentos e Servicos
    SERVICO {
        INT id_servico PK
        VARCHAR descricao
        DECIMAL valor_padrao
    }
    
    SERVICO_ATENDIMENTO {
        INT id_atendimento PK_FK
        INT id_servico PK_FK
        DECIMAL valor_cobrado
    }
    
    EXAME {
        INT id_exame PK
        VARCHAR nome_exame
    }
    
    RESULTADO_EXAME {
        INT id_resultado PK
        INT id_exame FK
        INT id_atendimento FK
        BOOLEAN status_coleta
        TEXT laudo
    }
    
    VACINA {
        INT id_vacina PK
        VARCHAR nome_vacina
    }
    
    VACINACAO {
        INT id_vacinacao PK
        INT id_vacina FK
        INT id_animal FK
        DATE data_aplicacao
    }

    %% Financeiro
    COBRANCA {
        INT id_cobranca PK
        INT id_atendimento FK
        INT id_responsavel FK
        DECIMAL valor_total
        DATE data_vencimento
    }
    
    PAGAMENTO {
        INT id_pagamento PK
        INT id_cobranca FK
        DECIMAL valor_pago
        DATE data_pagamento
    }
    
    ENTRADA {
        INT id_entrada PK
        VARCHAR descricao
        DECIMAL valor
        DATE data_entrada
    }

    %% Relacionamentos
    RESPONSAVEL ||--o{ ANIMAL : ""
    RESPONSAVEL ||--o{ COBRANCA : ""
    
    VETERINARIO ||--o{ DISPONIBILIDADE : ""
    VETERINARIO ||--o{ AGENDAMENTO : ""
    VETERINARIO ||--o{ ATENDIMENTO : ""
    
    ANIMAL ||--o{ AGENDAMENTO : ""
    ANIMAL ||--o{ ATENDIMENTO : ""
    ANIMAL ||--o{ REGISTRO_CLINICO : ""
    ANIMAL ||--o{ VACINACAO : ""
    
    AGENDAMENTO ||--o| ATENDIMENTO : ""
    
    ATENDIMENTO ||--o{ REGISTRO_CLINICO : ""
    ATENDIMENTO ||--o{ PRESCRICAO : ""
    ATENDIMENTO ||--o{ SERVICO_ATENDIMENTO : ""
    ATENDIMENTO ||--o{ RESULTADO_EXAME : ""
    ATENDIMENTO ||--o{ COBRANCA : ""
    
    SERVICO ||--o{ SERVICO_ATENDIMENTO : ""
    
    EXAME ||--o{ RESULTADO_EXAME : ""
    
    VACINA ||--o{ VACINACAO : ""
    
    COBRANCA ||--o{ PAGAMENTO : ""
```
