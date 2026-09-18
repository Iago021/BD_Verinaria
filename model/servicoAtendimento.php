<?php

class ServicoAtendimento
{
    private int $atendimentoId;
    private int $servicoId;
    private int $quantidade;
    private string $valorUnitario;

    public function __construct(int $atendimentoId, int $servicoId, int $quantidade, string $valorUnitario)
    {
        $this->atendimentoId = $atendimentoId;
        $this->servicoId = $servicoId;
        $this->quantidade = $quantidade;
        $this->valorUnitario = $valorUnitario;
    }

    public function getAtendimentoId(): int
    {
        return $this->atendimentoId;
    }

    public function getServicoId(): int
    {
        return $this->servicoId;
    }

    public function getQuantidade(): int
    {
        return $this->quantidade;
    }

    public function getValorUnitario(): string
    {
        return $this->valorUnitario;
    }
}
