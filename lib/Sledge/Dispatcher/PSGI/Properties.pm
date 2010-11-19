package Sledge::Dispatcher::PSGI::Properties;
use strict;
use warnings;
use base 'Sledge::Dispatcher::PSGI';

use Data::Properties;
use FileHandle;
use UNIVERSAL::require;

sub load_property {
    my ($self, $env, $path) = @_;
    $self->{cache} ||= {};
    if (!$self->{cache}->{$path} ||
        ($self->_reload($env) && ($self->{cache}->{$path}->[1] < _mtime($path)))) {
        my $props  = Data::Properties->new;
        my $handle = FileHandle->new($path) or
        Sledge::Exception::PropertiesNotFound->throw("$path: $!");
        $props->load($handle);
        $self->init_modules($props);
        $self->{cache}->{$path} = [ $props, _mtime($path) ];
    }
    return $self->{cache}->{$path}->[0];
}

sub _reload {
    my ($self, $env) = @_;
    $self->config('MapReload');
}

sub init_modules {
    my ($self, $props) = @_;
    for my $name ($props->property_names) {
        my $module = $props->get_property($name);
        $module->require or die $UNIVERSAL::require::ERROR;
    }
}

sub _mtime { (stat(shift))[9] }

sub do_determine {
    my ($self, $env, $dir) = @_;

    # load property file
    my $map_path = $self->config('MapFile')
        or Sledge::Exception::MapFileUndefined->throw;
    my $props = $self->load_property($env, $map_path);
    my $loadclass = $props->get_property($dir) || $props->get_property("$dir/");

    return $loadclass || $self->config('StaticClass');
}

1;
__END__

=head1 NAME

Sledge::Dispatcher::PSGI::Properties - auto-dispatch PSGI application

=head1 SYNOPSIS

  my $dispatcher = Sledge::Dispatcher::PSGI::Properties->new(
      MapFile        => '/path/to/map.props',
      DispatchStatic => 0,
      MapReload      => 0,
  );
  my $app = $dispatcher->to_app;

  # map.props
  / = My::Pages::Index
  /bar = My::Pages::Bar

  # MyApp/Pages.pm
  use base 'Sledge::Pages::PSGI';

  # http://localhost/
  # => My::Pages::Index->new->dispatch('index')
  # http://localhost/bar/baz
  # => My::Pages::Bar->new->dispatch('baz')

  # like Struts!
  use Plack::Builder;
  builder {
      my $dispatcher = Sledge::Dispatcher::PSGI::Properties->new(
          MapFile => '/path/to/map.props',
          Extension => '.do',
      );
      mount => $dispatcher->to_app;
  };

  # map.props
  # you DON'T need /webapp here!!!
  / = My::Pages::Index

  # then access http://localhost/webapp/bar.do
  # => My::Pages::Index->new->dispatch('bar')

=head1 AUTHOR

Jiro Nishiguchi E<lt>jiro@cpan.orgE<gt>

Original author: Tatsuhiko Miyagawa with Sledge developers.

=cut
