package Sledge::Pages::PSGI;
use strict;
use warnings;
use base 'Sledge::Pages::Base';

use Sledge::Request::PSGI;

sub dispatch {
    my ($self, $page) = @_;
    my $res = $self->r->res;
    $self->SUPER::dispatch($page);
    $res->finalize;
}

sub create_request {
    my ($self, $env) = @_;
    return Sledge::Request::PSGI->new($env);
}

1;
__END__
