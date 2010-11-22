use strict;
use Test::More tests => 12;
BEGIN { $ENV{SLEDGE_CONFIG_NAME} = '_test' }
use Plack::Test;
use HTTP::Request::Common;

package t::TestProj::Pages::Test;
use Test::More;
use File::Basename;
use base 't::TestProj::Pages';

sub dispatch_upload {
    my $self = shift;
    my @upload = $self->r->upload;
    is scalar @upload, 2;
    my $file1 = $self->r->upload('file1');
    isa_ok $file1, 'Sledge::Request::PSGI::Upload';
    is $file1->name, 'file1';
    is $file1->filename, basename(__FILE__);
    is $file1->size, -s __FILE__;
    ok $file1->tempname;
    ok $file1->type;
    ok $file1->info->{'Content-Type'};
    ok $file1->info->{'Content-Disposition'};

    my $fh = $file1->fh;
    ok $fh;
    chomp(my $line = <$fh>);
    is $line, 'use strict;';
    ok $fh->close;

    $self->r->content_type('text/plain');
    $self->finished(1);
}

package main;

test_psgi
    app => sub { t::TestProj::Pages::Test->new(@_)->dispatch('upload') },
    client => sub {
        shift->(
            POST '/upload',
                Content_Type => 'form-data',
                Content      => [
                    file1 => [ __FILE__ ],
                    file2 => [ __FILE__ ],
                ]
        );
    };
