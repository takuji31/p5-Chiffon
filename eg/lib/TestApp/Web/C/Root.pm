package  TestApp::Web::C::Root;
use Chiffon;
use Chiffon::Web::Controller;

sub index {
    my $self = shift;
    $self->stash->{title} = "Hello Chiffon World!";
}
