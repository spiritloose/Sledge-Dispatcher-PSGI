package Sledge::Request::PSGI;
use strict;
use warnings;

use Sledge::Request::Table;
use Plack::Request;
use Plack::Response;

sub new {
    my ($class, $env) = @_;
    bless {
        query  => Plack::Request->new($env),
        res    => Plack::Response->new(200),
        pnotes => {},
    }, $class;
}

sub query { shift->{query} }

sub res { shift->{res} }

sub header_out {
    my ($self, $key, $value) = @_;
    $self->res->header($key => $value) if @_ == 3;
    $self->res->header($key);
}

sub headers_out {
    my $self = shift;
    my %header_hash;
    $self->res->headers->scan(sub {
        $header_hash{$_[0]} = $_[1];
    });
    return wantarray ? %header_hash
    : Sledge::Request::Table->new(\%header_hash);
}

sub header_in {
    my ($self, $key) = @_;
    $self->query->header($key);
}

sub content_type {
    my ($self, $type) = @_;
    $self->header_out('Content-Type' => $type);
}

sub send_http_header {}

sub status {
    my ($self, $status) = @_;
    $self->res->status($status);
}

sub print {
    my $self = shift;
    my $body = ($self->res->body || '') . join('', @_);
    $self->res->body($body);
}

sub uri {
    my $self = shift;
    $self->query->uri->path;
}

sub args {
    my $self = shift;
    $self->query->env->{QUERY_STRING};
}

sub param {
    my $self = shift;
    # $r->param(foo => \@bar);
    if (@_ == 2 && ref($_[1]) eq 'ARRAY') {
        return $self->query->param($_[0], @{$_[1]});
    }
    $self->query->param(@_);
}

sub pnotes {
    my $self = shift;
    if (@_ == 0) {
        return keys %{$self->{pnotes}};
    } elsif (@_ == 1) {
        return $self->{pnotes}->{$_[0]};
    } else {
        $self->{pnotes}->{$_[0]} = $_[1];
    }
}

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

sub DESTROY {}

1;
__END__
