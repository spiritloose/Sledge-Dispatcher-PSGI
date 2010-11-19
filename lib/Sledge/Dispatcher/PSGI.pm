package Sledge::Dispatcher::PSGI;
use strict;
use warnings;

use File::Basename;
use Sledge::Exceptions;

our $VERSION = '0.0.1';

our $DEBUG = 0;

my %loaded;

sub DECLINED() {
    my $body = "Not Found\n";
    [404, ['Content-Type' => 'text/plain', 'Content-Length' => length $body], [$body]];
}

sub new {
    my ($class, %config) = @_;
    bless { config => \%config }, $class;
}

sub to_app {
    my $self = shift;
    sub { $self->handler(@_) };
}

sub config {
    my ($self, $name) = @_;
    $self->{config}->{$name};
}

sub debug {
    my ($env, $args) = @_;
    return unless $DEBUG;
    chomp $args;
    $env->{'psgi.errors'}->print("$args\n");
}

sub _load_module {
    my ($self, $env, $module) = @_;
    debug($env, "loading $module");
    return if $loaded{$module};

    no strict 'refs';
    eval "require $module";
    if ($@ && $@ !~ /Can't locate/) {
        debug($env, "error loading $module: $@");
        die $@;
    } elsif ($@) {
        debug($env, "erorr loading $module: $@");
    }
    $loaded{$module} = 1;
}

sub null_method { }

sub determine {
    my ($self, $env) = @_;

    # we can ignore extensions!
    my $ext = $self->config('Extension') || '.cgi';

    # for static .html
    my $static = $self->config('StaticExtension') || '.html';

    # determine directory and page name
    my ($page, $dir, $suf) = File::Basename::fileparse($env->{PATH_INFO}, $ext, $static);

    # don't match with $ext and $static
    if (index($page, '.') >= 0) {
        debug($env, "$page doesn't match with $ext and $static");
        return;
    }

    # Removed <Location> specific code. use Plack::App::URLMap.
    $dir =~ s!/$!!; # remove trailing slash

    my $loadclass = $self->do_determine($env, $dir);
    return $loadclass, $page, $suf eq $static, ($page eq '' && $suf eq '');
}

sub handler {
    my ($self, $env) = @_;
    my ($loadclass, $page, $is_static, $slash) = $self->determine($env);
    unless ($loadclass) {
        return DECLINED;
    };

    debug($env, "loadclass is $loadclass, page is $page");

    $self->_load_module($env, $loadclass);

    my $no_static = do {
        my $config = $self->config('DispatchStatic');
        defined $config ? $config : 0;
    };
    if ($is_static && !$self->_generated($loadclass, $page)) {
        debug($env, 'static method, but not yet auto-generated');
        if ($no_static || $loadclass->can("dispatch_$page")) {
            debug($env, "dispatch_$page exists, but access is $page.html");
            return DECLINED;
        } else {
            $self->_generate_method($env, $loadclass, $page);
        }
    } elsif ($slash) {
        my @indexes = $self->config('DirectoryIndex') ?
        split(/\s+/, $self->config('DirectoryIndex')) : 'index';
        debug($env, "indexes: ", join(",", @indexes));
        for my $index (@indexes) {
            if ($loadclass->can("dispatch_$index")) {
                debug($env, "$loadclass can do $index");
                $page = $index;
                last;
            }
        }
        $page ||= $indexes[0];
        debug($env, "page is $page");

        if (!$loadclass->can("dispatch_$page")) {
            if ($no_static) {
                debug($env, "access to slash, but no_static is on");
                return DECLINED;
            }
            $self->_generate_method($env, $loadclass, $page);
        }
    } elsif (!$is_static && $self->_generated($loadclass, $page)) {
        debug($env, "access to dynamic after static method $page made");
        return DECLINED;
    }

    unless ($loadclass->can("dispatch_$page")) {
        debug($env, "$loadclass can't do $page");
        return DECLINED;
    }

    debug($env, "ok now loading $loadclass - $page");
    local %ENV = (%ENV, %$env);
    $loadclass->new($env)->dispatch($page);
}

my %generated;

sub _generate_method {
    my ($self, $env, $loadclass, $page) = @_;
    debug($env, "generating $page on $loadclass");
    no strict 'refs';
    if (-e $loadclass->guess_filename($page)) {
        *{"$loadclass\::dispatch_$page"} = \&null_method;
        $generated{$loadclass, $page} = 1;
    }
}

sub _generated {
    my ($self, $loadclass, $page) = @_;
    return $generated{$loadclass, $page};
}

sub do_determine { Sledge::Exception::AbstractMethod->throw }

1;
__END__

=head1 NAME

Sledge::Dispatcher::PSGI - auto-dispatch PSGI application

=head1 SYNOPSIS

B<DO NOT USE THIS MODULE DIRECTORY>.

See L<Sledge::Dispatcher::PSGI::Properties> or
L<Sledge::Dispatcher::PSGI::Dynamic> for actual usage.

=head1 AUTHOR

Jiro Nishiguchi E<lt>jiro@cpan.orgE<gt>

Original author: Tatsuhiko Miyagawa with Sledge developers.

=cut
