package  TestApp::Web::C::Root;
use Chiffon;
use Chiffon::Web::Controller;
use TestApp::Container;

sub index {
    my $self = shift;
    $self->stash->{title} = "Hello Chiffon World!";
    warn container('home')->stringify;
}

1;
