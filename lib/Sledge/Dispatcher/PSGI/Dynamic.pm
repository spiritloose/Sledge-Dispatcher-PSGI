package Sledge::Dispatcher::PSGI::Dynamic;
use strict;
use warnings;
use base 'Sledge::Dispatcher::PSGI';

use Sledge::Exceptions;

sub do_determine {
    my ($self, $env, $dir) = @_;

    my @class = grep length, split /\//, $dir;
    if (!@class and my $root = $self->config('RootDirClassName')) {
        @class = ($root);
    }

    my $base = $self->config('BaseClass')
            or Sledge::Exception::ConfigKeyUndefined->throw('BaseClass needed');
    my $loadclass = join('::', $base, map { $self->_capitalize($_) } @class);
    return $loadclass;
}

sub _capitalize {
    my ($self, $ent) = @_;

    # foo_bar => FooBar
    my $cap = ucfirst $ent;
    $cap =~ s/_(\w)/uc($1)/eg;
    return $cap;
}

1;
__END__

=head1 NAME

Sledge::Dispatcher::PSGI::Dynamic - auto-dispatch PSGI application

=head1 SYNOPSIS

  my $dispatcher = Sledge::Dispatcher::PSGI::Dynamic->new(
      BaseClass => 'MyProject::Pages',
      RootDirClassName => 'Index',
  );
  my $app = $dispatcher->to_app;

=head1 AUTHOR

Jiro Nishiguchi E<lt>jiro@cpan.orgE<gt>

Original author: Tatsuhiko Miyagawa with Sledge developers.

=cut
