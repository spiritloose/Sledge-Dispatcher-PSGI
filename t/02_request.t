use strict;
use Test::More tests => 19;
BEGIN { $ENV{SLEDGE_CONFIG_NAME} = '_test' }
use Plack::Test;
use HTTP::Request::Common;

package t::TestProj::Pages::Test;
use Test::More;
use base 't::TestProj::Pages';

sub dispatch_get {
    my $self = shift;
    isa_ok $self->r, 'Sledge::Request::PSGI';
    is $self->r->method, 'GET';
    ok !$self->is_post_request;
    is $self->r->uri, '/get';
    is $self->r->args, 'foo=bar';
    is $self->r->param('foo'), 'bar';
    is $self->r->header_in('X-Foobar'), 'foobar';

    $self->r->pnotes(foo => 'bar');
    is $self->r->pnotes('foo'), 'bar';

    $self->r->status(404);
    $self->r->content_type('text/plain');
    $self->r->header_out('X-Hogehoge', 'hogehoge');
    $self->r->print('dispatch_get');
    $self->finished(1);
}

sub dispatch_post {
    my $self = shift;
    is $self->r->method, 'POST';
    ok $self->is_post_request;
    is $self->r->uri, '/post';
    is $self->r->param('foo'), 'bar';
    $self->r->content_type('text/html');
    $self->r->header_out('X-Hogehoge', 'hogehoge');
    $self->r->print('dispatch_post');
    $self->finished(1);
}

package main;

test_psgi
    app => sub { t::TestProj::Pages::Test->new(@_)->dispatch('get') },
    client => sub {
        my $res = shift->(GET '/get?foo=bar', 'X-Foobar' => 'foobar');
        is $res->code, 404;
        is $res->content_type, 'text/plain';
        is $res->header('X-Hogehoge'), 'hogehoge';
        is $res->content, 'dispatch_get';
    };

test_psgi
    app => sub { t::TestProj::Pages::Test->new(@_)->dispatch('post') },
    client => sub {
        my $res = shift->(POST '/post', [foo => 'bar']);
        is $res->code, 200;
        is $res->content_type, 'text/html';
        is $res->content, 'dispatch_post';
    };
