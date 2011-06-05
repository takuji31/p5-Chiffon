package  TestApp::Web::Controller;
use strict;
use warnings;
use parent 'Chiffon::Web::Controller';

__PACKAGE__->add_trigger(
    before_action => sub {
        my ($self, $c) = @_;
        $c->stash->{trigger} = "trigger call!";
    }
);

1;
