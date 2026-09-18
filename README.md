# Sistema de Gestão Veterinária

Um sistema web completo para gestão de clínicas veterinárias, estruturado com padrão MVC (Model-View-Controller) e DAO (Data Access Object) em PHP.

## 📋 Visão Geral

O sistema permite gerenciar todas as rotinas de uma clínica veterinária, desde o cadastro do paciente e seu tutor até o agendamento, atendimento clínico completo (exames, vacinas, prescrições) e o fluxo financeiro gerado pelas consultas.

## 🗄️ Arquitetura de Banco de Dados

A arquitetura de dados do sistema foi mapeada a partir das entidades e controladores da aplicação. Você pode visualizar os diagramas completos nos PDFs abaixo:

*   [Modelo Conceitual (Entidade-Relacionamento)](./downloads/Modelo_Conceitual_Veterinaria.pdf)
*   [Modelo Relacional](./downloads/Modelo_Relacional_Veterinaria.pdf)

### 📌 Cadastros Principais

*   **Responsável (Tutor):** Pode ser ativado ou inativado no sistema.
*   **Animal (Paciente):** Vinculado a um responsável. Pode ser arquivado ou reativado.
*   **Veterinário:** Profissional que realiza os atendimentos.
*   **Disponibilidade:** Agenda de horários configurada para os médicos veterinários.

### 🩺 Fluxo Clínico

O coração do sistema baseia-se no ciclo de atendimento do paciente:

1.  **Agendamento:** Relaciona um Animal a um Veterinário em uma data e horário específicos.
2.  **Atendimento:** A consulta médica efetiva. Possui os status de Confirmação, Cancelamento e Conclusão.
3.  **Registro Clínico:** Prontuário com as anotações do atendimento.
4.  **Prescrição:** Emissão de receitas médicas.
5.  **Exames e Resultados:** Solicitação de exames no atendimento, com fluxo de coleta de amostras e laudo.
6.  **Vacinação:** Registro da aplicação de vacinas do catálogo durante ou fora da consulta.
7.  **Serviços:** Inclusão de procedimentos realizados no atendimento para composição do valor final.

### 💰 Módulo Financeiro

O sistema gera automaticamente o fluxo financeiro a partir dos atendimentos:

*   **Cobrança:** Gerada vinculada a um atendimento e ao responsável.
*   **Pagamento:** Registro das quitações atreladas às cobranças.
*   **Entrada:** Gestão de outras movimentações (caixa/insumos).

## 🛠️ Tecnologias Utilizadas

*   PHP (Padrão MVC + DAO)
*   Banco de Dados Relacional (SQL)
*   Frontend (HTML, CSS/Estilos Personalizados, JS)

## 📁 Estrutura de Diretórios (Resumo)

*   `/controller`: Lógica de negócios, transições de status e fluxo do sistema (ex: `atendimentoConfirmar.php`).
*   `/model`: Classes de representação de dados das entidades (ex: `animal.php`).
*   `/persist`: Camada DAO para acesso ao banco de dados (ex: `animalDAO.php`).
*   `/view`: Telas, formulários e listagens da aplicação.
*   `/documentacao`: Guias, organização e validações.
