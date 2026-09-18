-- VETDATA | INSTALAÇÃO COMPLETA | v1.0 | 17/09/2026
-- Importar uma única vez em banco vazio. Requer permissão CREATE DATABASE e CREATE ROUTINE.
-- Não executar os arquivos separados depois deste. Perfis opcionais em 07_permissoes.sql.


-- INÍCIO: 02_criacao.sql
-- VETDATA | 02_criacao.sql | 17/09/2026
-- MariaDB 10.4+ / MySQL 8.0.16+. Executar uma vez em banco vazio.
-- Sem DROP DATABASE: uma segunda importação falha sem apagar dados.
CREATE DATABASE IF NOT EXISTS vetdata CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE vetdata;
SET NAMES utf8mb4;
SET time_zone = '-03:00';
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET SESSION sql_mode = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Pessoa responsável pelo animal.
CREATE TABLE responsavel (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(120) NOT NULL,
  documento CHAR(11) NOT NULL UNIQUE,
  ativo BOOLEAN NOT NULL DEFAULT TRUE,
  criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (CHAR_LENGTH(TRIM(nome)) >= 2),
  CHECK (documento REGEXP '^[0-9]{11}$'),
  CHECK (ativo IN (0,1))
) ENGINE=InnoDB;

-- Contatos multivalorados separados do cadastro.
CREATE TABLE contato_responsavel (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  responsavel_id INT UNSIGNED NOT NULL,
  tipo ENUM('EMAIL','TELEFONE') NOT NULL,
  valor VARCHAR(160) NOT NULL,
  FOREIGN KEY (responsavel_id) REFERENCES responsavel(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  UNIQUE (responsavel_id,tipo,valor),
  CHECK (CHAR_LENGTH(TRIM(valor)) > 0)
) ENGINE=InnoDB;

-- Catálogo de espécies.
CREATE TABLE especie (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Raça pertencente a uma espécie.
CREATE TABLE raca (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  especie_id INT UNSIGNED NOT NULL,
  nome VARCHAR(70) NOT NULL,
  FOREIGN KEY (especie_id) REFERENCES especie(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  UNIQUE (especie_id,nome)
) ENGINE=InnoDB;

-- Paciente com um responsável principal obrigatório.
CREATE TABLE animal (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  responsavel_id INT UNSIGNED NOT NULL,
  raca_id INT UNSIGNED NOT NULL,
  nome VARCHAR(70) NOT NULL,
  sexo ENUM('F','M','NI') NOT NULL DEFAULT 'NI',
  nascimento DATE NULL,
  microchip VARCHAR(30) NULL UNIQUE,
  ativo BOOLEAN NOT NULL DEFAULT TRUE,
  criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (responsavel_id) REFERENCES responsavel(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  FOREIGN KEY (raca_id) REFERENCES raca(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CHECK (CHAR_LENGTH(TRIM(nome)) > 0),
  CHECK (ativo IN (0,1)),
  INDEX idx_animal_nome (nome)
) ENGINE=InnoDB;

-- Catálogo de especialidades veterinárias.
CREATE TABLE especialidade (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Profissional e identificação no conselho.
CREATE TABLE veterinario (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(120) NOT NULL,
  crmv VARCHAR(24) NOT NULL UNIQUE,
  ativo BOOLEAN NOT NULL DEFAULT TRUE,
  CHECK (ativo IN (0,1))
) ENGINE=InnoDB;

-- Associação N:N entre profissionais e especialidades.
CREATE TABLE veterinario_especialidade (
  veterinario_id INT UNSIGNED NOT NULL,
  especialidade_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (veterinario_id,especialidade_id),
  FOREIGN KEY (veterinario_id) REFERENCES veterinario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  FOREIGN KEY (especialidade_id) REFERENCES especialidade(id) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;

-- Janelas semanais de trabalho.
CREATE TABLE disponibilidade (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  veterinario_id INT UNSIGNED NOT NULL,
  dia_semana TINYINT UNSIGNED NOT NULL,
  inicio TIME NOT NULL,
  fim TIME NOT NULL,
  FOREIGN KEY (veterinario_id) REFERENCES veterinario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CHECK (dia_semana BETWEEN 0 AND 6),
  CHECK (fim > inicio),
  UNIQUE (veterinario_id,dia_semana,inicio)
) ENGINE=InnoDB;

-- Agenda e ciclo de um atendimento.
CREATE TABLE atendimento (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  animal_id INT UNSIGNED NOT NULL,
  veterinario_id INT UNSIGNED NOT NULL,
  inicio DATETIME NOT NULL,
  fim DATETIME NOT NULL,
  motivo VARCHAR(200) NOT NULL,
  status ENUM('AGENDADO','CONFIRMADO','CONCLUIDO','CANCELADO') NOT NULL DEFAULT 'AGENDADO',
  criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (animal_id) REFERENCES animal(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  FOREIGN KEY (veterinario_id) REFERENCES veterinario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CHECK (fim > inicio),
  CHECK (CHAR_LENGTH(TRIM(motivo)) > 0),
  INDEX idx_agenda_vet_periodo (veterinario_id,inicio,fim,status),
  INDEX idx_historico_animal (animal_id,inicio),
  INDEX idx_agenda_status_inicio (status,inicio)
) ENGINE=InnoDB;

-- Evoluções clínicas imutáveis; correção é novo registro.
CREATE TABLE registro_clinico (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  atendimento_id INT UNSIGNED NOT NULL,
  autor_id INT UNSIGNED NOT NULL,
  anamnese TEXT NOT NULL,
  diagnostico TEXT NOT NULL,
  observacoes TEXT NULL,
  peso_kg DECIMAL(6,2) NULL,
  retifica_id INT UNSIGNED NULL UNIQUE,
  criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (atendimento_id) REFERENCES atendimento(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  FOREIGN KEY (autor_id) REFERENCES veterinario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  FOREIGN KEY (retifica_id) REFERENCES registro_clinico(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CHECK (peso_kg IS NULL OR peso_kg > 0),
  CHECK (CHAR_LENGTH(TRIM(anamnese)) > 0 AND CHAR_LENGTH(TRIM(diagnostico)) > 0)
) ENGINE=InnoDB;

-- Categoria usada no faturamento gerencial.
CREATE TABLE categoria_servico (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Catálogo e preço sugerido atual.
CREATE TABLE servico (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  categoria_id INT UNSIGNED NOT NULL,
  nome VARCHAR(90) NOT NULL UNIQUE,
  preco_base DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (categoria_id) REFERENCES categoria_servico(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CHECK (preco_base >= 0)
) ENGINE=InnoDB;

-- Itens realizados e preço histórico praticado.
CREATE TABLE atendimento_servico (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  atendimento_id INT UNSIGNED NOT NULL,
  servico_id INT UNSIGNED NOT NULL,
  quantidade SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  valor_unitario DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (atendimento_id) REFERENCES atendimento(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  FOREIGN KEY (servico_id) REFERENCES servico(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CHECK (quantidade > 0),
  CHECK (valor_unitario >= 0)
) ENGINE=InnoDB;

-- Catálogo de exames solicitáveis.
CREATE TABLE tipo_exame (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(90) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Pedido anterior à coleta e ao resultado.
CREATE TABLE exame_solicitacao (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  atendimento_id INT UNSIGNED NOT NULL,
  tipo_exame_id INT UNSIGNED NOT NULL,
  solicitado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  coletado_em DATETIME NULL,
  FOREIGN KEY (atendimento_id) REFERENCES atendimento(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  FOREIGN KEY (tipo_exame_id) REFERENCES tipo_exame(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CHECK (coletado_em IS NULL OR coletado_em >= solicitado_em)
) ENGINE=InnoDB;

-- Resultados versionados por acréscimo, sem sobrescrita.
CREATE TABLE exame_resultado (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  solicitacao_id INT UNSIGNED NOT NULL,
  autor_id INT UNSIGNED NOT NULL,
  resultado TEXT NOT NULL,
  registrado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (solicitacao_id) REFERENCES exame_solicitacao(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  FOREIGN KEY (autor_id) REFERENCES veterinario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CHECK (CHAR_LENGTH(TRIM(resultado)) > 0)
) ENGINE=InnoDB;

-- Produto vacinal e espécie de destino.
CREATE TABLE vacina (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(90) NOT NULL UNIQUE,
  especie_id INT UNSIGNED NOT NULL,
  FOREIGN KEY (especie_id) REFERENCES especie(id) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;

-- Rastreabilidade e validade do lote.
CREATE TABLE vacina_lote (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  vacina_id INT UNSIGNED NOT NULL,
  codigo VARCHAR(40) NOT NULL,
  validade DATE NOT NULL,
  FOREIGN KEY (vacina_id) REFERENCES vacina(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  UNIQUE (vacina_id,codigo),
  CHECK (CHAR_LENGTH(TRIM(codigo)) > 0)
) ENGINE=InnoDB;

-- Aplicação realizada no contexto do atendimento.
CREATE TABLE vacinacao (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  atendimento_id INT UNSIGNED NOT NULL,
  lote_id INT UNSIGNED NOT NULL,
  profissional_id INT UNSIGNED NOT NULL,
  aplicada_em DATE NOT NULL,
  proxima_dose DATE NULL,
  FOREIGN KEY (atendimento_id) REFERENCES atendimento(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  FOREIGN KEY (lote_id) REFERENCES vacina_lote(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  FOREIGN KEY (profissional_id) REFERENCES veterinario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CHECK (proxima_dose IS NULL OR proxima_dose > aplicada_em),
  INDEX idx_vacina_proxima (proxima_dose)
) ENGINE=InnoDB;

-- Catálogo de medicamentos de demonstração.
CREATE TABLE medicamento (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Itens prescritos, vinculados ao atendimento.
CREATE TABLE prescricao (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  atendimento_id INT UNSIGNED NOT NULL,
  medicamento_id INT UNSIGNED NOT NULL,
  posologia VARCHAR(200) NOT NULL,
  duracao_dias SMALLINT UNSIGNED NOT NULL,
  orientacoes TEXT NULL,
  criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (atendimento_id) REFERENCES atendimento(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  FOREIGN KEY (medicamento_id) REFERENCES medicamento(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CHECK (duracao_dias BETWEEN 1 AND 365),
  CHECK (CHAR_LENGTH(TRIM(posologia)) > 0)
) ENGINE=InnoDB;

-- Uma cobrança por atendimento; total calculado dos itens.
CREATE TABLE cobranca (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  atendimento_id INT UNSIGNED NOT NULL UNIQUE,
  desconto_pct DECIMAL(5,2) NOT NULL DEFAULT 0,
  emitida_em DATE NOT NULL,
  vencimento DATE NOT NULL,
  cancelada BOOLEAN NOT NULL DEFAULT FALSE,
  FOREIGN KEY (atendimento_id) REFERENCES atendimento(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CHECK (desconto_pct BETWEEN 0 AND 30),
  CHECK (vencimento >= emitida_em),
  CHECK (cancelada IN (0,1)),
  INDEX idx_cobranca_periodo (emitida_em,cancelada)
) ENGINE=InnoDB;

-- Formas permitidas para recebimentos.
CREATE TABLE forma_pagamento (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(40) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Recebimentos parciais imutáveis.
CREATE TABLE pagamento (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  cobranca_id INT UNSIGNED NOT NULL,
  forma_id INT UNSIGNED NOT NULL,
  valor DECIMAL(10,2) NOT NULL,
  pago_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cobranca_id) REFERENCES cobranca(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  FOREIGN KEY (forma_id) REFERENCES forma_pagamento(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CHECK (valor > 0),
  INDEX idx_pagamento_data (pago_em)
) ENGINE=InnoDB;

-- Estorno integral de um pagamento; lançamento separado.
CREATE TABLE estorno (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  pagamento_id INT UNSIGNED NOT NULL UNIQUE,
  motivo VARCHAR(200) NOT NULL,
  estornado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (pagamento_id) REFERENCES pagamento(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CHECK (CHAR_LENGTH(TRIM(motivo)) > 0)
) ENGINE=InnoDB;

-- Auditoria do cancelamento de atendimento.
CREATE TABLE cancelamento (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  atendimento_id INT UNSIGNED NOT NULL UNIQUE,
  motivo VARCHAR(200) NOT NULL,
  cancelado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (atendimento_id) REFERENCES atendimento(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CHECK (CHAR_LENGTH(TRIM(motivo)) > 0)
) ENGINE=InnoDB;

-- FIM: 02_criacao.sql

-- INÍCIO: 05_programacao.sql
-- VETDATA | 05_programacao.sql
-- Instalar ANTES da carga para testar os dados sob as mesmas regras de produção.
USE vetdata;

CREATE VIEW vw_agenda AS
SELECT a.id,a.inicio,a.fim,a.status,a.motivo,a.animal_id,a.veterinario_id,
       n.nome AS animal,e.nome AS especie,r.nome AS responsavel,v.nome AS veterinario
FROM atendimento a JOIN animal n ON n.id=a.animal_id
JOIN raca ra ON ra.id=n.raca_id JOIN especie e ON e.id=ra.especie_id
JOIN responsavel r ON r.id=n.responsavel_id JOIN veterinario v ON v.id=a.veterinario_id;

CREATE VIEW vw_financeiro AS
SELECT x.*, GREATEST(x.total_liquido-x.recebido,0) AS saldo,
  CASE WHEN x.cancelada=1 THEN 'CANCELADA'
       WHEN x.recebido>=x.total_liquido THEN 'PAGA'
       WHEN x.vencimento<CURRENT_DATE THEN 'ATRASADA'
       WHEN x.recebido>0 THEN 'PARCIAL' ELSE 'ABERTA' END AS situacao
FROM (
 SELECT c.id,c.atendimento_id,c.desconto_pct,c.emitida_em,c.vencimento,c.cancelada,
   COALESCE(it.bruto,0) AS total_bruto,COALESCE(it.liquido,0) AS total_original,
   CASE WHEN c.cancelada=1 THEN 0 ELSE COALESCE(it.liquido,0) END AS total_liquido,
   COALESCE(p.recebido,0) AS recebido
 FROM cobranca c
 LEFT JOIN (SELECT b.id, SUM(s.quantidade*s.valor_unitario) AS bruto,
   SUM(ROUND(s.quantidade*s.valor_unitario*(1-b.desconto_pct/100),2)) AS liquido
   FROM cobranca b JOIN atendimento_servico s ON s.atendimento_id=b.atendimento_id GROUP BY b.id) it ON it.id=c.id
 LEFT JOIN (SELECT pg.cobranca_id,SUM(CASE WHEN es.id IS NULL THEN pg.valor ELSE 0 END) AS recebido
   FROM pagamento pg LEFT JOIN estorno es ON es.pagamento_id=pg.id GROUP BY pg.cobranca_id) p ON p.cobranca_id=c.id
) x;

CREATE VIEW vw_faturamento_categoria AS
SELECT DATE_FORMAT(c.emitida_em,'%Y-%m') AS mes,cat.id AS categoria_id,cat.nome AS categoria,
       SUM(ROUND(s.quantidade*s.valor_unitario*(1-c.desconto_pct/100),2)) AS faturamento,
       SUM(s.quantidade) AS quantidade
FROM cobranca c JOIN atendimento_servico s ON s.atendimento_id=c.atendimento_id
JOIN servico se ON se.id=s.servico_id JOIN categoria_servico cat ON cat.id=se.categoria_id
WHERE c.cancelada=0 GROUP BY DATE_FORMAT(c.emitida_em,'%Y-%m'),cat.id,cat.nome;

-- Considera apenas a última aplicação de cada produto em cada animal.
CREATE VIEW vw_vacinacao_pendente AS
SELECT va.id,a.animal_id,n.nome AS animal,r.nome AS responsavel,v.nome AS vacina,
       va.proxima_dose,DATEDIFF(va.proxima_dose,CURRENT_DATE) AS dias,
       CASE WHEN va.proxima_dose<CURRENT_DATE THEN 'VENCIDA' ELSE 'PROXIMA' END AS situacao
FROM vacinacao va JOIN atendimento a ON a.id=va.atendimento_id
JOIN animal n ON n.id=a.animal_id JOIN responsavel r ON r.id=n.responsavel_id
JOIN vacina_lote l ON l.id=va.lote_id JOIN vacina v ON v.id=l.vacina_id
WHERE n.ativo=1 AND va.proxima_dose<=DATE_ADD(CURRENT_DATE,INTERVAL 30 DAY)
 AND NOT EXISTS (SELECT 1 FROM vacinacao vb JOIN atendimento ab ON ab.id=vb.atendimento_id
   JOIN vacina_lote lb ON lb.id=vb.lote_id
   WHERE ab.animal_id=a.animal_id AND lb.vacina_id=l.vacina_id
     AND (vb.aplicada_em>va.aplicada_em OR (vb.aplicada_em=va.aplicada_em AND vb.id>va.id)));

DELIMITER $$
CREATE PROCEDURE sp_validar_agenda(IN p_id INT,IN p_animal INT,IN p_vet INT,IN p_inicio DATETIME,IN p_fim DATETIME)
SQL SECURITY DEFINER
BEGIN
 IF NOT EXISTS(SELECT 1 FROM animal n JOIN responsavel r ON r.id=n.responsavel_id WHERE n.id=p_animal AND n.ativo=1 AND r.ativo=1) THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Animal e responsável precisam estar ativos'; END IF;
 IF NOT EXISTS(SELECT 1 FROM veterinario WHERE id=p_vet AND ativo=1) THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Veterinário inativo ou inexistente'; END IF;
 IF DATE(p_inicio)<>DATE(p_fim) OR NOT EXISTS(SELECT 1 FROM disponibilidade WHERE veterinario_id=p_vet
   AND dia_semana=WEEKDAY(p_inicio) AND TIME(p_inicio)>=inicio AND TIME(p_fim)<=fim) THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Horário fora da disponibilidade'; END IF;
 IF EXISTS(SELECT 1 FROM atendimento WHERE id<>p_id AND status<>'CANCELADO'
   AND (veterinario_id=p_vet OR animal_id=p_animal) AND inicio<p_fim AND fim>p_inicio) THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Conflito de horário do veterinário ou animal'; END IF;
END$$

-- Os procedimentos de agenda são a porta de escrita dos perfis operacionais.
-- O mutex único evita corrida inclusive quando o mesmo animal usa veterinários distintos.
-- É uma linha existente de catálogo, bloqueada somente durante a transação curta.
CREATE PROCEDURE sp_agendar(IN p_animal INT,IN p_vet INT,IN p_inicio DATETIME,IN p_fim DATETIME,IN p_motivo VARCHAR(200))
SQL SECURITY DEFINER
BEGIN
 DECLARE v_lock INT;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
 START TRANSACTION;
 SELECT id INTO v_lock FROM especie WHERE id=1 FOR UPDATE;
 INSERT INTO atendimento(animal_id,veterinario_id,inicio,fim,motivo) VALUES(p_animal,p_vet,p_inicio,p_fim,p_motivo);
 SET @vetdata_novo_id=LAST_INSERT_ID();
 COMMIT;
 SELECT @vetdata_novo_id AS id;
END$$

CREATE PROCEDURE sp_remarcar(IN p_id INT,IN p_inicio DATETIME,IN p_fim DATETIME)
SQL SECURITY DEFINER
BEGIN
 DECLARE v_lock INT;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
 START TRANSACTION;
 SELECT id INTO v_lock FROM especie WHERE id=1 FOR UPDATE;
 IF NOT EXISTS(SELECT 1 FROM atendimento WHERE id=p_id AND status IN ('AGENDADO','CONFIRMADO')) THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Somente agendamentos abertos podem ser remarcados'; END IF;
 UPDATE atendimento SET inicio=p_inicio,fim=p_fim WHERE id=p_id;
 COMMIT;
END$$

CREATE PROCEDURE sp_receber(IN p_cobranca INT,IN p_forma INT,IN p_valor DECIMAL(10,2))
SQL SECURITY DEFINER
BEGIN
 DECLARE v_id INT DEFAULT NULL;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
 START TRANSACTION;
 SELECT id INTO v_id FROM cobranca WHERE id=p_cobranca FOR UPDATE;
 IF v_id IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Cobrança inexistente'; END IF;
 INSERT INTO pagamento(cobranca_id,forma_id,valor) VALUES(p_cobranca,p_forma,p_valor);
 COMMIT;
END$$

CREATE PROCEDURE sp_cancelar(IN p_id INT,IN p_motivo VARCHAR(200))
SQL SECURITY DEFINER
BEGIN
 DECLARE v_lock INT;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
 START TRANSACTION;
 SELECT id INTO v_lock FROM especie WHERE id=1 FOR UPDATE;
 SELECT id INTO v_lock FROM atendimento WHERE id=p_id FOR UPDATE;
 IF NOT EXISTS(SELECT 1 FROM atendimento WHERE id=p_id AND status IN ('AGENDADO','CONFIRMADO')) THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Atendimento já concluído, cancelado ou inexistente'; END IF;
 IF EXISTS(SELECT 1 FROM registro_clinico WHERE atendimento_id=p_id)
 OR EXISTS(SELECT 1 FROM vacinacao WHERE atendimento_id=p_id)
 OR EXISTS(SELECT 1 FROM prescricao WHERE atendimento_id=p_id)
 OR EXISTS(SELECT 1 FROM exame_solicitacao WHERE atendimento_id=p_id) THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Atendimento com histórico clínico não pode ser cancelado'; END IF;
 IF EXISTS(SELECT 1 FROM cobranca WHERE atendimento_id=p_id) THEN
   SELECT id INTO v_lock FROM cobranca WHERE atendimento_id=p_id FOR UPDATE;
 END IF;
 INSERT INTO estorno(pagamento_id,motivo)
 SELECT p.id,p_motivo FROM pagamento p JOIN cobranca c ON c.id=p.cobranca_id
 WHERE c.atendimento_id=p_id AND NOT EXISTS(SELECT 1 FROM estorno e WHERE e.pagamento_id=p.id);
 UPDATE cobranca SET cancelada=1 WHERE atendimento_id=p_id;
 INSERT INTO cancelamento(atendimento_id,motivo) VALUES(p_id,p_motivo);
 UPDATE atendimento SET status='CANCELADO' WHERE id=p_id;
 COMMIT;
END$$

CREATE PROCEDURE sp_emitir_cobranca(IN p_atendimento INT,IN p_desconto DECIMAL(5,2),IN p_vencimento DATE)
SQL SECURITY DEFINER
BEGIN
 DECLARE v_lock INT;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
 START TRANSACTION;
 SELECT id INTO v_lock FROM atendimento WHERE id=p_atendimento FOR UPDATE;
 INSERT INTO cobranca(atendimento_id,desconto_pct,emitida_em,vencimento)
 VALUES(p_atendimento,p_desconto,CURRENT_DATE,p_vencimento);
 COMMIT;
END$$

CREATE TRIGGER tr_animal_insert BEFORE INSERT ON animal FOR EACH ROW
BEGIN
 IF NOT EXISTS(SELECT 1 FROM responsavel WHERE id=NEW.responsavel_id AND ativo=1) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Responsável ativo obrigatório'; END IF;
 IF NEW.nascimento>CURRENT_DATE THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Nascimento não pode ser futuro'; END IF;
END$$

CREATE TRIGGER tr_animal_update BEFORE UPDATE ON animal FOR EACH ROW
BEGIN
 IF NOT EXISTS(SELECT 1 FROM responsavel WHERE id=NEW.responsavel_id AND ativo=1) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Responsável ativo obrigatório'; END IF;
 IF NEW.nascimento>CURRENT_DATE THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Nascimento não pode ser futuro'; END IF;
END$$

CREATE TRIGGER tr_responsavel_inativar BEFORE UPDATE ON responsavel FOR EACH ROW
BEGIN
 IF NEW.ativo=0 AND EXISTS(SELECT 1 FROM animal WHERE responsavel_id=OLD.id) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Transfira todos os animais antes de inativar o responsável'; END IF;
END$$

CREATE TRIGGER tr_veterinario_inativar BEFORE UPDATE ON veterinario FOR EACH ROW
BEGIN
 IF NEW.ativo=0 AND EXISTS(SELECT 1 FROM atendimento WHERE veterinario_id=OLD.id AND status IN ('AGENDADO','CONFIRMADO')) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Resolva a agenda aberta antes de inativar o veterinário'; END IF;
END$$

CREATE TRIGGER tr_agenda_insert BEFORE INSERT ON atendimento FOR EACH ROW
BEGIN
 CALL sp_validar_agenda(0,NEW.animal_id,NEW.veterinario_id,NEW.inicio,NEW.fim);
 IF NEW.status<>'AGENDADO' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Novo atendimento deve iniciar como AGENDADO'; END IF;
END$$

CREATE TRIGGER tr_agenda_update BEFORE UPDATE ON atendimento FOR EACH ROW
BEGIN
 IF OLD.status IN ('CONCLUIDO','CANCELADO') THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Agenda encerrada é imutável'; END IF;
 IF NEW.animal_id<>OLD.animal_id OR NEW.veterinario_id<>OLD.veterinario_id THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Animal e veterinário não podem ser trocados; cancele e reagende'; END IF;
 IF NEW.status<>'CANCELADO' THEN CALL sp_validar_agenda(OLD.id,NEW.animal_id,NEW.veterinario_id,NEW.inicio,NEW.fim); END IF;
 IF NEW.status='CONCLUIDO' AND NOT EXISTS(SELECT 1 FROM registro_clinico WHERE atendimento_id=OLD.id) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Registre a evolução clínica antes de concluir'; END IF;
 IF NEW.status='CANCELADO' AND NOT EXISTS(SELECT 1 FROM cancelamento WHERE atendimento_id=OLD.id) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Use sp_cancelar para preservar histórico financeiro'; END IF;
END$$

CREATE TRIGGER tr_registro_insert BEFORE INSERT ON registro_clinico FOR EACH ROW
BEGIN
 IF NOT EXISTS(SELECT 1 FROM atendimento WHERE id=NEW.atendimento_id AND status<>'CANCELADO') THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Atendimento inexistente ou cancelado'; END IF;
 IF NOT EXISTS(SELECT 1 FROM veterinario WHERE id=NEW.autor_id AND ativo=1) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Autor deve ser veterinário ativo'; END IF;
 IF NEW.retifica_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM registro_clinico WHERE id=NEW.retifica_id AND atendimento_id=NEW.atendimento_id) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Retificação deve apontar registro do mesmo atendimento'; END IF;
END$$

CREATE TRIGGER tr_exame_coleta BEFORE UPDATE ON exame_solicitacao FOR EACH ROW
BEGIN
 IF NEW.atendimento_id<>OLD.atendimento_id OR NEW.tipo_exame_id<>OLD.tipo_exame_id OR NEW.solicitado_em<>OLD.solicitado_em
 OR OLD.coletado_em IS NOT NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Pedido preservado; coleta só pode ser informada uma vez'; END IF;
END$$

CREATE TRIGGER tr_resultado_insert BEFORE INSERT ON exame_resultado FOR EACH ROW
BEGIN
 IF NOT EXISTS(SELECT 1 FROM exame_solicitacao WHERE id=NEW.solicitacao_id AND coletado_em IS NOT NULL AND coletado_em<=NEW.registrado_em) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Resultado exige solicitação com coleta anterior'; END IF;
 IF NOT EXISTS(SELECT 1 FROM veterinario WHERE id=NEW.autor_id AND ativo=1) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Autor deve ser veterinário ativo'; END IF;
END$$

CREATE TRIGGER tr_vacinacao_insert BEFORE INSERT ON vacinacao FOR EACH ROW
BEGIN
 IF NOT EXISTS(SELECT 1 FROM vacina_lote l JOIN vacina v ON v.id=l.vacina_id
 JOIN atendimento a ON a.id=NEW.atendimento_id JOIN animal n ON n.id=a.animal_id JOIN raca r ON r.id=n.raca_id
 WHERE l.id=NEW.lote_id AND l.validade>=NEW.aplicada_em AND v.especie_id=r.especie_id
 AND a.status<>'CANCELADO' AND DATE(a.inicio)<=NEW.aplicada_em) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Lote inválido, vencido, espécie incompatível ou data anterior ao atendimento'; END IF;
 IF NEW.aplicada_em>CURRENT_DATE THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Aplicação não pode ser futura'; END IF;
 IF NOT EXISTS(SELECT 1 FROM veterinario WHERE id=NEW.profissional_id AND ativo=1) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Aplicador deve ser veterinário ativo'; END IF;
END$$

CREATE TRIGGER tr_exame_solicitacao_insert BEFORE INSERT ON exame_solicitacao FOR EACH ROW
BEGIN
 IF NOT EXISTS(SELECT 1 FROM atendimento WHERE id=NEW.atendimento_id AND status<>'CANCELADO') THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Atendimento inexistente ou cancelado'; END IF;
END$$

CREATE TRIGGER tr_prescricao_insert BEFORE INSERT ON prescricao FOR EACH ROW
BEGIN
 IF NOT EXISTS(SELECT 1 FROM atendimento WHERE id=NEW.atendimento_id AND status<>'CANCELADO') THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Atendimento inexistente ou cancelado'; END IF;
END$$

CREATE TRIGGER tr_item_insert BEFORE INSERT ON atendimento_servico FOR EACH ROW
BEGIN
 IF EXISTS(SELECT 1 FROM cobranca WHERE atendimento_id=NEW.atendimento_id) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Itens congelados após emissão da cobrança'; END IF;
 IF NOT EXISTS(SELECT 1 FROM atendimento WHERE id=NEW.atendimento_id AND status<>'CANCELADO') THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Atendimento cancelado ou inexistente'; END IF;
END$$

CREATE TRIGGER tr_item_update BEFORE UPDATE ON atendimento_servico FOR EACH ROW
BEGIN
 IF EXISTS(SELECT 1 FROM cobranca WHERE atendimento_id=NEW.atendimento_id) OR EXISTS(SELECT 1 FROM cobranca WHERE atendimento_id=OLD.atendimento_id) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Itens congelados após emissão da cobrança'; END IF;
 IF NOT EXISTS(SELECT 1 FROM atendimento WHERE id=NEW.atendimento_id AND status<>'CANCELADO') THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Atendimento cancelado ou inexistente'; END IF;
END$$

CREATE TRIGGER tr_item_delete BEFORE DELETE ON atendimento_servico FOR EACH ROW
BEGIN
 IF EXISTS(SELECT 1 FROM cobranca WHERE atendimento_id=OLD.atendimento_id) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Itens congelados após emissão da cobrança'; END IF;
 IF NOT EXISTS(SELECT 1 FROM atendimento WHERE id=OLD.atendimento_id AND status<>'CANCELADO') THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Atendimento cancelado ou inexistente'; END IF;
END$$

CREATE TRIGGER tr_cobranca_insert BEFORE INSERT ON cobranca FOR EACH ROW
BEGIN
 IF NOT EXISTS(SELECT 1 FROM atendimento_servico WHERE atendimento_id=NEW.atendimento_id) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Cobrança exige ao menos um serviço'; END IF;
 IF NOT EXISTS(SELECT 1 FROM atendimento WHERE id=NEW.atendimento_id AND status<>'CANCELADO') THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Não é possível cobrar atendimento cancelado'; END IF;
END$$

CREATE TRIGGER tr_cobranca_update BEFORE UPDATE ON cobranca FOR EACH ROW
BEGIN
 IF NEW.atendimento_id<>OLD.atendimento_id OR NEW.desconto_pct<>OLD.desconto_pct OR NEW.emitida_em<>OLD.emitida_em OR NEW.vencimento<>OLD.vencimento OR OLD.cancelada=1 THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Cobrança emitida é imutável, exceto cancelamento'; END IF;
 IF NEW.cancelada=1 AND EXISTS(SELECT 1 FROM pagamento p LEFT JOIN estorno e ON e.pagamento_id=p.id WHERE p.cobranca_id=OLD.id AND e.id IS NULL) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Estorne os pagamentos antes de cancelar'; END IF;
END$$

CREATE TRIGGER tr_pagamento_insert BEFORE INSERT ON pagamento FOR EACH ROW
BEGIN
 IF NOT EXISTS(SELECT 1 FROM vw_financeiro WHERE id=NEW.cobranca_id AND cancelada=0 AND saldo>=NEW.valor) THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Cobrança inexistente, cancelada ou pagamento acima do saldo'; END IF;
END$$

CREATE TRIGGER tr_registro_clinico_update BEFORE UPDATE ON registro_clinico FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Histórico imutável; acrescente novo registro ou estorno';
END$$

CREATE TRIGGER tr_registro_clinico_delete BEFORE DELETE ON registro_clinico FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Histórico imutável; acrescente novo registro ou estorno';
END$$

CREATE TRIGGER tr_exame_resultado_update BEFORE UPDATE ON exame_resultado FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Histórico imutável; acrescente novo registro ou estorno';
END$$

CREATE TRIGGER tr_exame_resultado_delete BEFORE DELETE ON exame_resultado FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Histórico imutável; acrescente novo registro ou estorno';
END$$

CREATE TRIGGER tr_vacinacao_update BEFORE UPDATE ON vacinacao FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Histórico imutável; acrescente novo registro ou estorno';
END$$

CREATE TRIGGER tr_vacinacao_delete BEFORE DELETE ON vacinacao FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Histórico imutável; acrescente novo registro ou estorno';
END$$

CREATE TRIGGER tr_prescricao_update BEFORE UPDATE ON prescricao FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Histórico imutável; acrescente novo registro ou estorno';
END$$

CREATE TRIGGER tr_prescricao_delete BEFORE DELETE ON prescricao FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Histórico imutável; acrescente novo registro ou estorno';
END$$

CREATE TRIGGER tr_pagamento_update BEFORE UPDATE ON pagamento FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Histórico imutável; acrescente novo registro ou estorno';
END$$

CREATE TRIGGER tr_pagamento_delete BEFORE DELETE ON pagamento FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Histórico imutável; acrescente novo registro ou estorno';
END$$

CREATE TRIGGER tr_estorno_update BEFORE UPDATE ON estorno FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Histórico imutável; acrescente novo registro ou estorno';
END$$

CREATE TRIGGER tr_estorno_delete BEFORE DELETE ON estorno FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Histórico imutável; acrescente novo registro ou estorno';
END$$

CREATE TRIGGER tr_cancelamento_update BEFORE UPDATE ON cancelamento FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Histórico imutável; acrescente novo registro ou estorno';
END$$

CREATE TRIGGER tr_cancelamento_delete BEFORE DELETE ON cancelamento FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Histórico imutável; acrescente novo registro ou estorno';
END$$

CREATE TRIGGER tr_atendimento_delete BEFORE DELETE ON atendimento FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Exclusão física não permitida; preserve o histórico';
END$$

CREATE TRIGGER tr_exame_solicitacao_delete BEFORE DELETE ON exame_solicitacao FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Exclusão física não permitida; preserve o histórico';
END$$

CREATE TRIGGER tr_cobranca_delete BEFORE DELETE ON cobranca FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Exclusão física não permitida; preserve o histórico';
END$$

DELIMITER ;

-- FIM: 05_programacao.sql

-- INÍCIO: 03_carga.sql
-- VETDATA | 03_carga.sql | Somente dados fictícios.
USE vetdata;
SET @hoje=CURRENT_DATE;
START TRANSACTION;

INSERT INTO responsavel (id,nome,documento) VALUES
(1,'Ana Lima','99000000001'),
(2,'Bruno Alves','99000000002'),
(3,'Carla Costa','99000000003'),
(4,'Diego Rocha','99000000004'),
(5,'Elisa Martins','99000000005'),
(6,'Fábio Santos','99000000006'),
(7,'Gabriela Melo','99000000007'),
(8,'Henrique Lopes','99000000008'),
(9,'Isabela Reis','99000000009'),
(10,'João Duarte','99000000010'),
(11,'Luana Castro','99000000011'),
(12,'Marcos Oliveira','99000000012');

INSERT INTO contato_responsavel (responsavel_id,tipo,valor) VALUES
(1,'EMAIL','cliente1@example.invalid'),
(1,'TELEFONE','(11) 0000-0001'),
(2,'EMAIL','cliente2@example.invalid'),
(2,'TELEFONE','(11) 0000-0002'),
(3,'EMAIL','cliente3@example.invalid'),
(3,'TELEFONE','(11) 0000-0003'),
(4,'EMAIL','cliente4@example.invalid'),
(4,'TELEFONE','(11) 0000-0004'),
(5,'EMAIL','cliente5@example.invalid'),
(5,'TELEFONE','(11) 0000-0005'),
(6,'EMAIL','cliente6@example.invalid'),
(6,'TELEFONE','(11) 0000-0006'),
(7,'EMAIL','cliente7@example.invalid'),
(7,'TELEFONE','(11) 0000-0007'),
(8,'EMAIL','cliente8@example.invalid'),
(8,'TELEFONE','(11) 0000-0008'),
(9,'EMAIL','cliente9@example.invalid'),
(9,'TELEFONE','(11) 0000-0009'),
(10,'EMAIL','cliente10@example.invalid'),
(10,'TELEFONE','(11) 0000-0010'),
(11,'EMAIL','cliente11@example.invalid'),
(11,'TELEFONE','(11) 0000-0011'),
(12,'EMAIL','cliente12@example.invalid'),
(12,'TELEFONE','(11) 0000-0012');

INSERT INTO especie (id,nome) VALUES
(1,'Canina'),
(2,'Felina'),
(3,'Coelho'),
(4,'Ave');

INSERT INTO raca (id,especie_id,nome) VALUES
(1,1,'Sem raça definida'),
(2,1,'Golden Retriever'),
(3,1,'Shih-tzu'),
(4,2,'Sem raça definida'),
(5,2,'Siamês'),
(6,2,'Persa'),
(7,3,'Mini Lop'),
(8,4,'Calopsita');

INSERT INTO animal (id,responsavel_id,raca_id,nome,sexo,nascimento,microchip) VALUES
(1,1,1,'Luna','F',DATE_ADD(@hoje,INTERVAL -365 DAY),'DEMO-000001'),
(2,2,2,'Thor','M',DATE_ADD(@hoje,INTERVAL -730 DAY),'DEMO-000002'),
(3,3,3,'Mel','F',DATE_ADD(@hoje,INTERVAL -1095 DAY),'DEMO-000003'),
(4,4,4,'Simba','M',DATE_ADD(@hoje,INTERVAL -1460 DAY),'DEMO-000004'),
(5,5,5,'Nina','F',DATE_ADD(@hoje,INTERVAL -1825 DAY),'DEMO-000005'),
(6,6,6,'Theo','M',DATE_ADD(@hoje,INTERVAL -2190 DAY),'DEMO-000006'),
(7,7,7,'Amora','F',DATE_ADD(@hoje,INTERVAL -2555 DAY),'DEMO-000007'),
(8,8,8,'Pipoca','M',DATE_ADD(@hoje,INTERVAL -365 DAY),'DEMO-000008'),
(9,9,1,'Bento','F',DATE_ADD(@hoje,INTERVAL -730 DAY),'DEMO-000009'),
(10,10,2,'Lola','M',DATE_ADD(@hoje,INTERVAL -1095 DAY),'DEMO-000010'),
(11,11,4,'Milo','F',DATE_ADD(@hoje,INTERVAL -1460 DAY),'DEMO-000011'),
(12,12,5,'Jade','M',DATE_ADD(@hoje,INTERVAL -1825 DAY),'DEMO-000012'),
(13,1,1,'Paçoca','F',DATE_ADD(@hoje,INTERVAL -2190 DAY),'DEMO-000013'),
(14,2,3,'Belinha','M',DATE_ADD(@hoje,INTERVAL -2555 DAY),'DEMO-000014'),
(15,3,4,'Tom','F',DATE_ADD(@hoje,INTERVAL -365 DAY),'DEMO-000015'),
(16,4,6,'Kiara','M',DATE_ADD(@hoje,INTERVAL -730 DAY),'DEMO-000016'),
(17,5,1,'Cacau','F',DATE_ADD(@hoje,INTERVAL -1095 DAY),'DEMO-000017'),
(18,6,8,'Chico','M',DATE_ADD(@hoje,INTERVAL -1460 DAY),'DEMO-000018'),
(19,7,4,'Lua','F',DATE_ADD(@hoje,INTERVAL -1825 DAY),'DEMO-000019'),
(20,8,2,'Fred','M',DATE_ADD(@hoje,INTERVAL -2190 DAY),'DEMO-000020');

INSERT INTO especialidade (id,nome) VALUES
(1,'Clínica geral'),
(2,'Dermatologia'),
(3,'Diagnóstico por imagem'),
(4,'Animais silvestres'),
(5,'Cirurgia');

INSERT INTO veterinario (id,nome,crmv) VALUES
(1,'Marina Azevedo','DEMO-SP-001'),
(2,'Rafael Nunes','DEMO-SP-002'),
(3,'Beatriz Campos','DEMO-SP-003'),
(4,'Lucas Teixeira','DEMO-SP-004');

INSERT INTO veterinario_especialidade (veterinario_id,especialidade_id) VALUES
(1,1),
(1,2),
(2,1),
(2,5),
(3,1),
(3,3),
(4,1),
(4,4);

INSERT INTO disponibilidade (veterinario_id,dia_semana,inicio,fim) VALUES
(1,0,'08:00','18:00'),
(1,1,'08:00','18:00'),
(1,2,'08:00','18:00'),
(1,3,'08:00','18:00'),
(1,4,'08:00','18:00'),
(1,5,'08:00','18:00'),
(1,6,'08:00','18:00'),
(2,0,'08:00','18:00'),
(2,1,'08:00','18:00'),
(2,2,'08:00','18:00'),
(2,3,'08:00','18:00'),
(2,4,'08:00','18:00'),
(2,5,'08:00','18:00'),
(2,6,'08:00','18:00'),
(3,0,'08:00','18:00'),
(3,1,'08:00','18:00'),
(3,2,'08:00','18:00'),
(3,3,'08:00','18:00'),
(3,4,'08:00','18:00'),
(3,5,'08:00','18:00'),
(3,6,'08:00','18:00'),
(4,0,'08:00','18:00'),
(4,1,'08:00','18:00'),
(4,2,'08:00','18:00'),
(4,3,'08:00','18:00'),
(4,4,'08:00','18:00'),
(4,5,'08:00','18:00'),
(4,6,'08:00','18:00');

INSERT INTO categoria_servico (id,nome) VALUES
(1,'Consultas'),
(2,'Exames'),
(3,'Vacinação'),
(4,'Procedimentos');

INSERT INTO servico (id,categoria_id,nome,preco_base) VALUES
(1,1,'Consulta clínica',150),
(2,1,'Retorno clínico',80),
(3,2,'Hemograma',90),
(4,2,'Ultrassonografia',220),
(5,3,'Aplicação de vacina',100),
(6,4,'Curativo',60),
(7,4,'Avaliação pré-operatória',180),
(8,2,'Exame de urina',70);

INSERT INTO tipo_exame (id,nome) VALUES
(1,'Hemograma'),
(2,'Ultrassonografia'),
(3,'Urina tipo I'),
(4,'Perfil bioquímico'),
(5,'Citologia');

INSERT INTO vacina (id,nome,especie_id) VALUES
(1,'Produto canino demonstrativo',1),
(2,'Produto felino demonstrativo',2),
(3,'Produto para coelhos demonstrativo',3),
(4,'Produto para aves demonstrativo',4);

INSERT INTO vacina_lote (id,vacina_id,codigo,validade) VALUES
(1,1,'DEMO-2026-1',DATE_ADD(@hoje,INTERVAL 360 DAY)),
(2,2,'DEMO-2026-2',DATE_ADD(@hoje,INTERVAL 360 DAY)),
(3,3,'DEMO-2026-3',DATE_ADD(@hoje,INTERVAL 360 DAY)),
(4,4,'DEMO-2026-4',DATE_ADD(@hoje,INTERVAL 360 DAY)),
(5,1,'DEMO-2026-5',DATE_ADD(@hoje,INTERVAL 180 DAY)),
(6,2,'LOTE-VENCIDO-TESTE',DATE_ADD(@hoje,INTERVAL -90 DAY));

INSERT INTO medicamento (id,nome) VALUES
(1,'Medicamento demonstrativo A'),
(2,'Medicamento demonstrativo B'),
(3,'Medicamento demonstrativo C'),
(4,'Medicamento demonstrativo D'),
(5,'Medicamento demonstrativo E');

INSERT INTO forma_pagamento (id,nome) VALUES
(1,'Pix'),
(2,'Dinheiro'),
(3,'Cartão de débito'),
(4,'Cartão de crédito');

INSERT INTO atendimento (id,animal_id,veterinario_id,inicio,fim,motivo) VALUES
(1,1,1,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -60 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -60 DAY),'09:40:00'),'Consulta de rotina'),
(2,2,2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -60 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -60 DAY),'09:40:00'),'Consulta de rotina'),
(3,3,3,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -60 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -60 DAY),'09:40:00'),'Consulta de rotina'),
(4,4,4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -60 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -60 DAY),'09:40:00'),'Consulta de rotina'),
(5,5,1,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -59 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -59 DAY),'09:40:00'),'Consulta de rotina'),
(6,6,2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -59 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -59 DAY),'09:40:00'),'Consulta de rotina'),
(7,7,3,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -59 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -59 DAY),'09:40:00'),'Consulta de rotina'),
(8,8,4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -59 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -59 DAY),'09:40:00'),'Consulta de rotina'),
(9,9,1,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -58 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -58 DAY),'09:40:00'),'Consulta de rotina'),
(10,10,2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -58 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -58 DAY),'09:40:00'),'Consulta de rotina'),
(11,11,3,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -58 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -58 DAY),'09:40:00'),'Consulta de rotina'),
(12,12,4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -58 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -58 DAY),'09:40:00'),'Consulta de rotina'),
(13,13,1,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -57 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -57 DAY),'09:40:00'),'Consulta de rotina'),
(14,14,2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -57 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -57 DAY),'09:40:00'),'Consulta de rotina'),
(15,15,3,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -57 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -57 DAY),'09:40:00'),'Consulta de rotina'),
(16,16,4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -57 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -57 DAY),'09:40:00'),'Consulta de rotina'),
(17,17,1,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -56 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -56 DAY),'09:40:00'),'Consulta de rotina'),
(18,18,2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -56 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -56 DAY),'09:40:00'),'Consulta de rotina'),
(19,19,3,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -56 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -56 DAY),'09:40:00'),'Consulta de rotina'),
(20,20,4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -56 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -56 DAY),'09:40:00'),'Consulta de rotina'),
(21,1,1,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:40:00'),'Retorno e acompanhamento'),
(22,2,2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:40:00'),'Retorno e acompanhamento'),
(23,3,3,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:40:00'),'Retorno e acompanhamento'),
(24,4,4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:40:00'),'Retorno e acompanhamento'),
(25,5,1,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:40:00'),'Retorno e acompanhamento'),
(26,6,2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:40:00'),'Retorno e acompanhamento'),
(27,7,3,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:40:00'),'Retorno e acompanhamento'),
(28,8,4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:40:00'),'Retorno e acompanhamento'),
(29,9,1,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'09:40:00'),'Retorno e acompanhamento'),
(30,10,2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'09:40:00'),'Retorno e acompanhamento'),
(31,11,3,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'09:40:00'),'Retorno e acompanhamento'),
(32,12,4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'09:40:00'),'Retorno e acompanhamento'),
(33,13,1,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -22 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -22 DAY),'09:40:00'),'Retorno e acompanhamento'),
(34,14,2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -22 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -22 DAY),'09:40:00'),'Retorno e acompanhamento'),
(35,15,3,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -22 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -22 DAY),'09:40:00'),'Retorno e acompanhamento'),
(36,16,4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -22 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -22 DAY),'09:40:00'),'Retorno e acompanhamento'),
(37,17,1,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -21 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -21 DAY),'09:40:00'),'Retorno e acompanhamento'),
(38,18,2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -21 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -21 DAY),'09:40:00'),'Retorno e acompanhamento'),
(39,19,3,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -21 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -21 DAY),'09:40:00'),'Retorno e acompanhamento'),
(40,20,4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -21 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -21 DAY),'09:40:00'),'Retorno e acompanhamento'),
(41,1,1,TIMESTAMP(DATE_ADD(@hoje,INTERVAL 0 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL 0 DAY),'09:40:00'),'Consulta de rotina'),
(42,2,2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL 0 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL 0 DAY),'09:40:00'),'Avaliação dermatológica'),
(43,3,3,TIMESTAMP(DATE_ADD(@hoje,INTERVAL 0 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL 0 DAY),'09:40:00'),'Vacinação'),
(44,4,4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL 0 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL 0 DAY),'09:40:00'),'Retorno clínico'),
(45,5,1,TIMESTAMP(DATE_ADD(@hoje,INTERVAL 0 DAY),'10:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL 0 DAY),'10:40:00'),'Consulta de rotina'),
(46,6,2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL 0 DAY),'10:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL 0 DAY),'10:40:00'),'Avaliação dermatológica'),
(47,7,3,TIMESTAMP(DATE_ADD(@hoje,INTERVAL 0 DAY),'10:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL 0 DAY),'10:40:00'),'Vacinação'),
(48,8,4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL 0 DAY),'10:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL 0 DAY),'10:40:00'),'Retorno clínico'),
(49,9,1,TIMESTAMP(DATE_ADD(@hoje,INTERVAL 1 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL 1 DAY),'09:40:00'),'Consulta de rotina'),
(50,10,2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL 1 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL 1 DAY),'09:40:00'),'Avaliação dermatológica'),
(51,11,3,TIMESTAMP(DATE_ADD(@hoje,INTERVAL 1 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL 1 DAY),'09:40:00'),'Vacinação'),
(52,12,4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL 1 DAY),'09:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL 1 DAY),'09:40:00'),'Retorno clínico'),
(53,13,1,TIMESTAMP(DATE_ADD(@hoje,INTERVAL 2 DAY),'10:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL 2 DAY),'10:40:00'),'Consulta de rotina'),
(54,14,2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL 2 DAY),'10:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL 2 DAY),'10:40:00'),'Avaliação dermatológica'),
(55,15,3,TIMESTAMP(DATE_ADD(@hoje,INTERVAL 2 DAY),'10:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL 2 DAY),'10:40:00'),'Vacinação'),
(56,16,4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL 2 DAY),'10:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL 2 DAY),'10:40:00'),'Retorno clínico'),
(57,20,4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL 3 DAY),'15:00:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL 3 DAY),'15:40:00'),'Agendamento cancelado de demonstração');

INSERT INTO registro_clinico (atendimento_id,autor_id,anamnese,diagnostico,observacoes,peso_kg,criado_em) VALUES
(1,1,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',2.0,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -60 DAY),'09:20:00')),
(2,2,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',4.2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -60 DAY),'09:20:00')),
(3,3,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',6.4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -60 DAY),'09:20:00')),
(4,4,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',8.6,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -60 DAY),'09:20:00')),
(5,1,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',10.8,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -59 DAY),'09:20:00')),
(6,2,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',13.0,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -59 DAY),'09:20:00')),
(7,3,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',15.2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -59 DAY),'09:20:00')),
(8,4,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',17.4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -59 DAY),'09:20:00')),
(9,1,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',19.6,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -58 DAY),'09:20:00')),
(10,2,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',21.8,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -58 DAY),'09:20:00')),
(11,3,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',24.0,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -58 DAY),'09:20:00')),
(12,4,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',26.2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -58 DAY),'09:20:00')),
(13,1,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',2.0,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -57 DAY),'09:20:00')),
(14,2,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',4.2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -57 DAY),'09:20:00')),
(15,3,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',6.4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -57 DAY),'09:20:00')),
(16,4,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',8.6,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -57 DAY),'09:20:00')),
(17,1,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',10.8,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -56 DAY),'09:20:00')),
(18,2,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',13.0,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -56 DAY),'09:20:00')),
(19,3,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',15.2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -56 DAY),'09:20:00')),
(20,4,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',17.4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -56 DAY),'09:20:00')),
(21,1,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',19.6,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:20:00')),
(22,2,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',21.8,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:20:00')),
(23,3,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',24.0,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:20:00')),
(24,4,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',26.2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:20:00')),
(25,1,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',2.0,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:20:00')),
(26,2,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',4.2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:20:00')),
(27,3,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',6.4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:20:00')),
(28,4,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',8.6,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:20:00')),
(29,1,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',10.8,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'09:20:00')),
(30,2,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',13.0,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'09:20:00')),
(31,3,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',15.2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'09:20:00')),
(32,4,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',17.4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'09:20:00')),
(33,1,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',19.6,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -22 DAY),'09:20:00')),
(34,2,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',21.8,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -22 DAY),'09:20:00')),
(35,3,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',24.0,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -22 DAY),'09:20:00')),
(36,4,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',26.2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -22 DAY),'09:20:00')),
(37,1,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',2.0,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -21 DAY),'09:20:00')),
(38,2,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',4.2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -21 DAY),'09:20:00')),
(39,3,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',6.4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -21 DAY),'09:20:00')),
(40,4,'Registro fictício: avaliação de rotina e histórico informado pelo responsável.','Avaliação demonstrativa, sem validade clínica.','Dados exclusivamente acadêmicos.',8.6,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -21 DAY),'09:20:00'));

INSERT INTO registro_clinico (atendimento_id,autor_id,anamnese,diagnostico,observacoes,peso_kg,retifica_id) VALUES
(1,1,'Retificação demonstrativa: ajuste do peso aferido.','Mantida a avaliação demonstrativa.','Original preservado no histórico.',2.1,1);

INSERT INTO atendimento_servico (atendimento_id,servico_id,quantidade,valor_unitario) VALUES
(1,1,1,150),
(2,1,1,150),
(3,1,1,150),
(4,1,1,150),
(5,1,1,150),
(6,1,1,150),
(7,1,1,150),
(8,1,1,150),
(9,1,1,150),
(10,1,1,150),
(11,1,1,150),
(12,1,1,150),
(13,1,1,150),
(14,1,1,150),
(15,1,1,150),
(16,1,1,150),
(17,1,1,150),
(18,1,1,150),
(19,1,1,150),
(20,1,1,150),
(21,2,1,80),
(22,2,1,80),
(23,2,1,80),
(24,2,1,80),
(25,2,1,80),
(26,2,1,80),
(27,2,1,80),
(28,2,1,80),
(29,2,1,80),
(30,2,1,80),
(31,2,1,80),
(32,2,1,80),
(33,2,1,80),
(34,2,1,80),
(35,2,1,80),
(36,2,1,80),
(37,2,1,80),
(38,2,1,80),
(39,2,1,80),
(40,2,1,80),
(1,3,1,90),
(2,4,1,220),
(3,5,1,100),
(4,6,1,60),
(5,7,1,180),
(6,8,1,70),
(7,3,1,90),
(8,4,1,220),
(9,5,1,100),
(10,6,1,60),
(11,7,1,180),
(12,8,1,70),
(13,3,1,90),
(14,4,1,220),
(15,5,1,100),
(16,6,1,60),
(17,7,1,180),
(18,8,1,70),
(19,3,1,90),
(20,4,1,220),
(21,5,1,100),
(22,6,1,60),
(23,7,1,180),
(24,8,1,70),
(25,3,1,90),
(26,4,1,220),
(27,5,1,100),
(28,6,1,60),
(29,7,1,180),
(30,8,1,70),
(41,1,1,150),
(57,1,1,150);

INSERT INTO exame_solicitacao (id,atendimento_id,tipo_exame_id,solicitado_em,coletado_em) VALUES
(1,21,1,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:10:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:20:00')),
(2,22,2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:10:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:20:00')),
(3,23,3,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:10:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:20:00')),
(4,24,4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:10:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -25 DAY),'09:20:00')),
(5,25,5,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:10:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:20:00')),
(6,26,1,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:10:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:20:00')),
(7,27,2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:10:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:20:00')),
(8,28,3,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:10:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'09:20:00')),
(9,29,4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'09:10:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'09:20:00')),
(10,30,5,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'09:10:00'),TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'09:20:00')),
(11,31,1,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'09:10:00'),NULL),
(12,32,2,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'09:10:00'),NULL),
(13,33,3,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -22 DAY),'09:10:00'),NULL),
(14,34,4,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -22 DAY),'09:10:00'),NULL),
(15,35,5,TIMESTAMP(DATE_ADD(@hoje,INTERVAL -22 DAY),'09:10:00'),NULL);

INSERT INTO exame_resultado (solicitacao_id,autor_id,resultado,registrado_em) VALUES
(1,1,'Resultado de demonstração: laudo fictício para validação do sistema.',TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'14:00:00')),
(2,2,'Resultado de demonstração: laudo fictício para validação do sistema.',TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'14:00:00')),
(3,3,'Resultado de demonstração: laudo fictício para validação do sistema.',TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'14:00:00')),
(4,4,'Resultado de demonstração: laudo fictício para validação do sistema.',TIMESTAMP(DATE_ADD(@hoje,INTERVAL -24 DAY),'14:00:00')),
(5,1,'Resultado de demonstração: laudo fictício para validação do sistema.',TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'14:00:00')),
(6,2,'Resultado de demonstração: laudo fictício para validação do sistema.',TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'14:00:00')),
(7,3,'Resultado de demonstração: laudo fictício para validação do sistema.',TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'14:00:00')),
(8,4,'Resultado de demonstração: laudo fictício para validação do sistema.',TIMESTAMP(DATE_ADD(@hoje,INTERVAL -23 DAY),'14:00:00'));

INSERT INTO exame_resultado (solicitacao_id,autor_id,resultado) VALUES
(1,1,'Retificação de demonstração. O laudo anterior permanece disponível.');

INSERT INTO vacinacao (atendimento_id,lote_id,profissional_id,aplicada_em,proxima_dose) VALUES
(1,1,1,DATE_ADD(@hoje,INTERVAL -60 DAY),DATE_ADD(@hoje,INTERVAL -20 DAY)),
(2,1,2,DATE_ADD(@hoje,INTERVAL -60 DAY),DATE_ADD(@hoje,INTERVAL -17 DAY)),
(3,1,3,DATE_ADD(@hoje,INTERVAL -60 DAY),DATE_ADD(@hoje,INTERVAL -14 DAY)),
(4,2,4,DATE_ADD(@hoje,INTERVAL -60 DAY),DATE_ADD(@hoje,INTERVAL -11 DAY)),
(5,2,1,DATE_ADD(@hoje,INTERVAL -59 DAY),DATE_ADD(@hoje,INTERVAL -8 DAY)),
(6,2,2,DATE_ADD(@hoje,INTERVAL -59 DAY),DATE_ADD(@hoje,INTERVAL -5 DAY)),
(7,3,3,DATE_ADD(@hoje,INTERVAL -59 DAY),DATE_ADD(@hoje,INTERVAL -2 DAY)),
(8,4,4,DATE_ADD(@hoje,INTERVAL -59 DAY),DATE_ADD(@hoje,INTERVAL 1 DAY)),
(9,1,1,DATE_ADD(@hoje,INTERVAL -58 DAY),DATE_ADD(@hoje,INTERVAL 4 DAY)),
(10,1,2,DATE_ADD(@hoje,INTERVAL -58 DAY),DATE_ADD(@hoje,INTERVAL 7 DAY)),
(11,2,3,DATE_ADD(@hoje,INTERVAL -58 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(12,2,4,DATE_ADD(@hoje,INTERVAL -58 DAY),DATE_ADD(@hoje,INTERVAL 13 DAY)),
(21,1,1,DATE_ADD(@hoje,INTERVAL -25 DAY),DATE_ADD(@hoje,INTERVAL 180 DAY)),
(22,1,2,DATE_ADD(@hoje,INTERVAL -25 DAY),DATE_ADD(@hoje,INTERVAL 181 DAY)),
(23,1,3,DATE_ADD(@hoje,INTERVAL -25 DAY),DATE_ADD(@hoje,INTERVAL 182 DAY)),
(24,2,4,DATE_ADD(@hoje,INTERVAL -25 DAY),DATE_ADD(@hoje,INTERVAL 183 DAY));

INSERT INTO prescricao (atendimento_id,medicamento_id,posologia,duracao_dias,orientacoes) VALUES
(1,1,'Posologia fictícia para teste; não utilizar em animais.',5,'Exemplo acadêmico sem validade clínica.'),
(2,2,'Posologia fictícia para teste; não utilizar em animais.',6,'Exemplo acadêmico sem validade clínica.'),
(3,3,'Posologia fictícia para teste; não utilizar em animais.',7,'Exemplo acadêmico sem validade clínica.'),
(4,4,'Posologia fictícia para teste; não utilizar em animais.',5,'Exemplo acadêmico sem validade clínica.'),
(5,5,'Posologia fictícia para teste; não utilizar em animais.',6,'Exemplo acadêmico sem validade clínica.'),
(6,1,'Posologia fictícia para teste; não utilizar em animais.',7,'Exemplo acadêmico sem validade clínica.'),
(7,2,'Posologia fictícia para teste; não utilizar em animais.',5,'Exemplo acadêmico sem validade clínica.'),
(8,3,'Posologia fictícia para teste; não utilizar em animais.',6,'Exemplo acadêmico sem validade clínica.'),
(9,4,'Posologia fictícia para teste; não utilizar em animais.',7,'Exemplo acadêmico sem validade clínica.'),
(10,5,'Posologia fictícia para teste; não utilizar em animais.',5,'Exemplo acadêmico sem validade clínica.'),
(11,1,'Posologia fictícia para teste; não utilizar em animais.',6,'Exemplo acadêmico sem validade clínica.'),
(12,2,'Posologia fictícia para teste; não utilizar em animais.',7,'Exemplo acadêmico sem validade clínica.'),
(13,3,'Posologia fictícia para teste; não utilizar em animais.',5,'Exemplo acadêmico sem validade clínica.'),
(14,4,'Posologia fictícia para teste; não utilizar em animais.',6,'Exemplo acadêmico sem validade clínica.'),
(15,5,'Posologia fictícia para teste; não utilizar em animais.',7,'Exemplo acadêmico sem validade clínica.');

INSERT INTO cobranca (id,atendimento_id,desconto_pct,emitida_em,vencimento) VALUES
(1,1,10,DATE_ADD(@hoje,INTERVAL -60 DAY),DATE_ADD(@hoje,INTERVAL -5 DAY)),
(2,2,0,DATE_ADD(@hoje,INTERVAL -60 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(3,3,0,DATE_ADD(@hoje,INTERVAL -60 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(4,4,0,DATE_ADD(@hoje,INTERVAL -60 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(5,5,0,DATE_ADD(@hoje,INTERVAL -59 DAY),DATE_ADD(@hoje,INTERVAL -5 DAY)),
(6,6,10,DATE_ADD(@hoje,INTERVAL -59 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(7,7,0,DATE_ADD(@hoje,INTERVAL -59 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(8,8,0,DATE_ADD(@hoje,INTERVAL -59 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(9,9,0,DATE_ADD(@hoje,INTERVAL -58 DAY),DATE_ADD(@hoje,INTERVAL -5 DAY)),
(10,10,0,DATE_ADD(@hoje,INTERVAL -58 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(11,11,10,DATE_ADD(@hoje,INTERVAL -58 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(12,12,0,DATE_ADD(@hoje,INTERVAL -58 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(13,13,0,DATE_ADD(@hoje,INTERVAL -57 DAY),DATE_ADD(@hoje,INTERVAL -5 DAY)),
(14,14,0,DATE_ADD(@hoje,INTERVAL -57 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(15,15,0,DATE_ADD(@hoje,INTERVAL -57 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(16,16,10,DATE_ADD(@hoje,INTERVAL -57 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(17,17,0,DATE_ADD(@hoje,INTERVAL -56 DAY),DATE_ADD(@hoje,INTERVAL -5 DAY)),
(18,18,0,DATE_ADD(@hoje,INTERVAL -56 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(19,19,0,DATE_ADD(@hoje,INTERVAL -56 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(20,20,0,DATE_ADD(@hoje,INTERVAL -56 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(21,21,10,DATE_ADD(@hoje,INTERVAL -25 DAY),DATE_ADD(@hoje,INTERVAL -5 DAY)),
(22,22,0,DATE_ADD(@hoje,INTERVAL -25 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(23,23,0,DATE_ADD(@hoje,INTERVAL -25 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(24,24,0,DATE_ADD(@hoje,INTERVAL -25 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(25,25,0,DATE_ADD(@hoje,INTERVAL -24 DAY),DATE_ADD(@hoje,INTERVAL -5 DAY)),
(26,26,10,DATE_ADD(@hoje,INTERVAL -24 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(27,27,0,DATE_ADD(@hoje,INTERVAL -24 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(28,28,0,DATE_ADD(@hoje,INTERVAL -24 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(29,29,0,DATE_ADD(@hoje,INTERVAL -23 DAY),DATE_ADD(@hoje,INTERVAL -5 DAY)),
(30,30,0,DATE_ADD(@hoje,INTERVAL -23 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(31,31,10,DATE_ADD(@hoje,INTERVAL -23 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(32,32,0,DATE_ADD(@hoje,INTERVAL -23 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(33,33,0,DATE_ADD(@hoje,INTERVAL -22 DAY),DATE_ADD(@hoje,INTERVAL -5 DAY)),
(34,34,0,DATE_ADD(@hoje,INTERVAL -22 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(35,35,0,DATE_ADD(@hoje,INTERVAL -22 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(36,36,10,DATE_ADD(@hoje,INTERVAL -22 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(37,37,0,DATE_ADD(@hoje,INTERVAL -21 DAY),DATE_ADD(@hoje,INTERVAL -5 DAY)),
(38,38,0,DATE_ADD(@hoje,INTERVAL -21 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(39,39,0,DATE_ADD(@hoje,INTERVAL -21 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(40,40,0,DATE_ADD(@hoje,INTERVAL -21 DAY),DATE_ADD(@hoje,INTERVAL 10 DAY)),
(41,41,0,DATE_ADD(@hoje,INTERVAL 0 DAY),DATE_ADD(@hoje,INTERVAL 7 DAY)),
(42,57,0,DATE_ADD(@hoje,INTERVAL 0 DAY),DATE_ADD(@hoje,INTERVAL 7 DAY));

INSERT INTO pagamento(cobranca_id,forma_id,valor) SELECT id,1,ROUND(total_liquido/2,2) FROM vw_financeiro WHERE id<=40 AND MOD(id,4)<>0;

INSERT INTO pagamento(cobranca_id,forma_id,valor) SELECT id,3,saldo FROM vw_financeiro WHERE id<=40 AND MOD(id,4) IN (1,2);

INSERT INTO pagamento (cobranca_id,forma_id,valor) VALUES
(42,1,60);

UPDATE atendimento SET status='CONCLUIDO' WHERE id<=40;

UPDATE atendimento SET status='CONFIRMADO' WHERE id BETWEEN 41 AND 44;

COMMIT;

CALL sp_cancelar(57,'Cancelamento solicitado pelo responsável (demonstração).');

-- FIM: 03_carga.sql

-- INÍCIO: 04_consultas.sql
-- VETDATA | 16 consultas identificadas; ajustar parâmetros conforme a demonstração.
USE vetdata;
SET @inicio=DATE_SUB(CURRENT_DATE,INTERVAL 90 DAY);
SET @fim=DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY);
SET @animal=1;

-- Q01 | Cadastro: pacientes, raça, espécie e responsável (JOIN de 4 tabelas).
SELECT n.id,n.nome,ra.nome AS raca,e.nome AS especie,r.nome AS responsavel
FROM animal n JOIN raca ra ON ra.id=n.raca_id JOIN especie e ON e.id=ra.especie_id
JOIN responsavel r ON r.id=n.responsavel_id WHERE n.ativo=1 ORDER BY n.nome;

-- Q02 | Agenda diária: filtro por intervalo permite uso do índice de data.
SELECT a.inicio,a.fim,n.nome AS animal,r.nome AS responsavel,v.nome AS veterinario,a.status
FROM atendimento a JOIN animal n ON n.id=a.animal_id JOIN responsavel r ON r.id=n.responsavel_id
JOIN veterinario v ON v.id=a.veterinario_id
WHERE a.inicio>=CURRENT_DATE AND a.inicio<DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY)
ORDER BY a.inicio,v.nome;

-- Q03 | GROUP BY/HAVING: responsáveis que possuem dois ou mais animais ativos.
SELECT r.id,r.nome,COUNT(n.id) AS animais
FROM responsavel r JOIN animal n ON n.responsavel_id=r.id AND n.ativo=1
GROUP BY r.id,r.nome HAVING COUNT(n.id)>=2 ORDER BY animais DESC,r.nome;

-- Q04 | Subconsulta correlacionada: animais sem próximo atendimento marcado.
SELECT n.id,n.nome FROM animal n WHERE n.ativo=1 AND NOT EXISTS(
 SELECT 1 FROM atendimento a WHERE a.animal_id=n.id AND a.inicio>=NOW()
 AND a.status IN ('AGENDADO','CONFIRMADO')) ORDER BY n.nome;

-- Q05 | Funções de texto, data e cálculo: resumo cadastral e idade.
SELECT n.id,UPPER(n.nome) AS nome,CONCAT(r.nome,' / paciente ',n.nome) AS etiqueta,
 TIMESTAMPDIFF(YEAR,n.nascimento,CURRENT_DATE) AS idade_anos,
 DATE_FORMAT(n.nascimento,'%d/%m/%Y') AS nascimento
FROM animal n JOIN responsavel r ON r.id=n.responsavel_id;

-- Q06 | Vacinação vencida ou prevista para os próximos 30 dias; só a última dose por produto.
SELECT * FROM vw_vacinacao_pendente ORDER BY proxima_dose,animal;

-- Q07 | Faturamento por período e categoria; competência da emissão, sem canceladas.
-- Arredondamento por item igual ao da cobrança; faturamento não é recebimento.
SELECT cat.nome AS categoria,
 SUM(ROUND(i.quantidade*i.valor_unitario*(1-c.desconto_pct/100),2)) AS faturamento
FROM cobranca c JOIN atendimento_servico i ON i.atendimento_id=c.atendimento_id
JOIN servico s ON s.id=i.servico_id JOIN categoria_servico cat ON cat.id=s.categoria_id
WHERE c.cancelada=0 AND c.emitida_em>=@inicio AND c.emitida_em<@fim
GROUP BY cat.id,cat.nome ORDER BY faturamento DESC;

-- Q08 | Pendência operacional: pedidos de exame ainda sem resultado.
SELECT x.id,n.nome AS animal,t.nome AS exame,x.solicitado_em,
 CASE WHEN x.coletado_em IS NULL THEN 'Aguardando coleta' ELSE 'Aguardando resultado' END AS etapa
FROM exame_solicitacao x JOIN atendimento a ON a.id=x.atendimento_id
JOIN animal n ON n.id=a.animal_id JOIN tipo_exame t ON t.id=x.tipo_exame_id
WHERE NOT EXISTS(SELECT 1 FROM exame_resultado z WHERE z.solicitacao_id=x.id)
ORDER BY x.solicitado_em;

-- Q09 | Cobranças abertas; quitação é calculada a partir de recebimentos e estornos.
SELECT f.id,n.nome AS animal,r.nome AS responsavel,f.total_liquido,f.recebido,f.saldo,f.vencimento,f.situacao
FROM vw_financeiro f JOIN atendimento a ON a.id=f.atendimento_id
JOIN animal n ON n.id=a.animal_id JOIN responsavel r ON r.id=n.responsavel_id
WHERE f.saldo>0 ORDER BY f.vencimento;

-- Q10 | Histórico longitudinal do animal: cada evolução, incluindo as retificações.
SELECT a.inicio AS atendimento_em,c.criado_em,c.id,c.retifica_id,v.nome AS autor,
 c.anamnese,c.diagnostico,c.peso_kg
FROM atendimento a JOIN registro_clinico c ON c.atendimento_id=a.id
JOIN veterinario v ON v.id=c.autor_id WHERE a.animal_id=@animal
ORDER BY a.inicio,c.criado_em,c.id;

-- Q11 | Auditoria: nenhum par de intervalos sobrepostos deve ser retornado.
SELECT a.id AS primeiro,b.id AS segundo,a.inicio,b.inicio
FROM atendimento a JOIN atendimento b ON a.id<b.id
 AND (a.veterinario_id=b.veterinario_id OR a.animal_id=b.animal_id)
 AND a.inicio<b.fim AND a.fim>b.inicio
WHERE a.status<>'CANCELADO' AND b.status<>'CANCELADO';

-- Q12 | Análise escolhida: participação por categoria e ranking no mês.
SELECT mes,categoria,faturamento,
 ROUND(100*faturamento/NULLIF(SUM(faturamento) OVER(PARTITION BY mes),0),2) AS participacao_pct,
 DENSE_RANK() OVER(PARTITION BY mes ORDER BY faturamento DESC) AS posicao
FROM vw_faturamento_categoria ORDER BY mes DESC,posicao,categoria;

-- Q13 | Movimentação de caixa: recebimentos na data e estornos na data efetiva.
SELECT DATE(evento_em) AS dia,SUM(valor) AS caixa_liquido FROM (
 SELECT pago_em AS evento_em,valor FROM pagamento
 UNION ALL SELECT e.estornado_em,-p.valor FROM estorno e JOIN pagamento p ON p.id=e.pagamento_id
) movimentos WHERE evento_em>=@inicio AND evento_em<@fim GROUP BY DATE(evento_em) ORDER BY dia;

-- Q14 | Atendimentos por profissional e situação.
SELECT v.nome,a.status,COUNT(*) AS quantidade FROM atendimento a
JOIN veterinario v ON v.id=a.veterinario_id GROUP BY v.id,v.nome,a.status ORDER BY v.nome,a.status;

-- Q15 | Último resultado de cada exame, sem apagar os laudos anteriores.
SELECT x.id,t.nome AS exame,z.resultado,z.registrado_em
FROM exame_solicitacao x JOIN tipo_exame t ON t.id=x.tipo_exame_id
JOIN exame_resultado z ON z.solicitacao_id=x.id
WHERE NOT EXISTS(SELECT 1 FROM exame_resultado z2 WHERE z2.solicitacao_id=x.id
 AND (z2.registrado_em>z.registrado_em OR (z2.registrado_em=z.registrado_em AND z2.id>z.id))) ORDER BY x.id;

-- Q16 | Conciliação: a soma do faturamento das categorias deve igualar o total de cobranças.
SELECT (SELECT COALESCE(SUM(faturamento),0) FROM vw_faturamento_categoria) AS por_categoria,
 (SELECT COALESCE(SUM(total_liquido),0) FROM vw_financeiro) AS por_cobranca;

-- FIM: 04_consultas.sql

-- INÍCIO: 06_testes.sql
-- VETDATA | Testes executáveis de sucesso, rejeição, COMMIT e ROLLBACK.
-- Execute depois da carga. O relatório é temporário; os dados de negócio são preservados.
USE vetdata;
DROP TEMPORARY TABLE IF EXISTS resultado_teste;
CREATE TEMPORARY TABLE resultado_teste(
 teste VARCHAR(100), resultado VARCHAR(10), evidencia VARCHAR(500)
) ENGINE=InnoDB;
DROP PROCEDURE IF EXISTS sp_teste_rejeicao;
DROP PROCEDURE IF EXISTS sp_teste_transacao;
DELIMITER $$
CREATE PROCEDURE sp_teste_rejeicao(IN p_nome VARCHAR(100),IN p_sql TEXT,IN p_esperado VARCHAR(120))
BEGIN
 DECLARE v_erro BOOL DEFAULT FALSE;
 DECLARE v_msg TEXT DEFAULT '';
 DECLARE v_estado CHAR(5);
 START TRANSACTION;
 BEGIN
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
  BEGIN SET v_erro=TRUE; GET DIAGNOSTICS CONDITION 1 v_msg=MESSAGE_TEXT,v_estado=RETURNED_SQLSTATE; END;
  SET @teste_sql=p_sql;
  PREPARE teste FROM @teste_sql;
  IF NOT v_erro THEN EXECUTE teste; DEALLOCATE PREPARE teste; END IF;
 END;
 ROLLBACK;
 INSERT INTO resultado_teste VALUES(p_nome,
 IF(v_erro AND (v_msg LIKE CONCAT('%',p_esperado,'%') OR v_estado=p_esperado),'PASSOU','FALHOU'),
 LEFT(CONCAT(COALESCE(v_estado,''),' ',v_msg),500));
END$$
CREATE PROCEDURE sp_teste_transacao()
BEGIN
 DECLARE v_antes INT;
 DECLARE v_id INT;
 DECLARE v_falhou BOOL DEFAULT FALSE;
 SELECT COUNT(*) INTO v_antes FROM responsavel;
 START TRANSACTION;
 BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET v_falhou=TRUE; ROLLBACK; END;
  INSERT INTO responsavel(nome,documento) VALUES('Teste rollback','88000000001');
  SET v_id=LAST_INSERT_ID();
  INSERT INTO contato_responsavel(responsavel_id,tipo,valor) VALUES(v_id,'EMAIL','teste@example.invalid');
  -- Simula falha no terceiro passo; deve desfazer responsável E contato.
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Falha simulada na operação composta';
 END;
 INSERT INTO resultado_teste
 SELECT 'T10 ROLLBACK da operação composta',IF(v_falhou AND COUNT(*)=v_antes,'PASSOU','FALHOU'),'Contagem de responsáveis restaurada; contato desfeito'
 FROM responsavel;
 START TRANSACTION;
 INSERT INTO responsavel(nome,documento) VALUES('Teste commit','88000000002');
 SET v_id=LAST_INSERT_ID();
 INSERT INTO contato_responsavel(responsavel_id,tipo,valor) VALUES(v_id,'EMAIL','commit@example.invalid');
 COMMIT;
 INSERT INTO resultado_teste SELECT 'T11 COMMIT da operação composta',
 IF(COUNT(*)=1,'PASSOU','FALHOU'),'Responsável e contato confirmados juntos'
 FROM responsavel r JOIN contato_responsavel c ON c.responsavel_id=r.id WHERE r.id=v_id;
 -- Limpeza controlada: apenas o cadastro técnico recém-criado e sem animais.
 DELETE FROM contato_responsavel WHERE responsavel_id=v_id;
 DELETE FROM responsavel WHERE id=v_id;
END$$
DELIMITER ;

CALL sp_teste_rejeicao('T01 Animal sem responsável',
 'INSERT INTO animal(responsavel_id,raca_id,nome) VALUES(NULL,1,''Órfão teste'')','Responsável ativo obrigatório');
CALL sp_teste_rejeicao('T02 Horários sobrepostos',
 'INSERT INTO atendimento(animal_id,veterinario_id,inicio,fim,motivo) SELECT 19,veterinario_id,inicio,fim,''Conflito teste'' FROM atendimento WHERE id=41','Conflito');
CALL sp_teste_rejeicao('T03 Resultado de exame não solicitado',
 'INSERT INTO exame_resultado(solicitacao_id,autor_id,resultado) VALUES(999999,1,''Inválido'')','solicitação com coleta');
CALL sp_teste_rejeicao('T04 Vacina sem lote',
 'INSERT INTO vacinacao(atendimento_id,lote_id,profissional_id,aplicada_em) VALUES(41,NULL,1,CURRENT_DATE)','Lote inválido');
CALL sp_teste_rejeicao('T05 Preço negativo',
 'INSERT INTO servico(categoria_id,nome,preco_base) VALUES(1,''Serviço negativo teste'',-1)','23000');
INSERT INTO atendimento_servico(atendimento_id,servico_id,quantidade,valor_unitario) VALUES(42,1,1,150);
SET @item_teste_desconto=LAST_INSERT_ID();
CALL sp_teste_rejeicao('T06 Desconto acima de 30%',
 'INSERT INTO cobranca(atendimento_id,desconto_pct,emitida_em,vencimento) VALUES(42,40,CURRENT_DATE,CURRENT_DATE)','23000');
DELETE FROM atendimento_servico WHERE id=@item_teste_desconto;
CALL sp_teste_rejeicao('T07 Exclusão de evolução clínica',
 'DELETE FROM registro_clinico WHERE id=1','Histórico imutável');
CALL sp_teste_rejeicao('T08 Responsável inativo com animais',
 'UPDATE responsavel SET ativo=0 WHERE id=1','Transfira todos os animais');
CALL sp_teste_rejeicao('T09 Pagamento maior que o saldo',
 'INSERT INTO pagamento(cobranca_id,forma_id,valor) VALUES(41,1,999999)','acima do saldo');
CALL sp_teste_transacao();

INSERT INTO resultado_teste SELECT 'T12 Cancelamento mantém cobrança e estorna',
 IF(a.status='CANCELADO' AND f.cancelada=1 AND f.saldo=0 AND f.recebido=0
 AND (SELECT COUNT(*) FROM estorno e JOIN pagamento p ON p.id=e.pagamento_id WHERE p.cobranca_id=f.id)=1,
 'PASSOU','FALHOU'),'Atendimento 57: auditoria, fatura e pagamento preservados; estorno integral'
FROM atendimento a JOIN vw_financeiro f ON f.atendimento_id=a.id JOIN cancelamento ca ON ca.atendimento_id=a.id WHERE a.id=57;

INSERT INTO resultado_teste SELECT 'T13 Histórico e retificação preservados',
 IF(COUNT(*)=3 AND SUM(c.retifica_id IS NOT NULL)=1,'PASSOU','FALHOU'),'Animal 1: duas consultas, original e retificação consultáveis'
FROM registro_clinico c JOIN atendimento a ON a.id=c.atendimento_id WHERE a.animal_id=1;

INSERT INTO resultado_teste SELECT 'T14 Conciliação dos indicadores',
 IF((SELECT SUM(faturamento) FROM vw_faturamento_categoria)=(SELECT SUM(total_liquido) FROM vw_financeiro),'PASSOU','FALHOU'),
 'Soma das categorias = soma de cobranças líquidas';

INSERT INTO resultado_teste SELECT 'T15 Agenda sem sobreposição',IF(COUNT(*)=0,'PASSOU','FALHOU'),'Intervalos adjacentes são permitidos; sobrepostos não'
FROM atendimento a JOIN atendimento b ON a.id<b.id AND (a.veterinario_id=b.veterinario_id OR a.animal_id=b.animal_id)
AND a.inicio<b.fim AND a.fim>b.inicio WHERE a.status<>'CANCELADO' AND b.status<>'CANCELADO';

INSERT INTO resultado_teste SELECT 'T16 Dados para vacinação pendente',IF(COUNT(*)>0,'PASSOU','FALHOU'),'Há doses vencidas/próximas; doses antigas substituídas não duplicam alerta' FROM vw_vacinacao_pendente;

CALL sp_teste_rejeicao('T17 Integridade referencial do tipo de exame',
 'INSERT INTO exame_solicitacao(atendimento_id,tipo_exame_id) VALUES(41,999999)','23000');
CALL sp_teste_rejeicao('T18 Aplicação de lote vencido',
 'INSERT INTO vacinacao(atendimento_id,lote_id,profissional_id,aplicada_em) VALUES(24,6,1,CURRENT_DATE)','Lote inválido');

SELECT * FROM resultado_teste ORDER BY teste;
SELECT COUNT(*) AS total_testes,SUM(resultado='PASSOU') AS passaram,SUM(resultado='FALHOU') AS falharam FROM resultado_teste;
DROP PROCEDURE sp_teste_rejeicao;
DROP PROCEDURE sp_teste_transacao;

-- FIM: 06_testes.sql
