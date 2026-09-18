# VETDATA - Documento de Requisitos (Etapa 1)

**Projeto Integrador de Banco de Dados - Etec**[span_0](start_span)[span_0](end_span)
**Autores:** Euro Albino de Souza e Mag Guapa[span_1](start_span)[span_1](end_span)

---

## 1. Visão Geral e Situação-Problema
A clínica veterinária Vida Animal apresentou um crescimento expressivo no volume de clientes, o que evidenciou as limitações de sua gestão atual[span_2](start_span)[span_2](end_span). O controle de agendas, prontuários, vacinação, exames e pagamentos é feito de forma fragmentada, através de planilhas e arquivos isolados[span_3](start_span)[span_3](end_span). Esse cenário tem gerado cadastros duplicados, perda de histórico clínico, agendamentos conflitantes e baixa visibilidade gerencial[span_4](start_span)[span_4](end_span). 

O projeto VetData tem como objetivo projetar e implementar um banco de dados relacional centralizado (MySQL/MariaDB) que garanta a integridade do histórico dos animais, impeça inconsistências e suporte as operações diárias e a tomada de decisão da clínica[span_5](start_span)[span_5](end_span).

## 2. Atores do Sistema
* **Recepcionistas / Administração:** Utilizam o sistema para gerenciar cadastros de clientes e pacientes, organizar a agenda de consultas e controlar o fluxo financeiro (cobranças e pagamentos).
* **Médicos Veterinários:** Profissionais que acessam o sistema para registrar anamneses, diagnósticos, solicitar exames, aplicar vacinas e emitir prescrições médicas.
* **Gestão (Direção):** Utiliza o sistema para acompanhamento de indicadores, faturamento, demandas e pendências operacionais[span_6](start_span)[span_6](end_span).

## 3. Processos e Escopo Funcional Mínimo
O sistema deverá abranger as seguintes áreas essenciais[span_7](start_span)[span_7](end_span):
* **Clientes e Animais:** Cadastro de responsáveis (tutores) e múltiplos animais, preservando características como espécie e raça[span_8](start_span)[span_8](end_span).
* **Equipe e Agenda:** Registro de veterinários, controle de suas especialidades e horários, permitindo agendar, remarcar e cancelar consultas sem conflitos[span_9](start_span)[span_9](end_span).
* **Atendimento Clínico:** Centralização do prontuário com diagnósticos, observações e procedimentos[span_10](start_span)[span_10](end_span).
* **Exames, Vacinas e Prescrições:** Solicitação e laudo de exames, controle de aplicação de vacinas (com lote e previsão de retorno) e receituários[span_11](start_span)[span_11](end_span).
* **Financeiro e Gestão:** Geração de cobranças atreladas ao atendimento, controle de formas de pagamento e geração de indicadores[span_12](start_span)[span_12](end_span).

## 4. Regras de Negócio (RN)
Para manter a segurança e a consistência dos dados, o sistema obedecerá às seguintes regras (garantidas via estrutura do banco, restrições nativas, triggers ou procedures)[span_13](start_span)[span_13](end_span):

1. **RN01 - Vínculo Obrigatório:** Todo animal deve estar associado a pelo menos um responsável ativo no sistema[span_14](start_span)[span_14](end_span).
2. **RN02 - Prevenção de Conflitos:** Um veterinário não pode possuir dois atendimentos confirmados no mesmo intervalo de horário[span_15](start_span)[span_15](end_span).
3. **RN03 - Composição de Atendimento:** Um atendimento deve obrigatoriamente estar associado a um (1) animal e a um (1) veterinário[span_16](start_span)[span_16](end_span).
4. **RN04 - Integridade de Exames:** Resultados de exames somente podem ser registrados para exames que foram previamente solicitados durante um atendimento[span_17](start_span)[span_17](end_span).
5. **RN05 - Rastreabilidade de Vacinas:** A aplicação de uma vacina deve obrigatoriamente identificar o produto, o lote e o profissional responsável pela aplicação[span_18](start_span)[span_18](end_span).
6. **RN06 - Valores Financeiros Válidos:** Os valores cobrados em serviços, consultas ou faturamentos não podem ser negativos[span_19](start_span)[span_19](end_span).
7. **RN07 - Preservação do Prontuário:** Registros clínicos não devem ser apagados para corrigir histórico, preservando a integridade longitudinal do paciente[span_20](start_span)[span_20](end_span).
8. **RN08 - Controle de Pagamentos:** O valor registrado em um pagamento não pode superar o valor total pendente da cobrança correspondente.
9. **RN09 - Registro Profissional Único:** O cadastro de um médico veterinário deve exigir um CRMV preenchido e único em todo o sistema.
10. **RN10 - Regra de Cancelamento:** Não é possível inserir novos pagamentos em uma cobrança vinculada a um atendimento que foi cancelado.
11. **RN11 - Bloqueio Operacional:** Animais associados a responsáveis com status "inativo" não podem receber novos agendamentos até que o cadastro do tutor seja regularizado.
12. **RN12 - Limite de Descontos:** Valores de desconto aplicados no faturamento financeiro não podem ultrapassar 100% do valor bruto do serviço ou produto.
13. 
