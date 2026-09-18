<?php

class Prescricao
{
    private int $atendimentoId;
    private int $medicamentoId;
    private string $posologia;
    private int $duracaoDias;
    private ?string $orientacoes;

    public function __construct(int $atendimentoId, int $medicamentoId, string $posologia, int $duracaoDias, ?string $orientacoes)
    {
        $this->atendimentoId = $atendimentoId;
        $this->medicamentoId = $medicamentoId;
        $this->posologia = $posologia;
        $this->duracaoDias = $duracaoDias;
        $this->orientacoes = $orientacoes;
    }

    public function getAtendimentoId(): int
    {
        return $this->atendimentoId;
    }

    public function getMedicamentoId(): int
    {
        return $this->medicamentoId;
    }

    public function getPosologia(): string
    {
        return $this->posologia;
    }

    public function getDuracaoDias(): int
    {
        return $this->duracaoDias;
    }

    public function getOrientacoes(): ?string
    {
        return $this->orientacoes;
    }
}
