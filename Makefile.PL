use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Maypole::Plugin::Transaction',
    AUTHOR       => 'Sebastian Riedel (sri@oook.de)',
    VERSION_FROM => 'Transaction.pm',
    PREREQ_PM    => { Maypole => '2.0' }
);
