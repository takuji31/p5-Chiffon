package  TestApp::Web::C::Root;
use Chiffon;
use Chiffon::Web::Controller;
use TestApp::Container;

sub do_index {
    my $self = shift;
    $self->stash->{title} = "Hello Chiffon World!";
}
sub do_test {
    my $self = shift;
    return $self->redirect("http://senchan.jp");
}

1;
