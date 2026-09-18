<?php

class Agendamento
{
    private int $animalId;
    private int $veterinarioId;
    private string $inicio;
    private string $fim;
    private string $motivo;

    public function __construct(int $animalId, int $veterinarioId, string $inicio, string $fim, string $motivo)
    {
        $this->animalId = $animalId;
        $this->veterinarioId = $veterinarioId;
        $this->inicio = $inicio;
        $this->fim = $fim;
        $this->motivo = $motivo;
    }

    public function getAnimalId(): int
    {
        return $this->animalId;
    }

    public function getVeterinarioId(): int
    {
        return $this->veterinarioId;
    }

    public function getInicio(): string
    {
        return $this->inicio;
    }

    public function getFim(): string
    {
        return $this->fim;
    }

    public function getMotivo(): string
    {
        return $this->motivo;
    }
}
