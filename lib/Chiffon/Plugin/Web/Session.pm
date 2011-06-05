package  Chiffon::Plugin::Web::Session;
use strict;
use warnings;

use parent 'Exporter::Lite';
use Plack::Session;

our @EXPORT = qw(
    session
);


sub session {
    my $self = shift;
    $self->{session} ||= Plack::Session->new($self->req->env);
}

1;
