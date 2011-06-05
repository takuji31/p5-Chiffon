use strict;
use warnings;
use Test::More;
use t::Utils;
use TestApp;

subtest "Export methods" => sub {
    can_ok('TestApp',qw(add_method base_dir camelize));
    done_testing;
};

done_testing;
