use ExtUtils::MakeMaker;
use Config;

WriteMakefile(
    'NAME'         => 'Getopt::ExPar',
    'VERSION_FROM' => 'ExPar.pm',
    'dist'         => {COMPRESS => 'gzip', SUFFIX => 'gz'}
);
