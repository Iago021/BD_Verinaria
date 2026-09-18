<?php
require_once __DIR__ . '/baseDAO.php';

class PainelDAO extends BaseDAO
{
    public function indicadores(): array
    {
        return $this->um("SELECT (SELECT COUNT(*) FROM atendimento WHERE inicio>=CURRENT_DATE AND inicio<DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY) AND status<>'CANCELADO') AS agenda,(SELECT COUNT(*) FROM animal WHERE ativo=1) AS pacientes,(SELECT COALESCE(SUM(total_liquido),0) FROM vw_financeiro WHERE emitida_em>=DATE_FORMAT(CURRENT_DATE,'%Y-%m-01')) AS faturamento,(SELECT COUNT(*) FROM vw_financeiro WHERE saldo>0) AS pendencias");
    }
}
