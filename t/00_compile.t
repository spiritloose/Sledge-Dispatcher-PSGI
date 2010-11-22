use strict;
use Test::More tests => 6;

BEGIN {
    use_ok 'Sledge::Dispatcher::PSGI';
    use_ok 'Sledge::Dispatcher::PSGI::Dynamic';
    use_ok 'Sledge::Dispatcher::PSGI::Properties';
    use_ok 'Sledge::Pages::PSGI';
    use_ok 'Sledge::Request::PSGI';
    use_ok 'Sledge::Request::PSGI::Upload';
}
