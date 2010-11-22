use strict;
use Test::More tests => 6;
BEGIN { $ENV{SLEDGE_CONFIG_NAME} = '_test' }

use Plack::Test;
use HTTP::Request::Common;
use t::TestProj::Pages::Root;

test_psgi
    app => sub { t::TestProj::Pages::Root->new(@_)->dispatch('index') },
    client => sub {
        my $cb = shift;
        my $res = $cb->(GET '/');
        is $res->content, "Hello, /index\n";
        is $res->code, 200;
        is $res->content_type, 'text/html';
    };

test_psgi
    app => sub { t::TestProj::Pages::Root->new(@_)->dispatch('hoge') },
    client => sub {
        my $cb = shift;
        my $res = $cb->(GET '/');
        is $res->content, "Hello, /hoge\n";
        is $res->code, 200;
        is $res->content_type, 'text/html';
    };
