package  Chiffon::Web::Controller;
use strict;
use warnings;

use Chiffon::Trigger;

sub has_action {
    my ($class, $action) = @_;
    return $class->can("do_$action");
}

sub run_action {
    my ($class, $c, $action, $args) = @_;
    $action = "do_$action";
    $args ||= [];

    $class->call_trigger('before_action', $c, @$args);
    $class->$action($c, @$args);
    $class->call_trigger('after_action', $c, @$args);
    return $c;
}

1;
