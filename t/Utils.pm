package  t::Utils;
use strict;
use warnings;
use lib qw(
    ./t/
    ./t/testapp/lib/
);

sub import {
    my $class  = shift;
    my $caller = caller;
    strict->import;
    warnings->import;
}

1;
