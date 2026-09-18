<?php

class RegistroClinico
{
    private int $atendimentoId;
    private int $autorId;
    private string $anamnese;
    private string $diagnostico;
    private ?string $observacoes;
    private ?string $pesoKg;
    private ?int $retificaId;

    public function __construct(int $atendimentoId, int $autorId, string $anamnese, string $diagnostico, ?string $observacoes, ?string $pesoKg, ?int $retificaId)
    {
        $this->atendimentoId = $atendimentoId;
        $this->autorId = $autorId;
        $this->anamnese = $anamnese;
        $this->diagnostico = $diagnostico;
        $this->observacoes = $observacoes;
        $this->pesoKg = $pesoKg;
        $this->retificaId = $retificaId;
    }

    public function getAtendimentoId(): int
    {
        return $this->atendimentoId;
    }

    public function getAutorId(): int
    {
        return $this->autorId;
    }

    public function getAnamnese(): string
    {
        return $this->anamnese;
    }

    public function getDiagnostico(): string
    {
        return $this->diagnostico;
    }

    public function getObservacoes(): ?string
    {
        return $this->observacoes;
    }

    public function getPesoKg(): ?string
    {
        return $this->pesoKg;
    }

    public function getRetificaId(): ?int
    {
        return $this->retificaId;
    }
}
