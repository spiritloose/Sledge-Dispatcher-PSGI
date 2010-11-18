package t::TestProj::Config::_common;
use strict;
use vars qw(%C);
*Config = \%C;

$C{TMPL_PATH}     = 't/view';
$C{DATASOURCE}    = [ 'dbi:mysql:sledge','root', '' ];
$C{COOKIE_NAME}   = 'sledge_sid';
$C{COOKIE_PATH}   = '/';
$C{COOKIE_DOMAIN} = undef;

1;
