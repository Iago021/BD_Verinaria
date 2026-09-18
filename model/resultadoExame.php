<?php

class ResultadoExame
{
    private int $solicitacaoId;
    private int $autorId;
    private string $resultado;

    public function __construct(int $solicitacaoId, int $autorId, string $resultado)
    {
        $this->solicitacaoId = $solicitacaoId;
        $this->autorId = $autorId;
        $this->resultado = $resultado;
    }

    public function getSolicitacaoId(): int
    {
        return $this->solicitacaoId;
    }

    public function getAutorId(): int
    {
        return $this->autorId;
    }

    public function getResultado(): string
    {
        return $this->resultado;
    }
}
