<?php

class Veterinario
{
    private string $nome;
    private string $crmv;
    private int $especialidadeId;

    public function __construct(string $nome, string $crmv, int $especialidadeId)
    {
        $this->nome = $nome;
        $this->crmv = $crmv;
        $this->especialidadeId = $especialidadeId;
    }

    public function getNome(): string
    {
        return $this->nome;
    }

    public function getCrmv(): string
    {
        return $this->crmv;
    }

    public function getEspecialidadeId(): int
    {
        return $this->especialidadeId;
    }
}
