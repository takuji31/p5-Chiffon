package  Chiffon::Web::Context;
use Chiffon::Core;

use Class::Accessor::Lite (
    new => 1,
    ro  => [qw/ env req res config view session dispatch_rule /],
);

sub stash :lvalue { shift->{stash} }
sub template { shift->{dispatch_rule}->{template} }
*request = \&req;
*response = \&res;

sub initialize {
    my $self = shift;
    $self->create_session;
}

sub create_session {
    my $self = shift;
    $self->{session} = Plack::Session->new($self->env);
}
