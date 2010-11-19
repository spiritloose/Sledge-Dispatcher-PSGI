use strict;
use Test::More tests => 7;
BEGIN { $ENV{SLEDGE_CONFIG_NAME} = '_test' }

use Plack::Test;
use HTTP::Request::Common;
use Sledge::Dispatcher::PSGI::Properties;

my $dispatcher = Sledge::Dispatcher::PSGI::Properties->new(
    MapFile => 't/map/map.props',
);
my $app = $dispatcher->to_app;

test_psgi $app, sub {
    my $cb = shift;
    my $res;
    $res = $cb->(GET '/');
    is $res->content, "Hello, /index\n";
    $res = $cb->(GET '/hoge');
    is $res->content, "Hello, /hoge\n";

    $res = $cb->(GET '/foo/');
    is $res->content, "Hello, /foo/index\n";
    $res = $cb->(GET '/foo/bar');
    is $res->content, "Hello, /foo/bar\n";
    $res = $cb->(GET '/foo/static.html');
    is $res->content, "Hello, static\n";
    $res = $cb->(GET '/foo/static');
    is $res->code, 404;
    is $res->content, "Not Found\n";
};
done_testing;
