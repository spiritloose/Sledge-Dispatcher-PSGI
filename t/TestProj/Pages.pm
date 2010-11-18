package t::TestProj::Pages;
use strict;
use base 'Sledge::Pages::PSGI';

use Sledge::Authorizer::Null;
use Sledge::Charset::Default;
use Sledge::SessionManager::Cookie;
use Sledge::Session::MySQL;
use Sledge::Template::TT;

use t::TestProj::Config;

sub create_authorizer {
    my $self = shift;
    return Sledge::Authorizer::Null->new($self);
}

sub create_charset {
    my $self = shift;
    return Sledge::Charset::Default->new($self);
}

sub create_config {
    my $self = shift;
    return t::TestProj::Config->instance;
}

sub create_manager {
    my $self = shift;
    return Sledge::SessionManager::Cookie->new($self);
}

sub create_session {
    my($self, $sid) = @_;
    return Sledge::Session::MySQL->new($self, $sid);
}

sub construct_session {}

1;
