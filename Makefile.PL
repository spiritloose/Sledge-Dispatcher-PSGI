use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Sledge::Dispatcher::PSGI',
    AUTHOR           => 'Jiro Nishiguchi <jiro@cpan.org>',
    VERSION_FROM     => 'lib/Sledge/Dispatcher/PSGI.pm',
    ABSTRACT_FROM    => 'lib/Sledge/Dispatcher/PSGI.pm',
    LICENSE          => 'perl',
    PL_FILES         => {},
    PREREQ_PM        => {
        'Test::More'     => 0,
        'Sledge::Hammer' => '1.0',
        'Plack'          => '0.9910',
    },
    dist             => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean            => { FILES    => 'Sledge-Dispatcher-PSGI*' },
);
