package Sledge::Request::PSGI::Upload;
use strict;
use warnings;
use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw/req name upload/);

use Sledge::Request::Table;
use Plack::Request::Upload;

sub new {
    my ($class, $req, $name) = @_;
    return $class->_new_from_name($req, $name) if defined $name;
    return $class->_new_list($req);
}

sub _new_list {
    my ($class, $req) = @_;
    my @names = $class->_param_names($req);
    return wantarray
        ? map $class->_new_from_name($req, $_), @names
            : $class->_new_from_name($req, $names[0]);
}

sub _new_from_name {
    my ($class, $req, $name) = @_;
    my $upload = $req->query->upload($name) or return;
    bless {
        req    => $req,
        name   => $name,
        upload => $upload,
    }, $class;
}

sub _param_names {
    my ($class, $req) = @_;
    return keys %{$req->uploads};
}

sub filename {
    my $self = shift;
    return $self->upload->filename;
}

sub size {
    my $self = shift;
    return $self->upload->size;
}

sub info {
    my ($self, $key) = @_;
    my $headers = $self->upload->headers;
    my %info = (
        'Content-Type'        => scalar $headers->content_type,
        'Content-Disposition' => scalar $headers->header('Content-Disposition'),
    );
    return defined $key
        ? $info{$key} : Sledge::Request::Table->new(\%info);
}

sub type {
    my $self = shift;
    return $self->upload->content_type;
}

sub next {
    my $self = shift;
    my $class = ref $self;
    my @names = $class->_param_names($self->req);
    my %name2idx = map { $names[$_] => $_ } 0..$#names;

    my $next_idx = $name2idx{$self->name} + 1;
    return $next_idx > $#names
        ? undef : $class->_new_from_name($self->req, $names[$next_idx]);
}

sub tempname {
    my $self = shift;
    return $self->upload->path;
}

sub link {
    my ($self, $path) = @_;
    link $self->tempname, $path;
}

sub fh {
    my $self = shift;
    open my $fh, '<', $self->tempname or die $!;
    $fh;
}

1;
__END__
