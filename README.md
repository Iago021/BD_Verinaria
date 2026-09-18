# Sistema de Gestão Veterinária 🐾

Bem-vindo ao repositório do **Sistema de Gestão Veterinária**. Esta é uma aplicação web completa, desenvolvida em PHP (utilizando o padrão arquitetural MVC + DAO), projetada para facilitar o controle de todas as rotinas diárias de uma clínica veterinária.

---

## 📋 Visão Geral

A plataforma permite que clínicas gerenciem desde os cadastros básicos (tutores, pacientes e profissionais) até o fluxo completo do atendimento clínico. Ao longo do processo, o sistema integra o acompanhamento médico com a gestão financeira, garantindo que todo serviço prestado gere suas respectivas cobranças.

---

## 🗄️ Modelagem do Banco de Dados

Para facilitar a compreensão da estrutura lógica do sistema, abaixo estão representados os modelos de dados.

### Modelo Conceitual (Diagrama de Entidade-Relacionamento)

Este diagrama ilustra como as entidades interagem entre si na lógica de negócios da clínica, destacando como um Agendamento evolui para um Atendimento, ramificando-se em Exames, Prescrições, Vacinas e faturamento (Cobrança).

> *Para melhor resolução, consulte o PDF: [Modelo Conceitual (PDF)](./downloads/Modelo_Conceitual_Veterinaria.pdf)*

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

Abaixo, a representação visual das tabelas criadas no banco de dados e suas ligações estruturais.

> *Para a tabela completa com tipos de dados, consulte o PDF: [Modelo Relacional (PDF)](./downloads/Modelo_Relacional_Veterinaria.pdf)*

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

---

## 🩺 Funcionalidades Principais

*   **Gestão de Cadastros:** Cadastro de Tutores (Responsáveis), Pacientes (Animais) com suporte a status (Ativo/Inativado, Arquivado/Reativado).
*   **Controle de Agendas:** Configuração de disponibilidade (`disponibilidadeInserir`) por profissional e geração de agendamentos.
*   **Fluxo de Atendimento:** O processo médico tem acompanhamento de status transicionais:
    *   Confirmar
    *   Alterar
    *   Concluir
    *   Cancelar
*   **Prontuário Médico Completo:** Centralização de registros clínicos, laudos de coleta de exames, histórico de vacinação e receitas.
*   **Faturamento:** Os serviços lançados no atendimento disparam automaticamente a criação de cobranças atreladas ao tutor, permitindo a gestão de pagamentos recebidos.

---

## 🛠️ Tecnologias Utilizadas

*   **Linguagem Base:** PHP
*   **Arquitetura:** MVC (Model-View-Controller)
*   **Acesso a Dados:** DAO (Data Access Object) via scripts SQL.
*   **Interface:** HTML, CSS (folhas de estilo personalizadas na pasta view), JS.

---

## 📁 Estrutura do Projeto

O projeto obedece a uma separação de responsabilidades estrita:

```text
/
├── controller/        # Transições de status e lógica de negócios (ex: atendimentoConcluir.php)
├── model/             # Classes de entidades do domínio (ex: animal.php, rotas.php)
├── persist/           # DAO e configuração de banco de dados (ex: conexao.php, animalDAO.php)
├── view/              # Interfaces de usuário, listagens, formulários e assets (css, js, fonts)
├── documentacao/      # Scripts SQL (permissoes.sql, script.sql) e logs de testes
└── index.php          # Ponto de entrada da aplicação
```
