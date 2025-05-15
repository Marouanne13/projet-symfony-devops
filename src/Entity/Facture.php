<?php

namespace App\Entity;

use App\Repository\FactureRepository;
use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Validator\Constraints as Assert;

#[ORM\Entity(repositoryClass: FactureRepository::class)]
class Facture
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\Column(length: 100, unique: true)]
    #[Assert\NotBlank(message: 'Le numéro de facture est obligatoire.')]
    private ?string $invoiceNumber = null;

    #[ORM\Column(type: Types::DATETIME_MUTABLE)]
    #[Assert\NotNull(message: 'La date de facturation est requise.')]
    private ?\DateTimeInterface $billingDate = null;

    #[ORM\Column]
    #[Assert\NotNull(message: 'Le montant est requis.')]
    #[Assert\Positive(message: 'Le montant doit être supérieur à zéro.')]
    private ?float $amount = null;

    #[ORM\Column(length: 100)]
    #[Assert\NotBlank(message: 'L\'état de la facture est requis.')]
    #[Assert\Choice(
        choices: ['Payée', 'Partiellement payée', 'Non payée'],
        message: 'L\'état doit être : Payée, Partiellement payée ou Non payée.'
    )]
    private ?string $status = null;

    #[ORM\Column(type: Types::TEXT, nullable: true)]
    #[Assert\Length(max: 1000, maxMessage: 'La note ne doit pas dépasser 1000 caractères.')]
    private ?string $note = null;

    #[ORM\ManyToOne(inversedBy: 'factures')]
    #[Assert\NotNull(message: 'Le client est requis pour la facture.')]
    private ?Client $client = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getInvoiceNumber(): ?string
    {
        return $this->invoiceNumber;
    }

    public function setInvoiceNumber(string $invoiceNumber): static
    {
        $this->invoiceNumber = $invoiceNumber;
        return $this;
    }

    public function getBillingDate(): ?\DateTimeInterface
    {
        return $this->billingDate;
    }

    public function setBillingDate(\DateTimeInterface $billingDate): static
    {
        $this->billingDate = $billingDate;
        return $this;
    }

    public function getAmount(): ?float
    {
        return $this->amount;
    }

    public function setAmount(float $amount): static
    {
        $this->amount = $amount;
        return $this;
    }

    public function getStatus(): ?string
    {
        return $this->status;
    }

    public function setStatus(string $status): static
    {
        $this->status = $status;
        return $this;
    }

    public function getNote(): ?string
    {
        return $this->note;
    }

    public function setNote(?string $note): static
    {
        $this->note = $note;
        return $this;
    }

    public function getClient(): ?Client
    {
        return $this->client;
    }

    public function setClient(?Client $client): static
    {
        $this->client = $client;
        return $this;
}
}
