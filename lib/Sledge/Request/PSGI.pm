package Sledge::Request::PSGI;
use strict;
use warnings;
use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw(query header_hash env status));

use Sledge::Request::Table;
use Sledge::Request::PSGI::Upload;
use Plack::Request;

sub new {
    my ($class, $env) = @_;
    bless {
        env         => $env,
        query       => Plack::Request->new($env),
        header_hash => {},
        status      => 200,
        body        => [],
    }, $class;
}

sub header_out {
    my ($self, $key, $value) = @_;
    $self->header_hash->{$key} = $value if @_ == 3;
    $self->header_hash->{$key};
}

sub headers_out {
    my $self = shift;
    return wantarray ? %{$self->header_hash}
        : Sledge::Request::Table->new($self->header_hash);
}

sub header_in {
    my ($self, $key) = @_;
    $key =~ s/-/_/g;
    return $self->env->{"HTTP_" . uc($key)};
}

sub content_type {
    my ($self, $type) = @_;
    $self->header_out('Content-Type' => $type);
}

sub send_http_header {
    # do nothing
}

sub method {
    my $self = shift;
    return $self->env->{REQUEST_METHOD} || 'GET';
}

sub print {
    my $self = shift;
    push @{$self->{body}}, @_;
}

sub uri {
    my $self = shift;
    # $REQUEST_URI - Query String
    my $uri = $self->env->{REQUEST_URI};
    $uri =~ s/\?.*$//;
    return $uri;
}

sub args {
    my $self = shift;
    return $self->env->{QUERY_STRING};
}

sub upload {
    my $self = shift;
    Sledge::Request::PSGI::Upload->new($self, @_);
}

sub param {
    my $self = shift;
    # $r->param(foo => \@bar);
    if (@_ == 2 && ref($_[1]) eq 'ARRAY') {
        return $self->query->param($_[0], @{$_[1]});
    }
    $self->query->param(@_);
}

sub DESTROY { }

sub AUTOLOAD {
    (my $meth = our $AUTOLOAD) =~ s/.*:://;
    no strict 'refs';
    *{$meth} = sub {
        use strict;
        my $self = shift;
        $self->query->$meth(@_);
    };
    goto &$meth;
}

sub finalize {
    my $self = shift;
    my %header = %{$self->{header_hash}};
    my @h;
    for my $key (keys %header) {
        if (ref $header{$key} eq 'ARRAY') {
            push @h, $key, $_ for @{$header{$key}};
        } else {
            push @h, $key, $header{$key};
        }
    }
    [$self->status, \@h, $self->{body}];
}
1;
__END__
