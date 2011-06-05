package  TestApp::Web::C::Root;
use strict;
use warnings;
use parent 'TestApp::Web::Controller';

sub do_index {
    my ($class, $c) = @_;
    $c->stash->{msg} = "HelloChiffonWorld!";
}

sub do_redirect {
    my ($class, $c) = @_;
    $c->redirect("/");
}

1;
