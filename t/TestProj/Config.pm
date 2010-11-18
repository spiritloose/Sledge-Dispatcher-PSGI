package t::TestProj::Config;
use strict;

use base qw(Sledge::Config Class::Singleton);

sub case_sensitive { 0 }

sub _new_instance {
    my $class = shift;
    unless (defined $ENV{SLEDGE_CONFIG_NAME}) {
        do '/etc/t-TestProj-conf.pl' or warn $!;
    }
    $class->SUPER::new($ENV{SLEDGE_CONFIG_NAME});
}

1;
