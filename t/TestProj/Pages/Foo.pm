package t::TestProj::Pages::Foo;
use strict;
use warnings;
use base 't::TestProj::Pages';

__PACKAGE__->tmpl_dirname('foo');

sub dispatch_index {}

sub dispatch_bar {}

1;
__END__
