<?php

class Responsavel
{
    private int $id;
    private string $nome;
    private string $documento;
    private string $email;
    private string $telefone;

    public function __construct(int $id, string $nome, string $documento, string $email, string $telefone)
    {
        $this->id = $id;
        $this->nome = $nome;
        $this->documento = $documento;
        $this->email = $email;
        $this->telefone = $telefone;
    }

    public function getId(): int
    {
        return $this->id;
    }

    public function getNome(): string
    {
        return $this->nome;
    }

    public function getDocumento(): string
    {
        return $this->documento;
    }

    public function getEmail(): string
    {
        return $this->email;
    }

    public function getTelefone(): string
    {
        return $this->telefone;
    }
}
