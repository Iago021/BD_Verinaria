<?php

class Animal
{
    private int $id;
    private int $responsavelId;
    private int $racaId;
    private string $nome;
    private string $sexo;
    private ?string $nascimento;
    private ?string $microchip;

    public function __construct(int $id, int $responsavelId, int $racaId, string $nome, string $sexo, ?string $nascimento, ?string $microchip)
    {
        $this->id = $id;
        $this->responsavelId = $responsavelId;
        $this->racaId = $racaId;
        $this->nome = $nome;
        $this->sexo = $sexo;
        $this->nascimento = $nascimento;
        $this->microchip = $microchip;
    }

    public function getId(): int
    {
        return $this->id;
    }

    public function getResponsavelId(): int
    {
        return $this->responsavelId;
    }

    public function getRacaId(): int
    {
        return $this->racaId;
    }

    public function getNome(): string
    {
        return $this->nome;
    }

    public function getSexo(): string
    {
        return $this->sexo;
    }

    public function getNascimento(): ?string
    {
        return $this->nascimento;
    }

    public function getMicrochip(): ?string
    {
        return $this->microchip;
    }
}
