<?php

class Vacinacao
{
    private int $atendimentoId;
    private int $loteId;
    private int $profissionalId;
    private string $aplicadaEm;
    private ?string $proximaDose;

    public function __construct(int $atendimentoId, int $loteId, int $profissionalId, string $aplicadaEm, ?string $proximaDose)
    {
        $this->atendimentoId = $atendimentoId;
        $this->loteId = $loteId;
        $this->profissionalId = $profissionalId;
        $this->aplicadaEm = $aplicadaEm;
        $this->proximaDose = $proximaDose;
    }

    public function getAtendimentoId(): int
    {
        return $this->atendimentoId;
    }

    public function getLoteId(): int
    {
        return $this->loteId;
    }

    public function getProfissionalId(): int
    {
        return $this->profissionalId;
    }

    public function getAplicadaEm(): string
    {
        return $this->aplicadaEm;
    }

    public function getProximaDose(): ?string
    {
        return $this->proximaDose;
    }
}
