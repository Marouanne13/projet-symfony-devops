<?php

namespace App\Command;

use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

#[AsCommand(
    name: 'create:admin',
    description: 'Créer un utilisateur admin pour le CRM',
)]
class CreateAdminCommand extends Command
{
    private EntityManagerInterface $em;
    private UserPasswordHasherInterface $hasher;

    public function __construct(EntityManagerInterface $em, UserPasswordHasherInterface $hasher)
    {
        parent::__construct();
        $this->em = $em;
        $this->hasher = $hasher;
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new SymfonyStyle($input, $output);

        $user = new User();
        $user->setEmail('admin@crm.com');
        $user->setFirstName('Admin');
        $user->setLastName('Test');
        $user->setRoles(['ROLE_ADMIN']);

        $hashedPassword = $this->hasher->hashPassword($user, 'adminpass');
        $user->setPassword($hashedPassword);

        $this->em->persist($user);
        $this->em->flush();

        $io->success('✅ Utilisateur admin créé : admin@crm.com / adminpass');

        return Command::SUCCESS;
        }
}
