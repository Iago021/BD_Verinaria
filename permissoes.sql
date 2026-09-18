-- VETDATA | 07_permissoes.sql | Opcional: executar com administrador do servidor.
-- Duas contas locais de demonstração. Troque as senhas antes de qualquer outro uso.
-- IF NOT EXISTS não redefine a senha de uma conta já existente.
CREATE USER IF NOT EXISTS 'vet_app'@'localhost' IDENTIFIED BY 'VetData_Local_2026!';
CREATE USER IF NOT EXISTS 'vet_gestao'@'localhost' IDENTIFIED BY 'VetData_Leitura_2026!';
GRANT SELECT ON vetdata.* TO 'vet_app'@'localhost';
GRANT SELECT ON vetdata.vw_agenda TO 'vet_gestao'@'localhost';
GRANT SELECT ON vetdata.vw_financeiro TO 'vet_gestao'@'localhost';
GRANT SELECT ON vetdata.vw_faturamento_categoria TO 'vet_gestao'@'localhost';
GRANT SELECT ON vetdata.vw_vacinacao_pendente TO 'vet_gestao'@'localhost';

GRANT INSERT,UPDATE ON vetdata.responsavel TO 'vet_app'@'localhost';
GRANT INSERT,UPDATE ON vetdata.contato_responsavel TO 'vet_app'@'localhost';
GRANT INSERT,UPDATE ON vetdata.animal TO 'vet_app'@'localhost';
GRANT INSERT,UPDATE ON vetdata.veterinario TO 'vet_app'@'localhost';
GRANT INSERT,UPDATE ON vetdata.veterinario_especialidade TO 'vet_app'@'localhost';
GRANT INSERT,UPDATE ON vetdata.disponibilidade TO 'vet_app'@'localhost';
GRANT DELETE ON vetdata.contato_responsavel TO 'vet_app'@'localhost';
GRANT INSERT ON vetdata.registro_clinico TO 'vet_app'@'localhost';
GRANT INSERT ON vetdata.atendimento_servico TO 'vet_app'@'localhost';
GRANT INSERT ON vetdata.exame_solicitacao TO 'vet_app'@'localhost';
GRANT INSERT ON vetdata.exame_resultado TO 'vet_app'@'localhost';
GRANT INSERT ON vetdata.vacinacao TO 'vet_app'@'localhost';
GRANT INSERT ON vetdata.prescricao TO 'vet_app'@'localhost';
GRANT UPDATE (coletado_em) ON vetdata.exame_solicitacao TO 'vet_app'@'localhost';
GRANT UPDATE (status) ON vetdata.atendimento TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE vetdata.sp_agendar TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE vetdata.sp_remarcar TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE vetdata.sp_cancelar TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE vetdata.sp_receber TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE vetdata.sp_emitir_cobranca TO 'vet_app'@'localhost';
SHOW GRANTS FOR 'vet_app'@'localhost';
SHOW GRANTS FOR 'vet_gestao'@'localhost';